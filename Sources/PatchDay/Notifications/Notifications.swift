//
//  Notifications.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/6/17.

import UIKit
import UserNotifications
import PDKit

class Notifications: NSObject, NotificationScheduling {

    private let sdk: PatchDataSDK
    private let center: NotificationCenterDelegate
    private let factory: NotificationProducing
    private let hormoneLogType = "Expired Hormone"
    private let pillLogType = "Due Pill"
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
        cancelHormoneNotifications([id])
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
            cancelHormoneNotifications(ids)
        }
    }

    /// Request a hormone notification.
    func requestExpiredHormoneNotification(for hormone: Hormonal) {
        guard sdk.settings.notifications.value else { return }
        cancelExpiredHormoneNotification(for: hormone)
        requestHormoneNotification(hormone)
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
            requestHormoneNotification(hormone)
        }
    }

    // MARK: - Pills

    /// Request a pill notification.
    func requestDuePillNotification(_ pill: Swallowable) {
        guard pillsEnabled else { return }
        guard pill.notify else { return }
        cancelDuePillNotification(pill)
        requestPillNotification(pill)
    }

    /// Requests notifications for all pills in the schedule.
    func requestAllDuePillNotifications() {
        guard pillsEnabled else { return }
        for pill in sdk.pills.all {
            requestDuePillNotification(pill)
        }
    }

    /// Cancels a pill notification.
    func cancelDuePillNotification(_ pill: Swallowable) {
        cancelPillNotifications([pill.id.uuidString])
    }

    /// Cancels all notifications for all pills.
    func cancelAllDuePillNotifications() {
        let ids = sdk.pills.all.map { $0.id.uuidString }
        cancelPillNotifications(ids)
    }

    // MARK: - Other

    /// Request a hormone notification that occurs when it's due overnight.
    func requestOvernightExpirationNotification(for hormone: Hormonal) {
        guard hormone.expiresOvernight else { return }
        requestOvernightHormoneNotification(hormone)
    }

    private var pillsEnabled: Bool {
        sdk.settings.pillsEnabled.rawValue
    }

    // MARK: - Private Request

    private func requestHormoneNotification(_ hormone: Hormonal) {
        factory.createExpiredHormoneNotification(hormone: hormone).request()
        logRequest(hormoneLogType)
    }

    private func requestOvernightHormoneNotification(_ hormone: Hormonal) {
        guard let expiration = hormone.expiration else { return }
        guard let notificationTime = DateFactory.createDateBeforeAtEightPM(of: expiration) else {
            return
        }
        factory.createOvernightExpiredHormoneNotification(date: notificationTime).request()
        logRequest("Overnight")
    }

    private func requestPillNotification(_ pill: Swallowable) {
        factory.createDuePillNotification(pill).request()
        logRequest(pillLogType)
    }

    // MARK: - Private Cancelation

    private func cancelHormoneNotifications(_ hormoneIds: [String]) {
        center.removeNotifications(with: hormoneIds)
        logCancel(hormoneLogType)
    }

    private func cancelPillNotifications(_ pillIds: [String]) {
        center.removeNotifications(with: pillIds)
        logCancel(pillLogType)
    }

    private func logRequest(_ message: String) {
        log.info("NOTIFICATION REQUESTED - \(message)")
    }

    private func logCancel(_ message: String) {
        log.info("NOTIFICATION CANCELED - \(message)")
    }
}
