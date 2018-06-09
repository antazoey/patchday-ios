//
//  NotificationController.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/6/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import UserNotifications

internal class PDNotificationController: NSObject, UNUserNotificationCenterDelegate {
    
    // Description:  class for controlling PatchDay's notifications.
    
    // MARK: - Essential
    
    internal var center = UNUserNotificationCenter.current()
    
    internal var currentScheduleIndex = 0
    
    internal var sendingNotifications = true
    
    internal var pillMode: Int = -1
    
    override init() {
        super.init()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            // Enable or disable features based on authorization, granted is a bool meaning it errored
        }
        UNUserNotificationCenter.current().delegate = self
    }
    
    internal func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // ACTION:  Autofill pressed
        if response.actionIdentifier == "changeActionID" {
            if ScheduleController.coreData.getMO(forIndex: currentScheduleIndex) != nil {
                // Change the patch using a Suggested Location from the Autofill Location functionality.
                let suggestedLocation = SLF.suggest(scheduleIndex: currentScheduleIndex, generalLocations: ScheduleController.schedule().makeArrayOfLocations())
                // Suggested date and time is the current date and time.
                let suggestDate = Date()
                ScheduleController.coreData.setMO(scheduleIndex: currentScheduleIndex, date: suggestDate, location: suggestedLocation)
                UIApplication.shared.applicationIconBadgeNumber -= 1
            }
        }
        if response.actionIdentifier == "takeActionID" {
            let keys = [PDStrings.tbStamp_key(), PDStrings.pgStamp_key()]
            let dailies = [PillDataController.getTBDailyInt(), PillDataController.getPGDailyInt()]
            var stamps: Stamps = []
            // Temp stamps gets member stamps
            if self.pillMode == 0, let tb_s = PillDataController.tb_stamps{
                stamps = tb_s
            }
            else if self.pillMode == 1 , let pg_s = PillDataController.pg_stamps {
                stamps = pg_s
            }
            // Take, use temp stamps
            PillDataController.take(this: &stamps, at: Date(), timesaday: dailies[self.pillMode], key: keys[self.pillMode])
            // Member stamps get temp stamps
            if self.pillMode == 0 {
                PillDataController.tb_stamps = stamps
            }
            else if self.pillMode == 1 {
                PillDataController.pg_stamps = stamps
            }
            UIApplication.shared.applicationIconBadgeNumber -= 1
        }
    }

    // MARK: - notifications
    
    /****************************************************
     requestNotifiyExpired(mode) : For expired patches or injection.
     ****************************************************/
    internal func requestNotifyExpired(scheduleIndex: Int) {
        let notifyTime = UserDefaultsController.getNotificationTimeDouble()
        if let mo = ScheduleController.coreData.getMO(forIndex: scheduleIndex), sendingNotifications,
            UserDefaultsController.getRemindMeUpon(), var timeIntervalUntilExpire = mo.determineIntervalToExpire(timeInterval: UserDefaultsController.getTimeInterval()) {
            self.currentScheduleIndex = scheduleIndex
            // notification's attributes
            let content = UNMutableNotificationContent()
            if (UserDefaultsController.getDeliveryMethod() == PDStrings.deliveryMethods[0]) {
                content.title = (notifyTime == 0) ? PDStrings.patchExpired_title : PDStrings.patchExpiresSoon_title
            }
            else {
                content.title = (notifyTime == 0) ? PDStrings.injectionExpired_title : PDStrings.injectionExpiresSoon_title
            }
            content.body = mo.notificationMessage(timeInterval: UserDefaultsController.getTimeInterval())
            content.sound = UNNotificationSound.default()
            content.badge = ScheduleController.schedule().expiredCount(timeInterval: UserDefaultsController.getTimeInterval()) + PillDataController.totalDue() + 1 as NSNumber
            let allowsSLF = UserDefaultsController.getSLF()
            if allowsSLF {
                // changeAction is an action for changing the patch from a notification using the Autofill Location Functionality (the SLF Bool from the Settings must be True) and the current date and time.
                let changeAction = UNNotificationAction(identifier: "changeActionID",
                    title: PDStrings.autoChange_string, options: [])
                
                // add the action int the category
                let changeCategory = UNNotificationCategory(identifier: "changeCategoryID", actions: [changeAction], intentIdentifiers: [], options: [])
                self.center.setNotificationCategories([changeCategory])
                
                // suggest location in the notification body text
                content.body += "\n\n" + PDStrings.notificationSuggestedLocation + ScheduleController.schedule().suggestLocation(scheduleIndex: scheduleIndex)
                
                // adopt category
                content.categoryIdentifier = "changeCategoryID"
            }
            // Trigger
            timeIntervalUntilExpire = timeIntervalUntilExpire - (notifyTime * 60.0)
            if timeIntervalUntilExpire > 0 {
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeIntervalUntilExpire, repeats: false)
                // Request
                if let id = PDStrings.changeSoonIDs[scheduleIndex] {
                    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger) // Schedule the notification.
                    self.center.add(request) { (error : Error?) in
                        if error != nil {
                            print("Unable to Add Notification Request (\(String(describing: error)), \(String(describing: error?.localizedDescription)))")
                        }
                    }
                }
            }
        }
    }
    
    /****************************************************
    requestNotifiyTakePill(mode) : Where mode = 0 means TB,
                                   mode = 1 means PG.
    ****************************************************/
    internal func requestNotifyTakePill(mode: Int) {
        self.pillMode = mode
        if !sendingNotifications {
            return
        }
        // Each array is 1x2, mode picks the correct values corresponding to TB or PG.
        let titles: [String] = [PDStrings.takeTBNotificationTitle, PDStrings.takePGNotificationTitle]
        let messages: [String] = [PDStrings.takeTBNotificationMessage, PDStrings.takePGNotificationMessage]
        let timesadays: [Int] = [PillDataController.getTBDailyInt(), PillDataController.getPGDailyInt()]
        let stamps: [Date?] = [PillDataController.getLaterStamp(stamps: PillDataController.tb_stamps), PillDataController.getLaterStamp(stamps: PillDataController.pg_stamps)]
        let firstTimes: [Date?] = [PillDataController.getTB1Time(), PillDataController.getPG1Time()]
        let secondTimes: [Date?] = [PillDataController.getTB2Time(), PillDataController.getPG2Time()]
        let content = UNMutableNotificationContent()
        
        // Content
        content.title = titles[mode]
        content.body = messages[mode]
        content.sound = UNNotificationSound.default()
        content.badge = ScheduleController.schedule().expiredCount(timeInterval: UserDefaultsController.getTimeInterval()) + PillDataController.totalDue() + 1 as NSNumber
        
        // Take Action
        let takeAction = UNNotificationAction(identifier: "takeActionID",
                                                title: PDStrings.take, options: [])
        let takeCategory = UNNotificationCategory(identifier: "takeCategoryID", actions: [takeAction], intentIdentifiers: [], options: [])
        self.center.setNotificationCategories([takeCategory])
        content.categoryIdentifier = "takeCategoryID"
        
        // Interval determination - TB1 or TB2? (or PG1 or PG2)
        let usingSecondTime = PillDataController.useSecondTime(timesaday: timesadays[mode], stamp: stamps[mode])
        var choiceDate = Date()
        let now = Date()
        // Using Second Time
        if usingSecondTime, let secondTime = secondTimes[mode], let todayDate = PillDataController.getTodayDate(at: secondTime) {
            choiceDate = todayDate
        }
        // Using First Time
        else {
            if let firstTime = firstTimes[mode] {
                if stamps[mode] == nil || !Calendar.current.isDate(stamps[mode]!, inSameDayAs: Date()) {
                    if let todayDate = PillDataController.getTodayDate(at: firstTime) {
                        choiceDate = todayDate
                    }
                }
                else if let tomorrow = PillDataController.getDate(at: firstTime, daysToAdd: 1) {
                    choiceDate = tomorrow
                }
            }
        }
        
        // Only request if the choiceDate is after now
        if now < choiceDate {
            let interval = choiceDate.timeIntervalSince(now)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            // Request
            let id = PDStrings.pillIDs[mode]
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger) // Schedule the notification.
            self.center.add(request) { (error : Error?) in
                if error != nil {
                    print("Unable to Add Notification Request (\(String(describing: error)), \(String(describing: error?.localizedDescription)))")
                }
            }
        }
    }
    
    internal func cancelSchedule(index: Int) {
        if let id = PDStrings.changeSoonIDs[index] {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        }
    }
    
    internal func cancelPills(identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
}
