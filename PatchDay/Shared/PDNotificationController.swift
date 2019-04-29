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
    
    typealias Trigger = UNTimeIntervalNotificationTrigger
    typealias Center = UNUserNotificationCenter

    internal var currentEstrogenIndex = 0
    internal var currentPillIndex = 0
    internal var sendingNotifications = true
    
    private var estroActionId = { return "estroActionId" }()
    private var takeActionId = { return "takeActionId" }()
    private var estroCategoryId = { return "estroCategoryId" }()
    private var pillCategoryId = { return "pillCategoryId" }()
    
    override init() {
        super.init()
        let curr = Center.current()
        curr.requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            if (error != nil) {
                print(error as Any)
            }
        }
        curr.setNotificationCategories(Set(getNotificationCategories()))
        curr.delegate = self
    }
    
    /// Resends all the estrogen notifications between the given indices.
    public func resendEstrogenNotifications(upToRemove: Int, upToAdd: Int) {
        cancelEstrogenNotifications(from: 0, to: upToRemove)
        for j in 0...upToAdd {
            if let estro = patchData.estrogenSchedule.getEstrogen(at: j) {
                requestEstrogenExpiredNotification(for: estro)
            }
        }
    }
    
    /// Resends all the estrogen notifications.
    public func resendAllEstrogenNotifications() {
        let i = patchData.defaults.quantity.value.rawValue
        resendEstrogenNotifications(upToRemove: i, upToAdd: i)
    }
    
    /// Resends the pill notification for the given pill.
    public func resendPillNotification(for pill: MOPill) {
        cancelPill(pill)
        requestNotifyTakePill(pill)
    }
    
    /// Determines the proper message for expired notifications.
    public func notificationBody(for estro: MOEstrogen, interval: ExpirationInterval) -> String {
        var body = ""
        typealias Bodies = PDStrings.NotificationStrings.Bodies
        let deliv = patchData.defaults.deliveryMethod.value
        let siteName = estro.getSiteName()
        if !estro.isCustomLocated(deliveryMethod: deliv),
            let msg = Bodies.siteToExpiredPatchMessage[siteName] {
                body = msg
        } else {
            switch deliv {
            case .Patches:
                body = Bodies.patchBody
            case .Injections:
                body = Bodies.injectionBody
            }
            body = body + siteName
        }
        return body
    }
    
    /// Handles responses received from interacting with notifications.
    internal func userNotificationCenter(_ center: Center,
                                         didReceive response: UNNotificationResponse,
                                         withCompletionHandler completionHandler: @escaping () -> Void) {
        let set = patchData.defaults.setSiteIndex
        switch response.actionIdentifier {
        case estroActionId :
            if let id = UUID(uuidString: response.notification.request.identifier),
            let suggestedsite = patchData.siteSchedule.suggest(changeIndex: set) {
                let now = Date() as NSDate
                let setter = patchData.schedule.setEstrogenDataForToday
                patchData.estrogenSchedule.setEstrogen(for: id, date: now,
                                                site: suggestedsite,
                                                setSharedData: setter)
                UIApplication.shared.applicationIconBadgeNumber -= 1
            }
        case takeActionId :
            if let uuid = UUID(uuidString: response.notification.request.identifier),
                let pill = patchData.pillSchedule.getPill(for: uuid) {
                let setter = patchData.pdSharedData.setPillDataForToday
                patchData.pillSchedule.take(pill,setPDSharedData: setter)
                requestNotifyTakePill(pill)
                UIApplication.shared.applicationIconBadgeNumber -= 1
            }
        default : return
        }
    }

    /// Cancels the notification at the given index.
    internal func cancelEstrogenNotification(at index: Index) {
        if let estro = patchData.estrogenSchedule.getEstrogen(at: index),
            let id = estro.getId() {
            let idStr = id.uuidString
            let center = Center.current()
            center.removePendingNotificationRequests(withIdentifiers: [idStr])
        }
    }
    
    /// Cancels all the estrogen notifications in the given indices.
    internal func cancelEstrogenNotifications(from startIndex: Index,
                                              to endIndex: Index) {
        var ids: [String] = []
        for i in startIndex...endIndex {
            if let estro = patchData.estrogenSchedule.getEstrogen(at: i),
                let id = estro.getId() {
                ids.append(id.uuidString)
            }
        }
        if ids.count > 0 {
            let current = Center.current()
            current.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
    
    /// Cancels all the estrogen notifications.
    internal func cancelAllEstrogenNotifications() {
        let end = patchData.defaults.quantity.value.rawValue - 1
        cancelEstrogenNotifications(from: 0, to: end)
    }
    
    /// Cancels a pill notification.
    internal func cancelPill(_ pill: MOPill) {
        let center = Center.current()
        if let id = pill.getId() {
            let idStr = id.uuidString
            center.removePendingNotificationRequests(withIdentifiers: [idStr])
        }
    }

    // MARK: - notifications
    
    /// Request an Estrogen notification.
    internal func requestEstrogenExpiredNotification(for estro: MOEstrogen) {
        let deliv = patchData.defaults.deliveryMethod.value
        let interval = patchData.defaults.expirationInterval
        let notify = patchData.defaults.notifications.value
        let notifyTime = Double(patchData.defaults.notificationsMinutesBefore.value)

        if sendingNotifications, notify, let date = estro.getDate(),
            var timeIntervalUntilExpire = PDDateHelper.expirationInterval(interval.hours, date: date as Date) {
            let content = UNMutableNotificationContent()
            content.title = determineEstrogenNotificationTitle(deliveryMethod: deliv, notifyTime: notifyTime)
            content.body = determineEstrogenNotificationBody(for: estro, interval: interval.value)
            content.sound = UNNotificationSound.default
            content.badge = patchData.schedule.totalDue(interval: interval) + 1 as NSNumber
            content.categoryIdentifier = estroCategoryId
            timeIntervalUntilExpire = timeIntervalUntilExpire - (notifyTime * 60.0)
            if timeIntervalUntilExpire > 0, let id = estro.getId() {
                let trigger = Trigger(timeInterval: timeIntervalUntilExpire,
                                                                repeats: false)
                let request = UNNotificationRequest(identifier: id.uuidString,
                                                    content: content,
                                                    trigger: trigger)
                let curr = Center.current()
                curr.add(request) {
                    (error : Error?) in
                    if error != nil {
                        let msg = "Unable to Add Notification Request "
                        let emsg = "(\(String(describing: error)), "
                        let desc = "\(String(describing: error?.localizedDescription)))"
                        print(msg + emsg + desc)
                    }
                }
            }
        }
    }
    
    /// Request an Estrogen notification that occurs when it's due overnight.
    internal func requestOvernightNotification(_ estro: MOEstrogen, expDate: Date) {
        let deliv = patchData.defaults.deliveryMethod.value
        let content = UNMutableNotificationContent()
        typealias Strings = PDStrings.NotificationStrings
        if let triggerDate = PDDateHelper.dateBefore(overNightDate: expDate) {
            switch deliv {
            case .Patches:
                content.title = Strings.Titles.overnight_patch
            case .Injections:
                content.title = Strings.Titles.overnight_injection
            }
            content.sound = UNNotificationSound.default
            let interval = triggerDate.timeIntervalSinceNow
            if interval > 0 {
                let trigger = Trigger(timeInterval: interval, repeats: false)
                let request = UNNotificationRequest(identifier: "overnight",
                                                    content: content,
                                                    trigger: trigger)
                let curr = Center.current()
                curr.add(request) { (error: Error?) in
                    if error != nil {
                        let msg = "Unable to Add Notification Request"
                        let e = "(\(String(describing: error)), "
                        let desc = "\(String(describing: error?.localizedDescription)))"
                        print(msg + e + desc)
                    }
                }
            }
        }
    }
    
    /// Request a pill notification from index.
    internal func requestNotifyTakePill(at index: Index) {
        if let pill = patchData.pillSchedule.getPill(at: index) {
            requestNotifyTakePill(pill)
        }
    }
    
    /// Request a pill notification.
    internal func requestNotifyTakePill(_ pill: MOPill) {
        let now = Date()
        if let dueDate = pill.due(), now < dueDate {
            let content = UNMutableNotificationContent()
            let timeInterval = patchData.defaults.expirationInterval
            let totalDue = patchData.schedule.totalDue(interval: timeInterval)
            content.title = PDStrings.NotificationStrings.Titles.takePill
            if let name = pill.getName() {
                content.title += name
            }
            content.sound = UNNotificationSound.default
            content.badge = totalDue + 1 as NSNumber
            content.categoryIdentifier = pillCategoryId
            let interval = dueDate.timeIntervalSince(now)
            let trigger = Trigger(timeInterval: interval, repeats: false)
            if let id = pill.getId() {
                let request = UNNotificationRequest(identifier: id.uuidString,
                                                    content: content,
                                                    trigger: trigger)
                let curr = Center.current()
                curr.add(request) { (error : Error?) in
                    if let e = error {
                        let msg = "Unable to Add Notification Request "
                        let emsg = "(\(String(describing: e)), "
                        let desc = "\(String(describing: e.localizedDescription)))"
                        print(msg + emsg + desc)
                    }
                }
            }
        }
    }
    
    // MARK: - Private helpers
    
    /// Returns the title for an estrogen notification.
    private func determineEstrogenNotificationTitle(deliveryMethod: DeliveryMethod, notifyTime: Double) -> String {
        var options: [String]
        switch deliveryMethod {
        case .Patches:
            options = [PDStrings.NotificationStrings.Titles.patchExpired,
                       PDStrings.NotificationStrings.Titles.patchExpires]
        case .Injections:
            options = [PDStrings.NotificationStrings.Titles.injectionExpired,
                        PDStrings.NotificationStrings.Titles.injectionExpires]
        }
        return (notifyTime == 0) ? options[0] : options[1]
    }
    
    /// Returns the body for an estrogen notification.
    private func determineEstrogenNotificationBody(for estro: MOEstrogen, interval: ExpirationInterval) -> String {
        var body = notificationBody(for: estro, interval: interval)
        typealias Bodies = PDStrings.NotificationStrings.Bodies
        let deliv = patchData.defaults.deliveryMethod.value
        var msg: String
        switch deliv {
        case .Patches:
            msg = Bodies.siteForNextPatch
        case .Injections:
            msg = Bodies.siteForNextInjection
        }
        if let additionalMessage = suggestSiteMessage(introMsg: msg) {
            body += additionalMessage
        }
        return body
    }
    
    private func suggestSiteMessage(introMsg: String) -> String? {
        let set = patchData.defaults.setSiteIndex
        if let suggestedSite = patchData.siteSchedule.suggest(changeIndex: set),
            let siteName = suggestedSite.getName() {
            return "\n" + introMsg + siteName
        }
        return nil
    }
    
    /// Create action for changing Estrogen from the notification.
    private func makeChangeAction() -> UNNotificationAction {
        return UNNotificationAction(identifier: estroActionId,
                                    title: PDStrings.NotificationStrings.actionMessages.autofill,
                                    options: [])
    }
    
    /// Create the category for Estrogen notifications.
    private func makeEstrogenCategory() -> UNNotificationCategory {
        let changeAction = makeChangeAction()
        return UNNotificationCategory(identifier: estroCategoryId,
                                      actions: [changeAction],
                                      intentIdentifiers: [],
                                      options: [])
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
