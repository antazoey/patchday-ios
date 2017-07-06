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
    
    public var sendingNotifications = true
    
    override init() {
        super.init()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            // Enable or disable features based on authorization, granted is a bool meaning it errored
            if granted && !SettingsController.getNotifyMeBool() {
                self.sendingNotifications = false
                if !SettingsController.getMentionedNotifications() {
                    PDAlertController.alertForMaybeYouShouldUseNotifications()
                    SettingsController.setMentionedNotifications(with: true)
                }
            }
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

    // MARK: - notifications
    
    func requestNotifyChangeSoon(patchIndex: Int) {
        if let patch = PatchDataController.getPatch(forIndex: patchIndex), sendingNotifications, SettingsController.getNotifyMeBool() {
            let minutesBefore = SettingsController.getNotificationTimeDouble()
            let secondsBefore = minutesBefore * 60.0
            let intervalUntilTrigger = patch.determineIntervalToExpire() - secondsBefore
            // notification's attributes
            let content = UNMutableNotificationContent()
            content.title = PatchDayStrings.changePatch_string
            content.body = PatchDataController.notificationString(index: patchIndex)
            content.sound = UNNotificationSound.default()
            // trigger
            if intervalUntilTrigger > 0 {
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: intervalUntilTrigger, repeats: false)
                // request
                if let id = PatchDayStrings.patchChangeSoonIDs[patchIndex] {
                    let request = UNNotificationRequest(identifier: id + "chg", content: content, trigger: trigger) // Schedule the notification.
                    self.center.add(request) { (error : Error?) in
                        if error != nil {
                        print("Unable to Add Notification Request (\(String(describing: error)), \(String(describing: error?.localizedDescription)))")
                        }
                    }
                    
                }
            }
        }
    }
    
    func requestNotifyExpired(patchIndex: Int) {
        if let patch = PatchDataController.getPatch(forIndex: patchIndex), sendingNotifications {
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
            let timeIntervalUntilExpire = patch.determineIntervalToExpire()
            if timeIntervalUntilExpire > 0 {
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeIntervalUntilExpire, repeats: false)
                // Request
                if let id = PatchDayStrings.patchChangeSoonIDs[patchIndex] {
                    let request = UNNotificationRequest(identifier: id + "exp", content: content, trigger: trigger) // Schedule the notification.
                    self.center.add(request) { (error : Error?) in
                        if error != nil {
                            print("Unable to Add Notification Request (\(String(describing: error)), \(String(describing: error?.localizedDescription)))")
                        }
                    }
                }
            }
        }
    }
    
}
