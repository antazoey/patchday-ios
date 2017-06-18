//
//  NotificationController.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/6/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit
import UserNotifications

class PDNotificationController: NSObject, UNUserNotificationCenterDelegate {
    
    // MARK: - Essential
    
    public var center = { return UNUserNotificationCenter.current() }()
    
    public var currentPatchIndex = 0
    
    override init() {
        super.init()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            // Enable or disable features based on authorization, granted is a bool meaning it errored
        }
        UNUserNotificationCenter.current().delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // ACTION:  Change Patch pressed
        if response.actionIdentifier == "changePatchActionID" {
            // change the current patch data
            PatchDataController.changePatchFromNotification(patchIndex: self.currentPatchIndex)
            // erase badge number
            UIApplication.shared.applicationIconBadgeNumber -= 1
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    }
    
    // MARK: - notifications
    
    func requestNotifyExpiredAndChangeSoon(patchIndex: Int) {
        self.requestNotifyExpired(patchIndex: patchIndex)
        self.requestNotifyChangeSoon(patchIndex: patchIndex)
    }
    
    func requestNotifyChangeSoon(patchIndex: Int) {
        let minutesBefore = Double(SettingsController.getNotificationTimeString())
        let secondsBefore = minutesBefore! * 60.0
        let intervalUntilTrigger = (PatchDataController.getPatch(forIndex: patchIndex)!.determineIntervalToExpire()! - secondsBefore)
        // notification's attributes
        let content = UNMutableNotificationContent()
        content.title = PatchDayStrings.changePatch_string
        content.body = PatchDataController.notificationString(index: patchIndex)
        content.sound = UNNotificationSound.default()
        // trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: intervalUntilTrigger, repeats: false)
        // request
        let request = UNNotificationRequest(identifier: PatchDayStrings.patchChangeSoonIDs[patchIndex]! + "chg", content: content, trigger: trigger) // Schedule the notification.
        self.center.add(request) { (error : Error?) in
            if error != nil {
                
                // Handle any errors
            }
        }
    }
    
    func requestNotifyExpired(patchIndex: Int) {
        self.currentPatchIndex = patchIndex
        let allowsAutoChooseLocation = SettingsController.getAutoChooseBool()
        if allowsAutoChooseLocation {
            let changePatchAction = UNNotificationAction(identifier: "changePatchActionID",
                                                     title: PatchDayStrings.changePatch_string, options: [])
            let changePatchCategory = UNNotificationCategory(identifier: "changePatchCategoryID",
                                                         actions: [changePatchAction],
                                                         intentIdentifiers: [],
                                                         options: [])
            self.center.setNotificationCategories([changePatchCategory])
        }
        
        // notification's attributes
        let content = UNMutableNotificationContent()
        content.title = PatchDayStrings.expiredPatch_string
        content.body = PatchDataController.notificationString(index: patchIndex)
        content.sound = UNNotificationSound.default()
        content.badge = 1
        if allowsAutoChooseLocation {
            // suggest location in text
            content.body += "\n\n" + PatchDayStrings.notificationSuggestion + PatchDataController.suggestLocation(patchIndex: patchIndex)
            // adopt category
            content.categoryIdentifier = "changePatchCategoryID"
        }
        // Trigger
        let timeInterval = PatchDataController.getPatch(forIndex: patchIndex)!.determineIntervalToExpire()!
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        // Request
        let request = UNNotificationRequest(identifier: PatchDayStrings.patchChangeSoonIDs[patchIndex]! + "exp", content: content, trigger: trigger) // Schedule the notification.
        self.center.add(request) { (error : Error?) in
            if error != nil {
                
                // Handle any errors
            }
        }
        
    }
}
