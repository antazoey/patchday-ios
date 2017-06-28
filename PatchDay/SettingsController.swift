//
//  SettingsController.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/17/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

class SettingsController {
    
    static public var iCloudSettings = { return UbiquitousKeyValueStoreController() }()
    
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
        if usingCloud, let pcount = iCloudSettings.patchCount {
                return String(describing: pcount)
        }
        else {
            return SettingsDefaultsController.getNumberOfPatches()
        }
    }
    
    static public func getNumberOfPatchesInt() -> Int {
        if usingCloud, let pcount = iCloudSettings.patchCount {
            return pcount
        }
        else if let pcount = Int(SettingsDefaultsController.getNumberOfPatches()) {
            return pcount
        }
        else {
            return 0
        }
    }
    
    static public func getExpirationInterval() -> String {
        if usingCloud, let expInterval = iCloudSettings.expirationInterval {
            return expInterval
        }
        else {
            return SettingsDefaultsController.getPatchInterval()
        }
    }
    
    static public func getAutoChooseBool() -> Bool {
        if usingCloud, let autoLoc = iCloudSettings.autoChooseLocation  {
            return autoLoc
        }
        else {
            return SettingsDefaultsController.getAutoChooseLocation()
        }
    }
    
    static public func getNotificationTimeString() -> String {
        if usingCloud, let notTime = iCloudSettings.notificationTime {
            return String(describing: notTime)
        }
        else {
            return SettingsDefaultsController.getNotificaitonOption()
        }
    }
    
    static public func getNotificationTimeInt() -> Int {
        if usingCloud, let notTime = iCloudSettings.notificationTime {
            return notTime
        }
        else if let notTime = Int(SettingsDefaultsController.getNotificaitonOption()) {
            return notTime
        }
        else {
            return 0
        }
    }
    
    static public func getNotifyMeBool() -> Bool {
        if usingCloud, let notMe = iCloudSettings.notifyMe {
            return notMe
        }
        else {
            return SettingsDefaultsController.getRemindMe()
        }
    }
    
    static public func getMentionedNotifications() -> Bool {
        if usingCloud, let mentioned = iCloudSettings.mentionedNotifications {
            return mentioned
        }
        else {
            return SettingsDefaultsController.getMentionedNotifications()
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
        if usingCloud, let pcount = Int(with) {
            iCloudSettings.set(numberOfPatches: pcount)
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
        if usingCloud, let notTime = Int(with)  {
            iCloudSettings.setNotificationTime(with: notTime)
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
    
    static public func setMentionedNotifications(with: Bool) {
        if usingCloud {
            iCloudSettings.setMentioned(with: with)
        }
        SettingsDefaultsController.setMentionedNotifications(to: with)
    }
    
}
