import Foundation
import SwiftUI
import CoreFoundation
import ApplicationServices

// MARK: - Launch Services Badge API
let CoreServiceBundle = CFBundleGetBundleWithIdentifier("com.apple.CoreServices" as CFString)

typealias LSASN = CFTypeRef
let kLSDefaultSessionID: Int32 = -2
let badgeLabelKey = "StatusLabel"

typealias LSCopyRunningApplicationArrayType = @convention(c) (Int32) -> [LSASN]

let LSCopyRunningApplicationArray: LSCopyRunningApplicationArrayType = {
    let untypedFnPtr = CFBundleGetFunctionPointerForName(CoreServiceBundle, "_LSCopyRunningApplicationArray" as CFString)
    return unsafeBitCast(untypedFnPtr, to: LSCopyRunningApplicationArrayType.self)
}()

typealias LSCopyApplicationInformationType = @convention(c) (Int32, CFTypeRef, CFString?) -> [CFString: CFDictionary]

let LSCopyApplicationInformation: LSCopyApplicationInformationType = {
    let untypedFnPtr = CFBundleGetFunctionPointerForName(CoreServiceBundle, "_LSCopyApplicationInformation" as CFString)
    return unsafeBitCast(untypedFnPtr, to: LSCopyApplicationInformationType.self)
}()

func getBadgeLabel(for bundleName: String) -> String? {
    let apps = LSCopyRunningApplicationArray(kLSDefaultSessionID)
    
    for asn in apps {
        let appInfo = LSCopyApplicationInformation(kLSDefaultSessionID, asn, nil) as [String: Any]
        
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

class DiscordMonitor: ObservableObject {
    @Published var notificationCount: Int = 0
    @Published var isRunning: Bool = false
    @Published var checkInterval: TimeInterval = 2.0
    
    private var timer: Timer?
    
    init() {
        startMonitoring()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: self.checkInterval, repeats: true) { [weak self] _ in
            self?.checkNotifications()
        }
        checkNotifications()
    }
    
    func isDiscordRunning() -> Bool {
        let workspace = NSWorkspace.shared
        let discordApps = workspace.runningApplications.filter {
            $0.bundleIdentifier?.contains("discord") == true ||
            $0.localizedName?.lowercased().contains("discord") == true
        }
    
        if discordApps.isEmpty {
            self.isRunning = false
            return false
        }
        
        self.isRunning = true
        return true
    }
    
    func checkNotifications() {
        if !isDiscordRunning() {
            DispatchQueue.main.async { self.notificationCount = 0 }
            return
        }
        
        if let badgeLabel = getBadgeLabel(for: "discord") {
            if let fetchedCount = Int(badgeLabel) {
                if fetchedCount != notificationCount {
                    DispatchQueue.main.async { self.notificationCount = fetchedCount }
                }
                return
            } else { self.notificationCount = 0}
        }
    }
}

