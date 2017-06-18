//
//  SettingsController.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/17/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

class SettingsController {
    
    static public var iCloudSettings = { return PDiCloudKeyValueStoreController() }()
    
    static public var usingCloud: Bool = { return (UIApplication.shared.delegate as! AppDelegate).iCloudIsAvailable() }()
    
    static public func startUp() {
        // iCloud defaults
        if usingCloud {
            iCloudSettings.becomeLive()
        }
        // user defaults
        SettingsDefaultsController.setUp()
        
    }
    
    // MARK: - Getters. will try to grab icloud first
    
    static public func getNumberOfPatchesString() -> String {
        if usingCloud {
            return String(describing: iCloudSettings.patchCount!)
        }
        else {
            return SettingsDefaultsController.getNumberOfPatches()
        }
    }
    
    static public func getNumberOfPatchesInt() -> Int {
        if usingCloud {
            return iCloudSettings.patchCount!
        }
        else {
            return Int(SettingsDefaultsController.getNumberOfPatches())!
        }
    }
    
    static public func getExpirationInterval() -> String {
        if usingCloud {
            return iCloudSettings.expirationInterval!
        }
        else {
            return SettingsDefaultsController.getPatchInterval()
        }
    }
    
    static public func getAutoChooseBool() -> Bool {
        if usingCloud {
            return iCloudSettings.autoChooseLocation!
        }
        else {
            return SettingsDefaultsController.getAutoChooseLocation()
        }
    }
    
    static public func getNotificationTimeString() -> String {
        if usingCloud {
            return String(describing: iCloudSettings.notificationTime)
        }
        else {
            return SettingsDefaultsController.getNotificaitonOption()
        }
    }
    
    static public func getNotificationTimeInt() -> Int {
        if usingCloud {
            return iCloudSettings.notificationTime!
        }
        else {
            return Int(SettingsDefaultsController.getNotificaitonOption())!
        }
    }
    
    static public func getNotifyMeBool() -> Bool {
        if usingCloud {
            return iCloudSettings.notifyMe!
        }
        else {
            return SettingsDefaultsController.getRemindMe()
        }
    }
    
    // MARK: - Setters, always sets user defaults, conditionally sets icloud keys
    
    static public func setExpirationInterval(with: String) {
        if usingCloud {
            iCloudSettings.set(expirationInterval: with)
        }
        SettingsDefaultsController.setPatchInterval(to: with)
    }
    
    
    static public func setNumberOfPatches(with: String) {
        if usingCloud {
            iCloudSettings.set(numberOfPatches: Int(with)!)
        }
        SettingsDefaultsController.setNumberOfPatches(to: with)
    }
    
    static public func setNumberOfPatches(with: Int) {
        if usingCloud {
            iCloudSettings.set(numberOfPatches: with)
        }
        SettingsDefaultsController.setNumberOfPatches(to: String(describing: with))
    }
    
    static public func setAutoChoose(bool: Bool) {
        if usingCloud {
            iCloudSettings.set(autoChooseLocation: bool)
        }
        SettingsDefaultsController.setAutoChooseLocation(to: bool)
    }
    
    static public func setNotificationTime(with: String) {
        if usingCloud {
            iCloudSettings.setNotificationTime(with: Int(with)!)
        }
        SettingsDefaultsController.setNotificationOption(to: with)
    }
    
    static public func setNotificationTime(with: Int) {
        if usingCloud {
            iCloudSettings.setNotificationTime(with: with)
        }
        SettingsDefaultsController.setNotificationOption(to: String(describing: with))
    }
    
    static public func setNotifyMe(bool: Bool) {
        if usingCloud {
            iCloudSettings.setNotifyMe(with: bool)
        }
        SettingsDefaultsController.setRemindMe(to: bool)
    }
    
}
