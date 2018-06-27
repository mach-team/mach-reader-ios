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
    
    private static let keyShowOthersHighlight = "SHOW_OTHERS_HIGHLIGHT"
    private static let keyIsPrivateActivity = "IS_PRIVATE_ACTIVITY"
    private static let keyShowOthersHighlightList = "SHOW_OTHERS_HIGHLIGHT_LIST"

    static var showOthersHighlight: Bool {
        set {
            userDefaults.set(newValue, forKey: keyShowOthersHighlight)
            userDefaults.synchronize()
        }
        
        get {
            return userDefaults.bool(forKey: keyShowOthersHighlight)
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
    
}
