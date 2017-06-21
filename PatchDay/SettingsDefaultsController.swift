//
//  SettingsDefaultsController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/25/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

class SettingsDefaultsController: NSObject {
    
    static private var patchInterval: String = "Half-Week"
    static private var numberOfPatches: String =  "4"
    
    //notifications
    static private var remindMe: Bool = true
    static private var notificationOption: String = "30"
    static private var autoChooseLocation: Bool = false
    
    static private var defaults = UserDefaults.standard

    // MARK: - a static init()
    
    static func setUp() {
        loadPatchInterval()
        loadNumberOfPatches()
        loadNotificationOption()
        loadAutoChooseLocation()
        loadRemindMe()
    }
    
    // MARK: - Getters
    
    static func getPatchInterval() -> String {
        return self.patchInterval
    }
    
    static func getNumberOfPatches() -> String {
        return self.numberOfPatches
    }
    
    static func getNotificaitonOption() -> String {
        return self.notificationOption
    }
    
    static func getAutoChooseLocation() -> Bool {
        return self.autoChooseLocation
    }
    
    static func getRemindMe() -> Bool {
        return self.remindMe
    }
    
    // MARK: - Setters
    
    static func setPatchInterval(to: String) {
        self.patchInterval = to
        self.defaults.set(self.getPatchInterval(), forKey: PatchDayStrings.patchChangeInterval_string())
        self.synchonize()
    }
    
    static func setNumberOfPatches(to: String) {
        self.numberOfPatches = to
        defaults.set(self.getNumberOfPatches(), forKey: PatchDayStrings.numberOfPatches_string())
        self.synchonize()
    }
    
    static func setNotificationOption(to: String) {
        self.notificationOption = to
        defaults.set(self.getNotificaitonOption(), forKey: PatchDayStrings.notificationKey_string())
        self.synchonize()
    }
    
    static func setAutoChooseLocation(to: Bool) {
        self.autoChooseLocation = to
        self.defaults.set(self.autoChooseLocation, forKey: PatchDayStrings.autoChooseLocation_string())
        self.synchonize()
    }
    
    static func setRemindMe(to: Bool) {
        self.remindMe = to
        self.defaults.set(self.remindMe, forKey: PatchDayStrings.remindMe_string())
        self.synchonize()
    }
    
    //MARK: - Synchronize
    
    static func synchonize() {
        defaults.synchronize()
    }
    
    // MARK: - loaders
    
    static private func loadPatchInterval() {
        if let interval = defaults.object(forKey: PatchDayStrings.patchChangeInterval_string()) as? String {
            patchInterval = interval
        }
    }
    
    static private func loadNumberOfPatches() {
        if let patchCount = defaults.object(forKey: PatchDayStrings.numberOfPatches_string()) as? String {
            numberOfPatches = patchCount
        }
    }
    
    static private func loadNotificationOption() {
        if let notifyTime = defaults.object(forKey: PatchDayStrings.notificationKey_string()) as? String {
            notificationOption = notifyTime
        }
    }
    
    static private func loadAutoChooseLocation() {
        if let autoLoad = defaults.object(forKey: PatchDayStrings.autoChooseLocation_string()) as? Bool {
            autoChooseLocation = autoLoad
        }
    }
    
    static private func loadRemindMe() {
        if let notifyMe = defaults.object(forKey: PatchDayStrings.remindMe_string()) as? Bool {
            remindMe = notifyMe
        }
    }
    
}
