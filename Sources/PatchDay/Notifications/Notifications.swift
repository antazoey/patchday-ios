//
//  Notifications.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/6/17.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import UIKit
import UserNotifications
import PDKit

class Notifications: NSObject, NotificationScheduling {

    private let sdk: PatchDataSDK
    private let center: NotificationCenterDelegate
    private let factory: NotificationProducing
    private lazy var log = PDLog<Notifications>()

    init(
        sdk: PatchDataSDK,
        center: NotificationCenterDelegate,
        factory: NotificationProducing
    ) {
        self.sdk = sdk
        self.center = center
        self.factory = factory
        super.init()
    }

    convenience init(sdk: PatchDataSDK, appBadge: PDBadgeReflective) {
        let center = PDNotificationCenter(
            root: UNUserNotificationCenter.current(),
            handlePill: PillNotificationActionHandler(sdk.pills, appBadge)
        )
        let factory = NotificationFactory(sdk: sdk, badge: appBadge)
        self.init(
            sdk: sdk,
            center: center,
            factory: factory
        )
        center.pillActionHandler.requestPillNotification = self.requestDuePillNotification
    }

    // MARK: - Hormone

    func cancelExpiredHormoneNotification(for hormone: Hormonal) {
        let id = hormone.id.uuidString
        center.removeNotifications(with: [id])
    }

    func cancelAllExpiredHormoneNotifications() {
        let end = sdk.settings.quantity.rawValue - 1
        cancelRangeOfExpiredHormoneNotifications(from: 0, to: end)
    }

    /// Cancels all the hormone notifications in the given indices.
    func cancelRangeOfExpiredHormoneNotifications(from begin: Index, to end: Index) {
        guard begin < end else { return }
        var ids: [String] = []
        for i in begin...end {
            if let hormone = sdk.hormones[i] {
                ids.append(hormone.id.uuidString)
            }
        }
        if ids.count > 0 {
            center.removeNotifications(with: ids)
        }
    }

    /// Request a hormone notification.
    func requestExpiredHormoneNotification(for hormone: Hormonal) {
        guard sdk.settings.notifications.value else { return }
        cancelExpiredHormoneNotification(for: hormone)
        let notification = factory.createExpiredHormoneNotification(hormone: hormone)
        notification.request()
    }

    func requestAllExpiredHormoneNotifications() {
        let end = sdk.settings.quantity.rawValue - 1
        requestRangeOfExpiredHormoneNotifications(from: 0, to: end)
    }

    /// Requests all the hormone notifications between the given indices.
    func requestRangeOfExpiredHormoneNotifications(from begin: Index, to end: Index) {
        guard sdk.settings.notifications.value else { return }
        guard begin < end else { return }
        cancelRangeOfExpiredHormoneNotifications(from: begin, to: end)
        for i in begin...end {
            guard let hormone = sdk.hormones[i] else { break }
            factory.createExpiredHormoneNotification(hormone: hormone).request()
        }
    }

    // MARK: - Pills

    /// Request a pill notification.
    func requestDuePillNotification(_ pill: Swallowable) {
        guard pill.notify else { return }
        cancelDuePillNotification(pill)
        factory.createDuePillNotification(pill).request()
        log.info("Pill notification has been requested")
    }

    /// Cancels a pill notification.
    func cancelDuePillNotification(_ pill: Swallowable) {
        center.removeNotifications(with: [pill.id.uuidString])
    }

    /// Request a hormone notification that occurs when it's due overnight.
    func requestOvernightExpirationNotification(for hormone: Hormonal) {
        guard hormone.expiresOvernight else { return }
        guard let expiration = hormone.expiration else { return }
        guard let notificationTime = DateFactory.createDateBeforeAtEightPM(of: expiration) else {
            return
        }
        factory.createOvernightExpiredHormoneNotification(date: notificationTime).request()
    }
}
