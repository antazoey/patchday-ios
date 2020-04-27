//
//  Notifications.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/6/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import UserNotifications
import PDKit


class Notifications: NSObject, NotificationScheduling {

	private let sdk: PatchDataSDK
	private let center: NotificationCenterDelegate
	private let factory: NotificationProducing

	init(sdk: PatchDataSDK, center: NotificationCenterDelegate, factory: NotificationProducing) {
		self.sdk = sdk
		self.center = center
		self.factory = factory
		super.init()
	}

	convenience init(sdk: PatchDataSDK, appBadge: PDBadgeDelegate) {
		let center = PDNotificationCenter(
			root: UNUserNotificationCenter.current(),
			applyHormoneHandler: ApplyHormoneNotificationActionHandler(sdk: sdk),
			swallowPillNotificationActionHandler: SwallowPillNotificationActionHandler(sdk.pills, appBadge)
		)
		self.init(sdk: sdk, center: center, factory: NotificationFactory())
		center.swallowPillNotificationActionHandler.requestPillNotification = self.requestDuePillNotification
	}

	// MARK: - Hormones

	func removeNotifications(with ids: [String]) {
		center.removeNotifications(with: ids)
	}

	/// Request a hormone notification.
	func requestExpiredHormoneNotification(for hormone: Hormonal) {
        guard sdk.settings.notifications.value else { return }
        let params = ExpiredHormoneNotificationCreationParams(
            hormone,
            sdk.sites.suggested?.name,
            sdk.settings.expirationInterval,
            Double(sdk.settings.notificationsMinutesBefore.value),
            sdk.hormones.totalExpired
        )
        factory.createExpiredHormoneNotification(params).request()
	}

	/// Cancels the hormone notification at the given index.
	func cancelExpiredHormoneNotification(at index: Index) {
		guard let hormone = sdk.hormones[index] else { return }
		cancelExpiredHormoneNotification(for: hormone)
	}
    
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

	/// Requests all the hormone notifications between the given indices.
	func requestRangeOfExpiredHormoneNotifications(from begin: Index = 0, to end: Index = -1) {
        let endIndex = end >= 0 ? end : sdk.hormones.count - 1
        if endIndex < begin { return }
        for i in begin...endIndex {
            guard let hormone = sdk.hormones[i] else { break }
            let id = hormone.id.uuidString
            center.removeNotifications(with: [id])
            requestExpiredHormoneNotification(for: hormone)
        }
	}

	func requestAllExpiredHormoneNotifications() {
		let end = sdk.settings.quantity.rawValue - 1
		requestRangeOfExpiredHormoneNotifications(from: 0, to: end)
	}

	// MARK: - Pills

	/// Request a pill notification from index.
	func requestDuePillNotification(forPillAt index: Index) {
        guard let pill = sdk.pills[index] else { return }
        requestDuePillNotification(pill)
	}

	/// Request a pill notification.
	func requestDuePillNotification(_ pill: Swallowable) {
        guard let dueDate = pill.due, Date() < dueDate else { return }
        let totalDue = sdk.totalAlerts
        factory.createDuePillNotification(pill, totalDue: totalDue).request()
	}

	/// Cancels a pill notification.
	func cancelDuePillNotification(_ pill: Swallowable) {
		center.removeNotifications(with: [pill.id.uuidString])
	}

	/// Request a hormone notification that occurs when it's due overnight.
	func requestOvernightExpirationNotification(for hormone: Hormonal) {
        guard let expiration = hormone.expiration else { return }
        guard let notificationTime = DateFactory.createDateBeforeAtEightPM(of: expiration) else { return }
        let method = sdk.settings.deliveryMethod.value
        let totalExpired = sdk.hormones.totalExpired
        let params = ExpiredHormoneOvernightNotificationCreationParams(notificationTime, method, totalExpired)
        factory.createOvernightExpiredHormoneNotification(params).request()
	}
}
