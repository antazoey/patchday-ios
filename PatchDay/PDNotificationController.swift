//
//  PDNotificationController.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/6/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import UserNotifications
import PDKit

internal class PDNotificationController: NSObject, UNUserNotificationCenterDelegate {
    
    // Description:  class for controlling PatchDay's notifications.
    
    // MARK: - Essential
    
    internal var center = UNUserNotificationCenter.current()
    internal var currentEstrogenIndex = 0
    internal var currentPillIndex = 0
    internal var sendingNotifications = true
    
    private var estroActionID = { return "estroActionID" }()
    private var takeActionID = { return "takeActionID" }()
    private var estroCategoryID = { return "estroCategoryID" }()
    private var pillCategoryID = { return "pillCategoryID" }()
    
    override init() {
        super.init()
        self.center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
        }
        center.setNotificationCategories(Set(getNotificationCategories()))
        UNUserNotificationCenter.current().delegate = self
    }
    
    // Handles responses received from interacting with notifications.
    internal func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.actionIdentifier == estroActionID, let uuid = UUID(uuidString: response.notification.request.identifier) {
            ScheduleController.estrogenController.setEstrogenMO(for: uuid, date: Date() as NSDate, site: SiteSuggester.getSuggestedSite())
            UIApplication.shared.applicationIconBadgeNumber -= 1
            }
        
        else if response.actionIdentifier == takeActionID,
            let uuid = UUID(uuidString: response.notification.request.identifier),
            let pill = PDPillHelper.getPill(in: ScheduleController.pillController.pillArray, for: uuid) {
            ScheduleController.pillController.take(pill)
            UIApplication.shared.applicationIconBadgeNumber -= 1
        }
    }
    
    public func resendEstrogenNotifications(upToRemove: Int, upToAdd: Int) {
        for i in 0...upToRemove {
            cancelEstrogenNotification(at: i)
        }
        for j in 0...upToAdd {
            let estro = ScheduleController.estrogenController.getEstrogenMO(at: j)
            requestEstrogenExpiredNotification(for: estro)
        }
    }
    
    public func resendPillNotification(for pill: MOPill) {
        cancelPill(pill)
        requestNotifyTakePill(pill)
    }

    // MARK: - notifications
    
    /**
     Notification for expired patches or injection.
     */
    private func determineEstrogenNotificationTitle(usingPatches: Bool, notifyTime: Double) -> String {
        let options = (usingPatches) ? [PDStrings.NotificationStrings.Titles.patchExpired, PDStrings.NotificationStrings.Titles.patchExpires] :
            [PDStrings.NotificationStrings.Titles.injectionExpired, PDStrings.NotificationStrings.Titles.injectionExpires]
        return (notifyTime == 0) ? options[0] : options[1]
    }
    
    private func determineEstrogenNotificationBody(for estro: MOEstrogen, intervalStr: String) -> String {
        var body = notificationBody(for: estro, intervalStr: intervalStr)
        let msg = (UserDefaultsController.usingPatches()) ? PDStrings.NotificationStrings.Bodies.siteForNextPatch : PDStrings.NotificationStrings.Bodies.siteForNextInjection
        if let additionalMessage = suggestSiteMessage(introMsg: msg) {
            body += additionalMessage
        }
        return body
    }
    
    /// Determines the proper message for expired notifications.
    public func notificationBody(for estro: MOEstrogen, intervalStr: String) -> String {
        var body = ""
        let usingPatches: Bool = UserDefaultsController.usingPatches()
        let siteName = estro.getSiteName()
        if !estro.isCustomLocated(usingPatches: usingPatches) && usingPatches {
            if let msg = PDStrings.NotificationStrings.Bodies.siteToExpiredPatchMessage[siteName] {
                body = msg
            }
        }
            
            // For custom sites or injections.
        else if usingPatches {
            body = PDStrings.NotificationStrings.Bodies.changePatchLocated + siteName
        }
        
        return body
    }
    
    private func suggestSiteMessage(introMsg: String) -> String? {
        if let suggestedSite = SiteSuggester.getSuggestedSite(), let siteName = suggestedSite.getName() {
            return "\n" + introMsg + siteName
        }
        return nil
    }
    
    
    internal func requestEstrogenExpiredNotification(for estro: MOEstrogen) {
        let intervalStr = UserDefaultsController.getTimeIntervalString()
        let usingPatches = UserDefaultsController.usingPatches()
        let notifyTime = Double(UserDefaultsController.getNotificationMinutesBefore())
        
        if sendingNotifications,
            UserDefaultsController.getRemindMeUpon(),
            let date = estro.getDate(),
            var timeIntervalUntilExpire = PDDateHelper.expirationInterval(intervalStr, date: date as Date), let id = estro.getID() {
            let content = UNMutableNotificationContent()
            
            content.title = determineEstrogenNotificationTitle(usingPatches: usingPatches, notifyTime: notifyTime)
            content.body = determineEstrogenNotificationBody(for: estro, intervalStr: intervalStr)
            content.sound = UNNotificationSound.default()
            content.badge = ScheduleController.totalDue(intervalStr: intervalStr) + 1 as NSNumber
            content.categoryIdentifier = estroCategoryID
            
            timeIntervalUntilExpire = timeIntervalUntilExpire - (notifyTime * 60.0)
            if timeIntervalUntilExpire > 0 {
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeIntervalUntilExpire, repeats: false)
                let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
                center.add(request) {
                    (error : Error?) in
                    if error != nil {
                        print("Unable to Add Notification Request (\(String(describing: error)), \(String(describing: error?.localizedDescription)))")
                    }
                }
            }
        }
    }
    
    internal func requestOvernightNotification(_ estro: MOEstrogen, expDate: Date) {
        let usingPatches = UserDefaultsController.usingPatches()
        let intervalStr = UserDefaultsController.getTimeIntervalString()
        let content = UNMutableNotificationContent()
        if let id = estro.getID(), let triggerDate = PDDateHelper.dateBeforeOvernight(overnightDate: expDate) {
            content.title = usingPatches ? PDStrings.NotificationStrings.Titles.overnight_patch : PDStrings.NotificationStrings.Titles.overnight_injection
            content.sound = UNNotificationSound.default()
            content.badge = ScheduleController.totalDue(intervalStr: intervalStr) + 1 as NSNumber
            content.categoryIdentifier = estroCategoryID
            let interval = triggerDate.timeIntervalSinceNow
            if interval > 0 {
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
                let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
                center.add(request) { (error: Error?) in
                    if error != nil {
                        print("Unable to Add Notification Request (\(String(describing: error)), \(String(describing: error?.localizedDescription)))")
                    }
                }
            }
        }
    }
    
    internal func requestNotifyTakePill(_ pill: MOPill) {
        let now = Date()
        
        if let id = pill.getID(), let dueDate = pill.getDueDate(), now < dueDate {
            let content = UNMutableNotificationContent()
            content.title = PDStrings.NotificationStrings.Titles.takePill
            if let name = pill.getName() {
                content.title += name
            }
            content.sound = UNNotificationSound.default()
            content.badge = ScheduleController.totalDue(intervalStr: UserDefaultsController.getTimeIntervalString()) + 1 as NSNumber
            content.categoryIdentifier = pillCategoryID
            let interval = dueDate.timeIntervalSince(now)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
            center.add(request) { (error : Error?) in
                if error != nil {
                    print("Unable to Add Notification Request (\(String(describing: error)), \(String(describing: error?.localizedDescription)))")
                }
            }
        }
    }
    
    internal func cancelEstrogenNotification(at index: Index) {
        let estro = ScheduleController.estrogenController.getEstrogenMO(at: index)
        if let id = estro.getID() {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        }
    }
    
    internal func cancelPill(_ pill: MOPill) {
        if let id = pill.getID() {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        }
    }
    
    // MARK: - Private helpers
    
    private func makeChangeAction() -> UNNotificationAction {
        return UNNotificationAction(identifier: estroActionID, title: PDStrings.NotificationStrings.actionMessages.autofill, options: [])
    }
    
    private func makeEstrogenCategory() -> UNNotificationCategory {
        let changeAction = makeChangeAction()
        return UNNotificationCategory(identifier: estroCategoryID, actions: [changeAction], intentIdentifiers: [], options: [])
    }
    
    private func makeTakeAction() -> UNNotificationAction {
        return UNNotificationAction(identifier: takeActionID,
                                    title: PDStrings.ActionStrings.take,
                                    options: [])
    }
    
    private func makeTakePillCategory() -> UNNotificationCategory {
        let takeAction = makeTakeAction()
        return UNNotificationCategory(identifier: pillCategoryID,
                                      actions: [takeAction],
                                      intentIdentifiers: [],
                                      options: [])
    }
    
    private func getNotificationCategories() -> [UNNotificationCategory] {
        return [makeTakePillCategory(), makeEstrogenCategory()]
    }
    
    
}
