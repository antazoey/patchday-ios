//
//  NotificationController.swift
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
    private var pillActionID = { return "pillActionID" }()
    private var estroCategoryID = { return "estroCategoryID" }()
    private var pillCategoryID = { return "pillCategoryID"}()
    
    override init() {
        super.init()
        self.center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            print(error ?? "ERROR")
        }
        UNUserNotificationCenter.current().delegate = self
    }
    
    // Handles responses received from interacting with notifications.
    internal func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.actionIdentifier == estroActionID,
            let uuid = UUID(uuidString: response.notification.request.identifier),
            let suggestedSiteStr = suggestSite(),
            let suggestedSite = ScheduleController.siteController.getSite(for: suggestedSiteStr) {
            ScheduleController.estrogenController.setEstrogenMO(for: uuid, date: Date() as NSDate, site: suggestedSite)
            UIApplication.shared.applicationIconBadgeNumber -= 1
            }
    }

    // MARK: - notifications
    
    /****************************************************
     requestNotifiyExpired(mode) : For expired patches or injection.
     ****************************************************/
    
    private func determineEstrogenNotificationTitle(usingPatches: Bool, notifyTime: Double) -> String {
        let options = (usingPatches) ? [PDStrings.NotificationStrings.Titles.patchExpired, PDStrings.NotificationStrings.Titles.patchExpires] :
            [PDStrings.NotificationStrings.Titles.injectionExpired, PDStrings.NotificationStrings.Titles.injectionExpires]
        return (notifyTime == 0) ? options[0] : options[1]
    }
    
    private func determineEstrogenNotificationBody(for estro: MOEstrogen, intervalStr: String) -> String {
        var body = estro.notificationMessage(intervalStr: intervalStr)
        let msg = (UserDefaultsController.usingPatches()) ? PDStrings.NotificationStrings.Bodies.siteForNextPatch : PDStrings.NotificationStrings.Bodies.siteForNextInjection
        if let additionalMessage = suggestSiteMessage(msg: msg) {
            body += additionalMessage
        }
        return body
    }
    
    private func makeChangeAction() -> UNNotificationAction {
        return UNNotificationAction(identifier: estroActionID, title: PDStrings.NotificationStrings.actionMessages.autofill, options: [])
    }
    
    private func makePillCategory(withActions actions: [UNNotificationAction]) -> UNNotificationCategory {
        return UNNotificationCategory(identifier: estroCategoryID, actions: actions, intentIdentifiers: [], options: [])
    }
    
    internal func requestEstrogenExpiredNotification(for estro: MOEstrogen) {
        let intervalStr = UserDefaultsController.getTimeIntervalString()
        let usingPatches = UserDefaultsController.usingPatches()
        let notifyTime = UserDefaultsController.getNotificationTimeDouble()
        if sendingNotifications,
            UserDefaultsController.getRemindMeUpon(),
            let date = estro.getDate(),
            var timeIntervalUntilExpire = PDDateHelper.expirationInterval(intervalStr, date: date as Date) {
            let content = UNMutableNotificationContent()
            content.title = determineEstrogenNotificationTitle(usingPatches: usingPatches, notifyTime: notifyTime)
            content.body = determineEstrogenNotificationBody(for: estro, intervalStr: intervalStr)
            content.sound = UNNotificationSound.default()
            content.badge = ScheduleController.totalEstrogenAndPillsDue() + 1 as NSNumber
            content.categoryIdentifier = estroCategoryID
            
            let changeAction = makeChangeAction()
            let pillCategory = makePillCategory(withActions: [changeAction])
            center.setNotificationCategories([pillCategory])
            
            timeIntervalUntilExpire = timeIntervalUntilExpire - (notifyTime * 60.0)
            if timeIntervalUntilExpire > 0, let id = estro.getID() {
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
    
    /****************************************************
    requestNotifiyTakePill(mode) : Where mode = 0 means TB,
                                   mode = 1 means PG.
    ****************************************************/
    internal func requestNotifyTakePill(_ pill: MOPill) {
        
        let content = UNMutableNotificationContent()
        content.title = PDStrings.NotificationStrings.Titles.takePill
        content.sound = UNNotificationSound.default()
        content.badge = ScheduleController.totalEstrogenAndPillsDue() + 1 as NSNumber
        
        // Take Action
        if let name = pill.getName() {
            let actionID = name + ":" + pillActionID
            let takeAction = UNNotificationAction(identifier: actionID,
                                                  title: PDStrings.ActionStrings.take,
                                                  options: [])
            let takeCategory = UNNotificationCategory(identifier: pillCategoryID,
                                                      actions: [takeAction],
                                                      intentIdentifiers: [],
                                                      options: [])
            center.setNotificationCategories([takeCategory])
            content.categoryIdentifier = pillCategoryID
        }
        let now = Date()
        if let dueDate = pill.getDueDate(), now < dueDate {
            content.body = PDDateHelper.format(time: dueDate)
            let interval = dueDate.timeIntervalSince(now)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let request = UNNotificationRequest(identifier: "PILLID", content: content, trigger: trigger)
            center.add(request) { (error : Error?) in
                if error != nil {
                    print("Unable to Add Notification Request (\(String(describing: error)), \(String(describing: error?.localizedDescription)))")
                }
            }
        }
    }
    
    internal func cancelEstrogenNotification(at index: Index) {
        if let estro = ScheduleController.estrogenController.getEstrogenMO(at: index), let id = estro.getID() {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        }
    }
    
    internal func cancelPills(identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // MARK: - Private helpers
    
    private func suggestSite() -> String? {
        let scheduleSites: [String] = ScheduleController.siteSchedule(sites: ScheduleController.siteController.siteArray).siteNamesArray
        let currentSites: [String] = ScheduleController.estrogenSchedule(estrogens: ScheduleController.estrogenController.estrogenArray).currentSiteNames
        let estroSiteName = (currentEstrogenIndex >= 0 && currentEstrogenIndex < currentSites.count) ? currentSites[currentEstrogenIndex] : PDStrings.PlaceholderStrings.new_site
        let estroCount: Int = UserDefaultsController.getQuantityInt()
        if let suggestSiteIndex = SiteSuggester.suggest(currentEstrogenSiteSuggestingFrom: estroSiteName, currentSites: currentSites, estrogenQuantity: estroCount, scheduleSites: scheduleSites), suggestSiteIndex >= 0 && suggestSiteIndex < scheduleSites.count {
            return scheduleSites[suggestSiteIndex]
        }
        return nil
    }
    
    private func suggestSiteMessage(msg: String) -> String? {
        if let suggestedSiteName = suggestSite() {
            return "\n\n" + msg + suggestedSiteName
        }
        return nil
    }
    
}
