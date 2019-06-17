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

class PDNotificationCenter: NSObject, UNUserNotificationCenterDelegate {
    
    override var description: String {
        return "Singleton for handling user notifications."
    }

    var currentEstrogenIndex = 0
    var currentPillIndex = 0
    var sendingNotifications = true
    
    override init() {
        super.init()
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            if (error != nil) {
                print(error as Any)
            }
        }
        center.setNotificationCategories(getNotificationCategories())
        center.delegate = self
    }
    
    /// Handles responses received from interacting with notifications.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let set = patchData.defaults.setSiteIndex
        switch response.actionIdentifier {
        case EstrogenNotification.actionId :
            if let id = UUID(uuidString: response.notification.request.identifier),
            let suggestedsite = patchData.siteSchedule.suggest(changeIndex: set) {
                let now = Date() as NSDate
                let setter = patchData.schedule.setEstrogenDataForToday
                patchData.estrogenSchedule.setEstrogen(for: id, date: now,
                                                site: suggestedsite,
                                                setSharedData: setter)
                UIApplication.shared.applicationIconBadgeNumber -= 1
            }
        case PillNotification.actionId :
            if let uuid = UUID(uuidString: response.notification.request.identifier),
                let pill = patchData.pillSchedule.getPill(for: uuid) {
                let setter = patchData.pdSharedData.setPillDataForToday
                patchData.pillSchedule.take(pill,setPDSharedData: setter)
                requestPillNotification(pill)
                UIApplication.shared.applicationIconBadgeNumber -= 1
            }
        default : return
        }
    }

    /// Cancels the notification at the given index.
    func cancelEstrogenNotification(at index: Index) {
        if let estro = patchData.estrogenSchedule.getEstrogen(at: index),
            let idStr = estro.getId()?.uuidString {
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [idStr])
        }
    }
    
    /// Cancels all the estrogen notifications in the given indices.
    func cancelEstrogenNotifications(from start: Index, to end: Index) {
        var ids: [String] = []
        for i in start...end {
            if let estro = patchData.estrogenSchedule.getEstrogen(at: i),
                let id = estro.getId() {
                ids.append(id.uuidString)
            }
        }
        if ids.count > 0 {
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
    
    /// Cancels all the estrogen notifications.
    func cancelEstrogenNotifications() {
        let end = patchData.defaults.quantity.value.rawValue - 1
        cancelEstrogenNotifications(from: 0, to: end)
    }
    
    /// Cancels a pill notification.
    func cancelPillNotification(_ pill: MOPill) {
        let center = UNUserNotificationCenter.current()
        if let id = pill.getId() {
            let idStr = id.uuidString
            center.removePendingNotificationRequests(withIdentifiers: [idStr])
        }
    }

    // MARK: - notifications
    
    /// Request an Estrogen notification.
    func requestEstrogenExpiredNotification(for estrogen: MOEstrogen) {
        let deliv = patchData.defaults.deliveryMethod.value
        let interval = patchData.defaults.expirationInterval
        let notify = patchData.defaults.notifications.value
        let notifyMinBefore = Double(patchData.defaults.notificationsMinutesBefore.value)
        let totalExpired = patchData.schedule.totalDue(interval: interval)


        if sendingNotifications, notify {
            EstrogenNotification(for: estrogen,
                                 deliveryMethod: deliv,
                                 expirationInterval: interval,
                                 notifyMinutesBefore: notifyMinBefore,
                                 totalDue: totalExpired).send()
        }
    }
    
    /// Request an Estrogen notification that occurs when it's due overnight.
    func requestOvernightNotification(_ estro: MOEstrogen, expDate: Date) {
        let interval = patchData.defaults.expirationInterval
        if let triggerDate = PDDateHelper.dateBefore(overNightDate: expDate) {
            EstrogenOvernightNotification(triggerDate: triggerDate,
                                          deliveryMethod: patchData.defaults.deliveryMethod.value,
                                          totalDue: patchData.schedule.totalDue(interval: interval)).send()
        }
    }
    
    /// Request a pill notification from index.
    func requestPillNotification(forPillAt index: Index) {
        if let pill = patchData.pillSchedule.getPill(at: index) {
            requestPillNotification(pill)
        }
    }
    
    /// Request a pill notification.
    func requestPillNotification(_ pill: MOPill) {
        let now = Date()
        if let dueDate = pill.due(), now < dueDate {
            let timeInterval = patchData.defaults.expirationInterval
            let totalDue = patchData.schedule.totalDue(interval: timeInterval)
            PillNotification(for: pill, dueDate: dueDate, totalDue: totalDue).send()
        }
    }
    
    /// Resends all the estrogen notifications between the given indices.
    func resendEstrogenNotifications(begin: Index = 0, end: Index = -1) {
        let e = end >= 0 ? end : patchData.estrogenSchedule.count() - 1
        if e < begin { return }
        for i in begin...e {
            if let estro = patchData.estrogenSchedule.getEstrogen(at: i),
                let idStr = estro.getId()?.uuidString {
                let center = UNUserNotificationCenter.current()
                center.removePendingNotificationRequests(withIdentifiers: [idStr])
                requestEstrogenExpiredNotification(for: estro)
            }
        }
    }
    
    // MARK: - Private helpers
    
    private func getNotificationCategories() -> Set<UNNotificationCategory> {
        let estrogenAction = UNNotificationAction(identifier: EstrogenNotification.actionId,
                                                  title: PDStrings.ActionStrings.autofill,
                                                  options: [])
        let estrogenCategory = UNNotificationCategory(identifier: EstrogenNotification.actionId,
                                                      actions: [estrogenAction],
                                                      intentIdentifiers: [],
                                                      options: [])
        let pillAction = UNNotificationAction(identifier: PillNotification.actionId,
                                                  title: PDStrings.ActionStrings.take,
                                                  options: [])
        let pillCategory = UNNotificationCategory(identifier: PillNotification.categoryId,
                                                  actions: [pillAction],
                                                  intentIdentifiers: [],
                                                  options: [])
        return Set([estrogenCategory, pillCategory])
    }
}
