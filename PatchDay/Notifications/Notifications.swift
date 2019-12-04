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


class Notifications: NSObject, NotificationScheduling {

    private let sdk: PatchDataDelegate?
    private let center: PDNotificationCenter
    private let factory: NotificationProducing

    var currentEstrogenIndex = 0
    var currentPillIndex = 0
    var sendingNotifications = true
    
    init(sdk: PatchDataDelegate?, center: PDNotificationCenter, factory: NotificationProducing) {
        self.sdk = sdk
        self.center = center
        self.factory = factory
        super.init()
    }
    
    convenience override init() {
        let center = PDNotificationCenter(
            root: UNUserNotificationCenter.current(),
            applyHormoneHandler: ApplyHormoneNotificationActionHandler(),
            swallowPillHandler: SwallowPillNotificationActionHandler()
        )
        self.init(sdk: app?.sdk, center: center, factory: NotificationFactory())
    }
    
    // MARK: - Hormones
    
    func removeNotifications(with ids: [String]) {
        center.removeNotifications(with: ids)
    }
    
    /// Request a hormone notification.
    func requestExpiredHormoneNotification(for hormone: Hormonal) {
        if let sdk = sdk {
            let method = sdk.defaults.deliveryMethod.value
            let interval = sdk.defaults.expirationInterval
            let notify = sdk.defaults.notifications.value
            let notifyMinBefore = Double(sdk.defaults.notificationsMinutesBefore.value)
            let totalExpired = sdk.hormones.totalExpired
            if sendingNotifications, notify {
                factory.createExpiredHormoneNotification(
                    hormone,
                    deliveryMethod: method,
                    expiration: interval,
                    notifyMinutesBefore: notifyMinBefore,
                    totalDue: totalExpired
                ).request()
            }
        }
    }

    /// Cancels the hormone notification at the given index.
    func cancelExpiredHormoneNotification(at index: Index) {
        if let hormone = sdk?.hormones.at(index) {
            cancelExpiredHormoneNotification(for: hormone)
        }
    }

    func cancelExpiredHormoneNotification(for hormone: Hormonal) {
        let id = hormone.id.uuidString
        center.removeNotifications(with: [id])
    }

    func cancelAllExpiredHormoneNotifications() {
        let end = (sdk?.defaults.quantity.rawValue ?? 1) - 1
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
        if let hormones = sdk?.hormones {
            let e = end >= 0 ? end : hormones.count - 1
            if e < begin { return }
            for i in begin...e {
                if let mone = hormones.at(i) {
                    let id = mone.id.uuidString
                    center.removeNotifications(with: [id])
                    requestExpiredHormoneNotification(for: mone)
                }
            }
        }
    }
    
    func resendAllExpiredHormoneNotifications() {
        let end = (sdk?.defaults.quantity.rawValue ?? 1) - 1
        resendExpiredHormoneNotifications(from: 0, to: end)
    }
    
    // MARK: - Pills
    
    /// Request a pill notification from index.
    func requestDuePillNotification(forPillAt index: Index) {
        if let pill = sdk?.pills.at(index) {
            requestDuePillNotification(pill)
        }
    }
    
    /// Request a pill notification.
    func requestDuePillNotification(_ pill: Swallowable) {
        if Date() < pill.due, let totalDue = sdk?.totalAlerts {
            factory.createDuePillNotification(pill, totalDue: totalDue).request()
        }
    }
    
    /// Cancels a pill notification.
    func cancelDuePillNotification(_ pill: Swallowable) {
        center.removeNotifications(with: [pill.id.uuidString])
    }
    
    /// Request a hormone notification that occurs when it's due overnight.
    func requestOvernightExpirationNotification(_ hormone: Hormonal) {
        if let sdk = sdk,
            let exp = hormone.expiration,
            let triggerDate = DateHelper.dateBefore(overNightDate: exp) {
            
            factory.createOvernightExpiredHormoneNotification(
                triggerDate: triggerDate,
                deliveryMethod: sdk.defaults.deliveryMethod.value,
                totalDue: sdk.totalAlerts
            ).request()
        }
    }
    
    private func appendHormoneIdToList(at i: Index, lst: inout [String]) {
        if let mone = sdk?.hormones.at(i) {
            let id = mone.id.uuidString
            lst.append(id)
        }
    }
}