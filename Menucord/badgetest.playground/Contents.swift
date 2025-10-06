import Foundation
import CoreFoundation

//func getBadgeLabel(_ pid: Int32) -> String? {
//    guard let appInfo = _LSCopyApplicationInformation(kLSDefaultSessionID, _LSCopyRunningApplicationArray(kLSDefaultSessionID).first as CFArray, "com.apple.launchd" as CFString) as? [String: CFDictionary],
//          let bundleID = appInfo["LSApplicationIdentifier"] as? String,
//}

let CoreServiceBundle = CFBundleGetBundleWithIdentifier("com.apple.CoreServices" as CFString)

typealias LSASN = CFTypeRef
let kLSDefaultSessionID: Int32 = -2
let badgeLabelKey = "StatusLabel" // TODO: Is there a `_kLS*` constant for this?

typealias _LSCopyRunningApplicationArray_Type = @convention(c) (Int32) -> [LSASN]

let _LSCopyRunningApplicationArray: _LSCopyRunningApplicationArray_Type = {
    let untypedFnPtr = CFBundleGetFunctionPointerForName(CoreServiceBundle, "_LSCopyRunningApplicationArray" as CFString)
    return unsafeBitCast(untypedFnPtr, to: _LSCopyRunningApplicationArray_Type.self)
}()

typealias _LSCopyApplicationInformation_Type = @convention(c) (Int32, CFTypeRef, CFString?) -> [CFString: CFDictionary]

let _LSCopyApplicationInformation: _LSCopyApplicationInformation_Type = {
    let untypedFnPtr = CFBundleGetFunctionPointerForName(CoreServiceBundle, "_LSCopyApplicationInformation" as CFString)
    return unsafeBitCast(untypedFnPtr, to: _LSCopyApplicationInformation_Type.self)
}()

func getAllAppASNs() -> [LSASN] {
    _LSCopyRunningApplicationArray(kLSDefaultSessionID)
}

func getAppInfo(asn: LSASN, property: String? = nil) -> [String: Any] {
    return _LSCopyApplicationInformation(kLSDefaultSessionID, asn, property as CFString?) as [String: Any]
}


let apps = getAllAppASNs()
let appInfos = apps.map { getAppInfo(asn: $0) }

let appBadges = Dictionary(uniqueKeysWithValues:
    appInfos.compactMap { appInfo -> (key: String, value: String)? in
        guard let badgeLabel = appInfo[badgeLabelKey] else { return nil }
        
        // It's posisble to make apps with no bundle
        let appName = appInfo[kCFBundleNameKey as String] as! String? ?? "<no bundle name>"
        let badgeString = (badgeLabel as! [String: String])["label"]!
        
        return (key: appName, value: badgeString)
    }
)

appBadges.forEach { k, v in print("\(k): '\(v)'")}
