//
//  SettingsDefaultsController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/25/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

public class SettingsDefaultsController: NSObject {
    
    static private var patchInterval: String = "Half-Week"
    static internal var numberOfPatches: String =  "4"
    
    //notifications
    static private var remindMe: Bool = true
    static private var notificationOption: String = "30"
    static private var autoChooseLocation: Bool = true
    
    //rememberance
    static private var mentionedDisclaimer: Bool = false
    
    static private var defaults = UserDefaults.standard

    // MARK: - a static init()
    
    public static func setUp() {
        loadPatchInterval()
        loadNumberOfPatches()
        loadNotificationOption()
        loadAutoChooseLocation()
        loadRemindMe()
        loadMentionedDisclaimer()
    }
    
    // MARK: - Getters
    
    public static func getPatchInterval() -> String {
        return self.patchInterval
    }
    
    public static func getNumberOfPatchesString() -> String {
        return self.numberOfPatches
    }
    
    public static func getNumberOfPatchesInt() -> Int {
        if let int = Int(getNumberOfPatchesString()) {
            return int
        }
        else {
            return -1
        }
    }
    
    public static func getNotificaitonTimeString() -> String {
        return self.notificationOption
    }
    
    public static func getNotificationTimeInt() -> Int {
        if let int = Int(self.notificationOption) {
            return int
        }
        else {
            return -1
        }
    }
    
    public static func getNotificationTimeDouble() -> Double {
        if let double = Double(self.notificationOption) {
            return double
        }
        else {
            return -1
        }
    }
    
    public static func getAutoChooseLocation() -> Bool {
        return self.autoChooseLocation
    }
    
    public static func getRemindMe() -> Bool {
        return self.remindMe
    }
    
    public static func getMentionedDisclaimer() -> Bool {
        return self.mentionedDisclaimer
    }
    
    // MARK: - Setters
    
    public static func setPatchInterval(to: String) {
        self.patchInterval = to
        self.defaults.set(to, forKey: PDStrings.patchChangeInterval_string())
        self.synchonize()
    }
    
    public static func setNumberOfPatches(to: String) {
        let oldNumberOfPatches = self.getNumberOfPatchesInt()
            if let startIndex = Int(to) {
                // delete old patch data for easy sorting
                if startIndex < oldNumberOfPatches {
                    PDAlertController.alertForChangingPatchCount(startIndexForReset: startIndex, endIndexForReset: oldNumberOfPatches, newPatchCount: to)
                }
                else {
                    self.numberOfPatches = to
                    defaults.set(to, forKey: PDStrings.numberOfPatches_string())
                }
            }
        self.synchonize()
    }
    
    public static func setNotificationOption(to: String) {
        self.notificationOption = to
        defaults.set(to, forKey: PDStrings.notificationKey_string())
        self.synchonize()
    }
    
    public static func setAutoChooseLocation(to: Bool) {
        self.autoChooseLocation = to
        self.defaults.set(to, forKey: PDStrings.autoChooseLocation_string())
        self.synchonize()
    }
    
    static func setRemindMe(to: Bool) {
        self.remindMe = to
        self.defaults.set(to, forKey: PDStrings.remindMe_string())
        self.synchonize()
    }

    public static func setMentionedDisclaimer(to: Bool) {
        self.mentionedDisclaimer = to
        self.defaults.set(to, forKey: PDStrings.mentioned_string())
        self.synchonize()
    }
    
    //MARK: - Synchronize
    
    public static func synchonize() {
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
    
    static private func loadMentionedDisclaimer() {
        if let mentioned = defaults.object(forKey: PDStrings.mentioned_string()) as? Bool {
            mentionedDisclaimer = mentioned
        }
    }
}
