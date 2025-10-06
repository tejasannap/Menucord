import Foundation
import SwiftUI
import CoreFoundation
import ApplicationServices

// MARK: Launch Services Wrapper
final class LaunchServicesWrapper {
    static let shared = LaunchServicesWrapper()
    
    private let coreServiceBundle = CFBundleGetBundleWithIdentifier("com.apple.CoreServices" as CFString)
    private let kLSDefaultSessionID: Int32 = -2
    private let badgeLabelKey = "StatusLabel"
    
    private typealias LSCopyRunningApplicationArrayType = @convention(c) (Int32) -> [CFTypeRef]
    private typealias LSCopyApplicationInformationType = @convention(c) (Int32, CFTypeRef, CFString?) -> [CFString: CFDictionary]
    
    private let copyRunningApplicationArray: LSCopyRunningApplicationArrayType?
    private let copyApplicationInformation: LSCopyApplicationInformationType?
    
    private init() {
        guard let bundle = coreServiceBundle else {
            copyRunningApplicationArray = nil
            copyApplicationInformation = nil
            return
        }
        
        if let ptr = CFBundleGetFunctionPointerForName(bundle, "_LSCopyRunningApplicationArray" as CFString) {
            copyRunningApplicationArray = unsafeBitCast(ptr, to: LSCopyRunningApplicationArrayType.self)
        } else {
            copyRunningApplicationArray = nil
        }
        
        if let ptr = CFBundleGetFunctionPointerForName(bundle, "_LSCopyApplicationInformation" as CFString) {
            copyApplicationInformation = unsafeBitCast(ptr, to: LSCopyApplicationInformationType.self)
        } else {
            copyApplicationInformation = nil
        }
    }
    
    func getBadgeLabel(for bundleName: String) -> String? {
        guard let copyRunningApps = copyRunningApplicationArray,
              let copyAppInfo = copyApplicationInformation else {
            return nil
        }
        
        let apps = copyRunningApps(kLSDefaultSessionID)
        
        for asn in apps {
            let appInfo = copyAppInfo(kLSDefaultSessionID, asn, nil) as [String: Any]
            
            guard let appName = appInfo[kCFBundleNameKey as String] as? String,
                  appName.lowercased().contains(bundleName.lowercased()) else {
                continue
            }
            
            if let badgeLabel = appInfo[badgeLabelKey] as? [String: String],
               let label = badgeLabel["label"] {
                return label
            }
        }
        
        return nil
    }
}

// MARK: Discord Monitor
class DiscordMonitor: ObservableObject {
    @Published var notificationCount: Int = 0
    @Published var isRunning: Bool = false
    
    var checkInterval: TimeInterval = 2.0 {
        didSet {
            if oldValue != checkInterval, timer != nil {
                restartMonitoring()
            }
        }
    }
    
    private var timer: Timer?
    private let launchServices = LaunchServicesWrapper.shared
    private let checkQueue = DispatchQueue(label: "com.discordmonitor.check", qos: .utility)
    
    private static let discordIdentifier = "discord"
    
    init() {
        startMonitoring()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { [weak self] _ in
            self?.checkNotifications()
        }
        checkNotifications()
    }
    
    private func restartMonitoring() {
        timer?.invalidate()
        startMonitoring()
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    func checkNotifications() {
        checkQueue.async { [weak self] in
            guard let self = self else { return }
            
            let workspace = NSWorkspace.shared
            let discordApps = workspace.runningApplications.filter {
                $0.bundleIdentifier?.lowercased().contains(Self.discordIdentifier) == true ||
                $0.localizedName?.lowercased().contains(Self.discordIdentifier) == true
            }
            
            let running = !discordApps.isEmpty
            let count: Int
            
            if running, let badgeLabel = self.launchServices.getBadgeLabel(for: Self.discordIdentifier) {
                count = Int(badgeLabel) ?? 0
            } else {
                count = 0
            }
            
            DispatchQueue.main.async {
                self.isRunning = running
                self.notificationCount = count
            }
        }
    }
}
