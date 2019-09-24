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
//

class PDNotificationCenter: NSObject, UNUserNotificationCenterDelegate {
    
    override var description: String {
        return "Singleton for handling user notifications."
    }
    
    private let sdk: PatchDataDelegate

    var currentEstrogenIndex = 0
    var currentPillIndex = 0
    var sendingNotifications = true
    
    init(sdk: PatchDataDelegate) {
        self.sdk = sdk
        super.init()
    }
    
    convenience override init() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            if (error != nil) {
                print(error as Any)
            }
        }
        center.setNotificationCategories(getNotificationCategories())
        center.delegate = self
        self.init(sdk: app.sdk)
    }
    
    /// Handles responses received from interacting with notifications.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case EstrogenNotification.actionId :
            if let id = UUID(uuidString: response.notification.request.identifier),
                let suggestedsite = sdk.suggestedSite {
                let now = Date() as NSDate
                let setter = patchData.sdk.schedule.setEstrogenDataForToday
                patchData.sdk.estrogenSchedule.setEstrogen(for: id, date: now,
                                                       site: suggestedsite,
                                                       setSharedData: setter)
                UIApplication.shared.applicationIconBadgeNumber -= 1
            }
        case PillNotification.actionId :
            if let uuid = UUID(uuidString: response.notification.request.identifier),
                let pill = patchData.sdk.pillSchedule.getPill(for: uuid) {
                let setter = patchData.sdk.pdSharedData.setPillDataForToday
                pillSchedule.take(pill,setPDSharedData: setter)
                requestPillNotification(pill)
                UIApplication.shared.applicationIconBadgeNumber -= 1
            }
        default : return
        }
    }

    /// Cancels the notification at the given index.
    func cancelEstrogenNotification(at index: Index) {
        if let estro = sdk.estrogens.at(index),
            let center = UNUserNotificationCenter.current() {
            let id = estro.id.uuidString
            center.removePendingNotificationRequests(withIdentifiers: [id])
        }
    }
    
    /// Cancels all the estrogen notifications in the given indices.
    func cancelEstrogenNotifications(from start: Index, to end: Index) {
        var ids: [String] = []
        for i in start...end {
            appendEstrogenIdToList(at: i, lst: &ids)
        }
        if ids.count > 0 {
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
    
    private func appendEstrogenIdToList(at i: Index, inout lst: [String]) {
        if let estro = sdk.estrogens.at(i) {
            let id = estro.id.uuidString
            lst.append(id)
        }
    }
    
    /// Cancels all the estrogen notifications.
    func cancelEstrogenNotifications() {
        let end = sdk.defaults.quantity.value.rawValue - 1
        cancelEstrogenNotifications(from: 0, to: end)
    }
    
    /// Cancels a pill notification.
    func cancelPillNotification(_ pill: Swallowable) {
        let center = UNUserNotificationCenter.current()
        let id = pill.id.uuidString
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    // MARK: - notifications
    
    /// Request an Estrogen notification.
    func requestEstrogenExpiredNotification(for estrogen: MOEstrogen) {
        let deliv = sdk.deliveryMethod
        let interval = patchData.defaults.expirationInterval
        let notify = patchData.defaults.notifications.value
        let notifyMinBefore = Double(patchData.defaults.notificationsMinutesBefore.value)
        let totalExpired = patchData.schedule.totalDue(interval: interval)


        if sendingNotifications, notify {
            EstrogenNotification(for: estrogen,
                                 deliveryMethod: deliv,
                                 expirationInterval: interval,
                                 notifyMinutesBefore: notifyMinBefore,
                                 totalDue: totalExpired).request()
        }
    }
    
    /// Request an Estrogen notification that occurs when it's due overnight.
    func requestOvernightNotification(_ estro: MOEstrogen, expDate: Date) {
        let interval = patchData.defaults.expirationInterval
        if let triggerDate = PDDateHelper.dateBefore(overNightDate: expDate) {
            EstrogenOvernightNotification(triggerDate: triggerDate,
                                          deliveryMethod: patchData.defaults.deliveryMethod.value,
                                          totalDue: patchData.schedule.totalDue(interval: interval)).request()
        }
    }
    
    /// Request a pill notification from index.
    func requestPillNotification(forPillAt index: Index) {
        if let pill = patchData.pillSchedule.at(index) {
            requestPillNotification(pill)
        }
    }
    
    /// Request a pill notification.
    func requestPillNotification(_ pill: MOPill) {
        let now = Date()
        if let dueDate = pill.due(), now < dueDate {
            let timeInterval = patchData.defaults.expirationInterval
            let totalDue = patchData.schedule.totalDue(interval: timeInterval)
            PillNotification(for: pill, dueDate: dueDate, totalDue: totalDue).request()
        }
    }
    
    /// Resends all the estrogen notifications between the given indices.
    func resendEstrogenNotifications(begin: Index = 0, end: Index = -1) {
        let e = end >= 0 ? end : sdk.estrogens.count() - 1
        if e < begin { return }
        for i in begin...e {
            if let estro = sdk.estrogens.at(i),
                let idStr = estro.id?.uuidString {
                let center = UNUserNotificationCenter.current()
                center.removePendingNotificationRequests(withIdentifiers: [idStr])
                requestEstrogenExpiredNotification(for: estro)
            }
        }
    }
    
    // MARK: - Private helpers
    
    private func getNotificationCategories() -> Set<UNNotificationCategory> {
        let estrogenAction = UNNotificationAction(identifier: EstrogenNotification.actionId,
                                                  title: PDActionStrings.autofill,
                                                  options: [])
        let estrogenCategory = UNNotificationCategory(identifier: EstrogenNotification.actionId,
                                                      actions: [estrogenAction],
                                                      intentIdentifiers: [],
                                                      options: [])
        let pillAction = UNNotificationAction(identifier: PillNotification.actionId,
                                                  title: PDActionStrings.take,
                                                  options: [])
        let pillCategory = UNNotificationCategory(identifier: PillNotification.categoryId,
                                                  actions: [pillAction],
                                                  intentIdentifiers: [],
                                                  options: [])
        return Set([estrogenCategory, pillCategory])
    }
}
