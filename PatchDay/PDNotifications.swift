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


class PDNotifications: NSObject, PDNotificationScheduling {


    private let sdk: PatchDataDelegate
    private let center: PDNotificationCenter

    var currentEstrogenIndex = 0
    var currentPillIndex = 0
    var sendingNotifications = true
    
    init(sdk: PatchDataDelegate, center: PDNotificationCenter) {
        self.sdk = sdk
        self.center = center
        super.init()
    }
    
    convenience override init() {
        let center = PDNotificationCenter(
            sdk: app.sdk,
            root: UNUserNotificationCenter.current()
        )
        self.init(sdk: app.sdk, center: center)
    }
    
    // MARK: - Hormones
    
    /// Request a hormone notification.
    func requestExpiredHormoneNotification(for hormone: Hormonal) {
        let deliv = sdk.deliveryMethod
        let interval = sdk.defaults.expirationInterval
        let notify = sdk.defaults.notifications.value
        let notifyMinBefore = Double(sdk.defaults.notificationsMinutesBefore.value)
        let totalExpired = sdk.totalHormonesExpired

        if sendingNotifications, notify {
            ExpiredHormoneNotification(
                for: hormone,
                deliveryMethod: deliv,
                expirationInterval: interval,
                notifyMinutesBefore: notifyMinBefore,
                totalDue: totalExpired
            ).request()
        }
    }

    /// Cancels the hormone notification at the given index.
    func cancelExpiredHormoneNotification(at index: Index) {
        if let mone = sdk.hormones.at(index) {
            let id = mone.id.uuidString
            center.removeNotifications(with: [id])
        }
    }

    func cancelAllExpiredHormoneNotifications() {
        let end = sdk.quantity.rawValue - 1
        cancelExpiredHormoneNotifications(from: 0, to: end)
    }
    
    /// Cancels all the hormone notifications in the given indices.
    func cancelExpiredHormoneNotifications(from begin: Index, to end: Index) {
        var ids: [String] = []
        for i in begin...end {
            appendHormoneIdToList(at: i, lst: &ids)
        }
        if ids.count > 0 {
            center.removeNotifications(with: ids)
        }
    }
    
    /// Resends all the hormone notifications between the given indices.
    func resendExpiredHormoneNotifications(from begin: Index = 0, to end: Index = -1) {
        let e = end >= 0 ? end : sdk.hormones.count - 1
        if e < begin { return }
        for i in begin...e {
            if let mone = sdk.hormones.at(i) {
                let id = mone.id.uuidString
                center.removeNotifications(with: [id])
                requestExpiredHormoneNotification(for: mone)
            }
        }
    }
    
    func resendAllExpiredExpiredNotifications() {
        let end = sdk.quantity.rawValue - 1
        resendExpiredHormoneNotifications(from: 0, to: end)
    }
    
    // MARK: - Pills
    
    /// Request a pill notification from index.
    func requestDueillNotification(forPillAt index: Index) {
        if let pill = sdk.pills.at(index) {
            requestDuePillNotification(pill)
        }
    }
    
    /// Request a pill notification.
    func requestDuePillNotification(_ pill: Swallowable) {
        if Date() < pill.due {
            let totalDue = sdk.totalAlerts
            DuePillNotification(
                for: pill,
                dueDate: pill.due,
                totalDue: totalDue
            ).request()
        }
    }
    
    /// Cancels a pill notification.
    func cancelDuePillNotification(_ pill: Swallowable) {
        center.removeNotifications(with: [pill.id.uuidString])
    }
    
    /// Request a hormone notification that occurs when it's due overnight.
    func requestOvernightExpirationNotification(_ hormone: Hormonal, expDate: Date) {
        if let triggerDate = PDDateHelper.dateBefore(overNightDate: expDate) {
            ExpiredHormoneOvernightNotification(
                triggerDate: triggerDate,
                deliveryMethod: sdk.deliveryMethod,
                totalDue: sdk.totalAlerts
            ).request()
        }
    }
    
    private func appendHormoneIdToList(at i: Index, lst: inout [String]) {
        if let mone = sdk.hormones.at(i) {
            let id = mone.id.uuidString
            lst.append(id)
        }
    }
}
