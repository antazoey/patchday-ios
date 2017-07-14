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
    static private var autoChooseLocation: Bool = true
    
    //rememberance
    static private var mentionedDisclaimer: Bool = false
    
    static private var defaults = UserDefaults.standard

    // MARK: - a static init()
    
    static func setUp() {
        loadPatchInterval()
        loadNumberOfPatches()
        loadNotificationOption()
        loadAutoChooseLocation()
        loadRemindMe()
        
        // non icloud included
        loadMentionedDisclaimer()
    }
    
    // MARK: - Getters
    
    static func getPatchInterval() -> String {
        return self.patchInterval
    }
    
    static func getNumberOfPatchesString() -> String {
        return self.numberOfPatches
    }
    
    static func getNumberOfPatchesInt() -> Int {
        if let int = Int(getNumberOfPatchesString()) {
            return int
        }
        else {
            return -1
        }
    }
    
    static func getNotificaitonTimeString() -> String {
        return self.notificationOption
    }
    
    static func getNotificationTimeInt() -> Int {
        if let int = Int(self.notificationOption) {
            return int
        }
        else {
            return -1
        }
    }
    
    static func getNotificationTimeDouble() -> Double {
        if let double = Double(self.notificationOption) {
            return double
        }
        else {
            return -1
        }
    }
    
    static func getAutoChooseLocation() -> Bool {
        return self.autoChooseLocation
    }
    
    static func getRemindMe() -> Bool {
        return self.remindMe
    }
    
    static func getCloudKey() -> NSObjectProtocol? {
        if let key = defaults.object(forKey: "cloudKey") {
            return key as? NSObjectProtocol
        }
        return nil
    }
    
    // non icloud included
    
    static func getMentionedDisclaimer() -> Bool {
        return self.mentionedDisclaimer
    }
    
    // MARK: - Setters
    
    static func setPatchInterval(to: String) {
        self.patchInterval = to
        self.defaults.set(to, forKey: PDStrings.patchChangeInterval_string())
        self.synchonize()
    }
    
    static func setNumberOfPatches(to: String) {
        self.numberOfPatches = to
        defaults.set(to, forKey: PDStrings.numberOfPatches_string())
        self.synchonize()
    }
    
    static func setNotificationOption(to: String) {
        self.notificationOption = to
        defaults.set(to, forKey: PDStrings.notificationKey_string())
        self.synchonize()
    }
    
    static func setAutoChooseLocation(to: Bool) {
        self.autoChooseLocation = to
        self.defaults.set(to, forKey: PDStrings.autoChooseLocation_string())
        self.synchonize()
    }
    
    static func setRemindMe(to: Bool) {
        self.remindMe = to
        self.defaults.set(to, forKey: PDStrings.remindMe_string())
        self.synchonize()
    }
    
    // non icloud included
    
    static func setMentionedDisclaimer(to: Bool) {
        self.mentionedDisclaimer = to
        self.defaults.set(to, forKey: PDStrings.mentioned_string())
        self.synchonize()
    }
    
    static func setCloudKey(to: NSObjectProtocol) {
        self.defaults.set(to, forKey: "cloudKey")
        self.synchonize()
    }
    
    //MARK: - Synchronize
    
    static func synchonize() {
        defaults.synchronize()
    }
    
    // MARK: - loaders
    
    static private func loadPatchInterval() {
        if let interval = defaults.object(forKey: PDStrings.patchChangeInterval_string()) as? String {
            patchInterval = interval
        }
    }
    
    static private func loadNumberOfPatches() {
        if let patchCount = defaults.object(forKey: PDStrings.numberOfPatches_string()) as? String {
            numberOfPatches = patchCount
        }
    }
    
    static private func loadNotificationOption() {
        if let notifyTime = defaults.object(forKey: PDStrings.notificationKey_string()) as? String {
            notificationOption = notifyTime
        }
    }
    
    static private func loadAutoChooseLocation() {
        if let autoLoad = defaults.object(forKey: PDStrings.autoChooseLocation_string()) as? Bool {
            autoChooseLocation = autoLoad
        }
    }
    
    static private func loadRemindMe() {
        if let notifyMe = defaults.object(forKey: PDStrings.remindMe_string()) as? Bool {
            remindMe = notifyMe
        }
    }
    
    // non icloud included
    
    static private func loadMentionedDisclaimer() {
        if let mentioned = defaults.object(forKey: PDStrings.mentioned_string()) as? Bool {
            mentionedDisclaimer = mentioned
        }
    }
}
