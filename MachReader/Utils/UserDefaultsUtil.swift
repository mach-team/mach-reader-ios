//
//  UserDefaultUtil.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/06/22.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import Foundation

class UserDefaultsUtil {
    static let userDefaults = UserDefaults.standard
    static let group = UserDefaults(suiteName: suiteName)!
    
    private static let suiteName = "group.tech.mach.mach-reader"
    private static let keyIsFirstOpen = "IS_FIRST_OPEN"
    private static let keyShareBookData = "SHARE_DATA"
    private static let keyShowOthersHighlight = "SHOW_OTHERS_HIGHLIGHT"
    private static let keyIsPrivateActivity = "IS_PRIVATE_ACTIVITY"
    private static let keyShowOthersHighlightList = "SHOW_OTHERS_HIGHLIGHT_LIST"
    private static let keyFcmToken = "FCM_TOKEN"

    static var isFirstOpen: Bool {
        set {
            userDefaults.set(newValue, forKey: keyIsFirstOpen)
            userDefaults.synchronize()
        }
        
        get {
            return (userDefaults.value(forKey: keyIsFirstOpen) as? Bool) ?? true
        }
    }
    
    static var showOthersHighlight: Bool {
        set {
            userDefaults.set(newValue, forKey: keyShowOthersHighlight)
            userDefaults.synchronize()
        }
        
        get {
            return (userDefaults.value(forKey: keyShowOthersHighlight) as? Bool) ?? true
        }
    }
    
    static var isPrivateActivity: Bool {
        set {
            userDefaults.set(newValue, forKey: keyIsPrivateActivity)
            userDefaults.synchronize()
        }
        
        get {
            return userDefaults.bool(forKey: keyIsPrivateActivity)
        }
    }
    
    static var showOthersHighlightList: Bool {
        set {
            userDefaults.set(newValue, forKey: keyShowOthersHighlightList)
            userDefaults.synchronize()
        }
        
        get {
            return userDefaults.bool(forKey: keyShowOthersHighlightList)
        }
    }
    
    static var sharedBookData: Data? {
        set {
            group.set(newValue, forKey: keyShareBookData)
            group.synchronize()
        }
        
        get {
            return group.data(forKey: keyShareBookData)
        }
    }
    
    static var fcmToken: String? {
        set {
            userDefaults.set(newValue, forKey: keyFcmToken)
            userDefaults.synchronize()
        }
        
        get {
            return userDefaults.string(forKey: keyFcmToken)
        }
    }
    
}
