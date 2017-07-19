//
//  SettingsDefaultsController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/25/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

public class SettingsDefaultsController: NSObject {
    
    // Description: The SettingsDefaultsController is the controller for the User Defaults that are unique to the user and their schedule.  There are schedule defaults and there are notification defaults.  The schedule defaults included the patch expiration interval (patchInterval) and the number of patches in the schedule (numberOfPatches).  The notification defaults includes a bool indicatinng whether the user wants a reminder and the time before expiration that the user would wish to receive the reminder.  It also includes a bool for the auto suggest location functionality.
    
    // Schedule defaults:
    
    static private var patchInterval: String = "Half-Week"
    static internal var numberOfPatches: String =  "4"
    
    // Notification defaults: 
    
    static private var remindMe: Bool = true
    static private var notificationOption: String = "30"
    static private var autoChooseLocation: Bool = true
    
    // Rememberance
    
    static private var mentionedDisclaimer: Bool = false
    
    // App 
    
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
    
    public static func setNumberOfPatchesWithWarning(to: String, oldNumberOfPatches: Int, numberOfPatchesButton: UIButton) {
        print ("old patch count: " + String(describing: oldNumberOfPatches))
        
        /* 
         This method will warn the user if they are about to delete patch data.
         
         It is necessary to reset patches that are no longer in the schedule, which happens when the user has is decreasing the number of patches in a full schedule.  Resetting unused patches makes sorting the schedule less error prone and more comprehensive.
        
         The variable "startIndexForResetingAndNewNumberOfPatches" represents two things.  1.) It is the start index for reseting patches that need to be reset from decreasing a full schedule, and 2.), it is the Int form of the new number of Patches
        */
        
            if let startIndexForResettingAndNewNumberOfPatches = Int(to) {
                // delete old patch data for easy sorting
                if startIndexForResettingAndNewNumberOfPatches < oldNumberOfPatches {
                    var patchesOnChoppingBlockHaveSetAttributes: Bool = true
                    for i in (startIndexForResettingAndNewNumberOfPatches...SettingsDefaultsController.getNumberOfPatchesInt() - 1) {
                        if let patch = PatchDataController.getPatch(index: i) {
                            // Don't display warning if all the patches being erased are empty.
                            if patch.isEmpty() {
                                patchesOnChoppingBlockHaveSetAttributes = false
                                self.numberOfPatches = to
                                defaults.set(to, forKey: PDStrings.numberOfPatches_string())
                                self.synchonize()
                                return
                            }
                        }
                        else {
                            patchesOnChoppingBlockHaveSetAttributes = false
                            self.numberOfPatches = to
                            defaults.set(to, forKey: PDStrings.numberOfPatches_string())
                            self.synchonize()
                            return
                        }
                    }
                    if patchesOnChoppingBlockHaveSetAttributes {
                        PDAlertController.alertForChangingPatchCount(startIndexForReset: startIndexForResettingAndNewNumberOfPatches, endIndexForReset: oldNumberOfPatches, newPatchCount: to, numberOfPatchesButton: numberOfPatchesButton)
                        self.synchonize()
                        return
                    }
                }
                else {
                    self.numberOfPatches = to
                    defaults.set(to, forKey: PDStrings.numberOfPatches_string())
                    self.synchonize()
                    return
                }
            }
    }
    
    public static func setNumberOfPatchesWithoutWarning(to: String) {
        self.numberOfPatches = to
        defaults.set(to, forKey: PDStrings.numberOfPatches_string())
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
