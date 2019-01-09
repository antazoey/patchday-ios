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
import PatchData

internal class PDNotificationController: NSObject, UNUserNotificationCenterDelegate {
    
    override var description: String {
        return "Singleton for reading, writing, and querying the MOEstrogen array."
    }
    
    internal var center = UNUserNotificationCenter.current()
    internal var currentEstrogenIndex = 0
    internal var currentPillIndex = 0
    internal var sendingNotifications = true
    
    private var estroActionId = { return "estroActionId" }()
    private var takeActionId = { return "takeActionId" }()
    private var estroCategoryId = { return "estroCategoryId" }()
    private var pillCategoryId = { return "pillCategoryId" }()
    
    override init() {
        super.init()
        self.center.requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            if (error != nil) {
                print(error as Any)
            }
        }
        center.setNotificationCategories(Set(getNotificationCategories()))
        UNUserNotificationCenter.current().delegate = self
    }
    
    /// Handles responses received from interacting with notifications.
    internal func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let set = Defaults.setSiteIndex
        if response.actionIdentifier == estroActionId,
            let id = UUID(uuidString: response.notification.request.identifier),
            let suggestedsite = SiteSchedule.suggest(changeIndex: set) {
            let now = Date() as NSDate
            let setter = Schedule.setEstrogenDataForToday
            EstrogenSchedule.setEstrogen(for: id, date: now,
                                         site: suggestedsite,
                                         setSharedData: setter)
            UIApplication.shared.applicationIconBadgeNumber -= 1
        } else if response.actionIdentifier == takeActionId,
            let uuid = UUID(uuidString: response.notification.request.identifier),
            let pill = PillSchedule.getPill(for: uuid) {
            PillSchedule.take(pill, setPDSharedData: PDSharedData.setPillDataForToday)
            requestNotifyTakePill(pill)
            UIApplication.shared.applicationIconBadgeNumber -= 1
        }
    }
    
    /// Resends all the estrogen notifications between the given indices.
    public func resendEstrogenNotifications(upToRemove: Int, upToAdd: Int) {
        cancelEstrogenNotifications(from: 0, to: upToRemove)
        for j in 0...upToAdd {
            if let estro = EstrogenSchedule.getEstrogen(at: j) {
                requestEstrogenExpiredNotification(for: estro)
            }
        }
    }
    
    /// Resends all the estrogen notifications.
    public func resendAllEstrogenNotifications() {
        let i = Defaults.getQuantity()
        resendEstrogenNotifications(upToRemove: i, upToAdd: i)
    }
    
    /// Resends the pill notification for the given pill.
    public func resendPillNotification(for pill: MOPill) {
        cancelPill(pill)
        requestNotifyTakePill(pill)
    }
    
    /// Cancels the notification at the given index.
    internal func cancelEstrogenNotification(at index: Index) {
        if let estro = EstrogenSchedule.getEstrogen(at: index),
            let id = estro.getId() {
            let idStr = id.uuidString
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [idStr])
        }
    }
    
    /// Cancels all the estrogen notifications in the given indices.
    internal func cancelEstrogenNotifications(from startIndex: Index,
                                              to endIndex: Index) {
        var ids: [String] = []
        for i in startIndex...endIndex {
            if let estro = EstrogenSchedule.getEstrogen(at: i),
                let id = estro.getId() {
                ids.append(id.uuidString)
            }
        }
        if ids.count > 0 {
            let current = UNUserNotificationCenter.current()
            current.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
    
    /// Cancels all the estrogen notifications.
    internal func cancelAllEstrogenNotifications() {
        let end = Defaults.getQuantity() - 1
        cancelEstrogenNotifications(from: 0, to: end)
    }
    
    /// Cancels a pill notification.
    internal func cancelPill(_ pill: MOPill) {
        let center = UNUserNotificationCenter.current()
        if let id = pill.getId() {
            let idStr = id.uuidString
            center.removePendingNotificationRequests(withIdentifiers: [idStr])
        }
    }

    // MARK: - notifications
    
    /// Returns the title for an estrogen notification.
    private func determineEstrogenNotificationTitle(usingPatches: Bool,
                                                    notifyTime: Double) -> String {
        let options = (usingPatches) ? [PDStrings.NotificationStrings.Titles.patchExpired, PDStrings.NotificationStrings.Titles.patchExpires] :
            [PDStrings.NotificationStrings.Titles.injectionExpired, PDStrings.NotificationStrings.Titles.injectionExpires]
        return (notifyTime == 0) ? options[0] : options[1]
    }
    
    /// Returns the body for an estrogen notification.
    private func determineEstrogenNotificationBody(for estro: MOEstrogen,
                                                   interval: String) -> String {
        var body = notificationBody(for: estro, interval: interval)
        typealias Bodies = PDStrings.NotificationStrings.Bodies
        let msg = (Defaults.usingPatches()) ?
            Bodies.siteForNextPatch :
            Bodies.siteForNextInjection
        if let additionalMessage = suggestSiteMessage(introMsg: msg) {
            body += additionalMessage
        }
        return body
    }
    
    /// Determines the proper message for expired notifications.
    public func notificationBody(for estro: MOEstrogen, interval: String) -> String {
        var body = ""
        typealias Bodies = PDStrings.NotificationStrings.Bodies
        let usingPatches: Bool = Defaults.usingPatches()
        let siteName = estro.getSiteName()
        if !estro.isCustomLocated(usingPatches: usingPatches) && usingPatches {
            if let msg = Bodies.siteToExpiredPatchMessage[siteName] {
                body = msg
            }
        } else {
            body = (usingPatches) ? Bodies.patchBody : Bodies.injectionBody
            body = body + siteName
        }
        return body
    }
    
    private func suggestSiteMessage(introMsg: String) -> String? {
        let set = Defaults.setSiteIndex
        if let suggestedSite = SiteSchedule.suggest(changeIndex: set),
            let siteName = suggestedSite.getName() {
            return "\n" + introMsg + siteName
        }
        return nil
    }
    
    /// Request an Estrogen notification.
    internal func requestEstrogenExpiredNotification(for estro: MOEstrogen) {
        let interval = Defaults.getTimeInterval()
        let usingPatches = Defaults.usingPatches()
        let notifyTime = Double(Defaults.getNotificationMinutesBefore())
        
        if sendingNotifications,
            Defaults.notify(),
            let date = estro.getDate(),
            var timeIntervalUntilExpire = PDDateHelper.expirationInterval(interval,
                                                                          date: date as Date) {
            let content = UNMutableNotificationContent()
            
            content.title = determineEstrogenNotificationTitle(usingPatches: usingPatches,
                                                               notifyTime: notifyTime)
            content.body = determineEstrogenNotificationBody(for: estro, interval: interval)
            content.sound = UNNotificationSound.default()
            content.badge = Schedule.totalDue(interval: interval) + 1 as NSNumber
            content.categoryIdentifier = estroCategoryId
            
            timeIntervalUntilExpire = timeIntervalUntilExpire - (notifyTime * 60.0)
            if timeIntervalUntilExpire > 0, let id = estro.getId() {
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeIntervalUntilExpire,
                                                                repeats: false)
                let request = UNNotificationRequest(identifier: id.uuidString,
                                                    content: content,
                                                    trigger: trigger)
                center.add(request) {
                    (error : Error?) in
                    if error != nil {
                        print("Unable to Add Notification Request (\(String(describing: error))," +
                            "\(String(describing: error?.localizedDescription)))")
                    }
                }
            }
        }
    }
    
    /// Request an Estrogen notification that occurs when it's due overnight.
    internal func requestOvernightNotification(_ estro: MOEstrogen, expDate: Date) {
        let usingPatches = Defaults.usingPatches()
        let content = UNMutableNotificationContent()
        typealias Strings = PDStrings.NotificationStrings
        if let triggerDate = PDDateHelper.dateBeforeOvernight(overnightDate: expDate) {
            content.title = usingPatches ?
                Strings.Titles.overnight_patch :
                Strings.Titles.overnight_injection
            content.sound = UNNotificationSound.default()
            let interval = triggerDate.timeIntervalSinceNow
            if interval > 0 {
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval,
                                                                repeats: false)
                let request = UNNotificationRequest(identifier: "overnight",
                                                    content: content,
                                                    trigger: trigger)
                center.add(request) { (error: Error?) in
                    if error != nil {
                        print("Unable to Add Notification Request (\(String(describing: error))," +
                            "\(String(describing: error?.localizedDescription)))")
                    }
                }
            }
        }
    }
    
    /// Request a pill notification from index.
    internal func requestNotifyTakePill(at index: Index) {
        if let pill = PillSchedule.getPill(at: index) {
            requestNotifyTakePill(pill)
        }
    }
    
    /// Request a pill notification.
    internal func requestNotifyTakePill(_ pill: MOPill) {
        let now = Date()
        if let dueDate = pill.getDueDate(), now < dueDate {
            let content = UNMutableNotificationContent()
            let totalDue = Schedule.totalDue(interval: Defaults.getTimeInterval())
            content.title = PDStrings.NotificationStrings.Titles.takePill
            if let name = pill.getName() {
                content.title += name
            }
            content.sound = UNNotificationSound.default()
            content.badge = totalDue + 1 as NSNumber
            content.categoryIdentifier = pillCategoryId
            let interval = dueDate.timeIntervalSince(now)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval,
                                                            repeats: false)
            if let id = pill.getId() {
                let request = UNNotificationRequest(identifier: id.uuidString,
                                                    content: content,
                                                    trigger: trigger)
                center.add(request) { (error : Error?) in
                    if let e = error {
                        let desc = e.localizedDescription
                        print("Unable to Add Notification Request (\(String(describing: e))," +
                            "\(String(describing: desc)))")
                    }
                }
            }
        }
    }
    
    // MARK: - Private helpers
    
    /// Create action for changing Estrogen from the notification.
    private func makeChangeAction() -> UNNotificationAction {
        return UNNotificationAction(identifier: estroActionId, title: PDStrings.NotificationStrings.actionMessages.autofill, options: [])
    }
    
    /// Create the category for Estrogen notifications.
    private func makeEstrogenCategory() -> UNNotificationCategory {
        let changeAction = makeChangeAction()
        return UNNotificationCategory(identifier: estroCategoryId, actions: [changeAction],
                                      intentIdentifiers: [], options: [])
    }
    
    /// Create the action for taking a pill from the notification.
    private func makeTakeAction() -> UNNotificationAction {
        return UNNotificationAction(identifier: takeActionId,
                                    title: PDStrings.ActionStrings.take,
                                    options: [])
    }
    
    /// Create the category for Pill notifications.
    private func makeTakePillCategory() -> UNNotificationCategory {
        let takeAction = makeTakeAction()
        return UNNotificationCategory(identifier: pillCategoryId,
                                      actions: [takeAction],
                                      intentIdentifiers: [],
                                      options: [])
    }
    
    /// Return all PatchDay notification categories.
    private func getNotificationCategories() -> [UNNotificationCategory] {
        return [makeTakePillCategory(), makeEstrogenCategory()]
    }
}
