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


class PDNotificationSchedule: NSObject, PDNotificationScheduling {
    
    override var description: String {
        return "Singleton for handling user notifications."
    }
    
    private let sdk: PatchDataDelegate
    private let center: PDNotificationCenter

    var currentEstrogenIndex = 0
    var currentPillIndex = 0
    var sendingNotifications = true
    
    init(sdk: PatchDataDelegate, center: PDNotificationCenter) {
        self.sdk = sdk
        super.init()
    }
    
    convenience override init() {
        let center = PDNotificationCenter(sdk: app.sdk,
                                          root: UNUserNotificationCenter.current(),
                                          requestPillNotification: requestPillNotification)
        self.init(sdk: app.sdk, center: center)
    }

    /// Cancels the notification at the given index.
    func cancelEstrogenNotification(at index: Index) {
        if let mone = sdk.hormones.at(index) {
            let id = mone.id.uuidString
            center.removeNotifications(with: [id])
        }
    }
    
    /// Cancels all the estrogen notifications in the given indices.
    func cancelEstrogenNotifications(from start: Index, to end: Index) {
        var ids: [String] = []
        for i in start...end {
            appendEstrogenIdToList(at: i, lst: &ids)
        }
        if ids.count > 0 {
            center.removeNotifications(with: ids)
        }
    }
    
    private func appendEstrogenIdToList(at i: Index, lst: inout [String]) {
        if let mone = sdk.hormones.at(i) {
            let id = estro.id.uuidString
            lst.append(id)
        }
    }
    
    /// Cancels all the estrogen notifications.
    func cancel() {
        let end = sdk.defaults.quantity.value.rawValue - 1
        cancelEstrogenNotifications(from: 0, to: end)
    }
    
    /// Cancels a pill notification.
    func cancel(_ pill: Swallowable) {
        center.removeNotifications(with: [pill.id.uuidString])
    }

    // MARK: - notifications
    
    /// Request an Estrogen notification.
    func requestEstrogenExpiredNotification(for estrogen: Hormonal) {
        let deliv = sdk.deliveryMethod
        let interval = sdk.defaults.expirationInterval
        let notify = sdk.defaults.notifications.value
        let notifyMinBefore = Double(sdk.defaults.notificationsMinutesBefore.value)
        let totalExpired = sdk.totalEstrogensExpired

        if sendingNotifications, notify {
            ExpiredEstrogenNotification(for: estrogen,
                                        deliveryMethod: deliv,
                                        expirationInterval: interval,
                                        notifyMinutesBefore: notifyMinBefore,
                                        totalDue: totalExpired).request()
        }
    }
    
    /// Request an Estrogen notification that occurs when it's due overnight.
    func requestOvernightNotification(_ estro: Hormonal, expDate: Date) {
        if let triggerDate = PDDateHelper.dateBefore(overNightDate: expDate) {
            ExpiredEstrogenOvernightNotification(triggerDate: triggerDate,
                                          deliveryMethod: sdk.deliveryMethod,
                                          totalDue: sdk.totalDue)
                .request()
        }
    }
    
    /// Request a pill notification from index.
    func requestPillNotification(forPillAt index: Index) {
        if let pill = sdk.pills.at(index) {
            requestPillNotification(pill)
        }
    }
    
    /// Request a pill notification.
    func requestPillNotification(_ pill: Swallowable) {
        if Date() < pill.due {
            let totalDue = sdk.totalDue
            DuePillNotification(for: pill,
                                dueDate: pill.due,
                                totalDue: totalDue)
                .request()
        }
    }
    
    /// Resends all the estrogen notifications between the given indices.
    func resendEstrogenNotifications(begin: Index = 0, end: Index = -1) {
        let e = end >= 0 ? end : sdk.hormones.count - 1
        if e < begin { return }
        for i in begin...e {
            if let mone = sdk.hormones.at(i) {
                let id = estro.id.uuidString
                center.removeNotifications(with: [id])
                requestEstrogenExpiredNotification(for: estro)
            }
        }
    }

}
