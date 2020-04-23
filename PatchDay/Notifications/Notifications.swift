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

	private let sdk: PatchDataSDK?
	private let center: PDNotificationCenter
	private let factory: NotificationProducing

	var currentHormoneIndex = 0
	var currentPillIndex = 0
	var sendingNotifications = true

	init(sdk: PatchDataSDK?, center: PDNotificationCenter, factory: NotificationProducing) {
		self.sdk = sdk
		self.center = center
		self.factory = factory
		super.init()
	}

	convenience init(sdk: PatchDataSDK?, appBadge: PDBadgeDelegate) {
		let center = PDNotificationCenter(
			root: UNUserNotificationCenter.current(),
			applyHormoneHandler: ApplyHormoneNotificationActionHandler(sdk: sdk),
			swallowPillNotificationActionHandler: SwallowPillNotificationActionHandler(
				pills: sdk?.pills,
				appBadge: appBadge
			)
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
		if let sdk = sdk, sendingNotifications, sdk.settings.notifications.value,
			let siteId = hormone.siteId,
			let siteName = sdk.sites[siteId]?.name {
			let params = ExpiredHormoneNotificationCreationParams(
				hormone: hormone,
				expiringSiteName: siteName,
				suggestedSiteName: sdk.sites.suggested?.name,
				deliveryMethod: sdk.settings.deliveryMethod.value,
				expiration: sdk.settings.expirationInterval,
				notificationMinutesBefore: Double(sdk.settings.notificationsMinutesBefore.value),
				totalHormonesExpired: sdk.hormones.totalExpired
			)
			factory.createExpiredHormoneNotification(params).request()
		}
	}

	/// Cancels the hormone notification at the given index.
	func cancelExpiredHormoneNotification(at index: Index) {
		guard let hormone = sdk?.hormones[index] else { return }
		cancelExpiredHormoneNotification(for: hormone)
	}

	func cancelExpiredHormoneNotification(for hormone: Hormonal) {
		let id = hormone.id.uuidString
		center.removeNotifications(with: [id])
	}

	func cancelAllExpiredHormoneNotifications() {
		let end = (sdk?.settings.quantity.rawValue ?? 1) - 1
		cancelRangeOfExpiredHormoneNotifications(from: 0, to: end)
	}

	/// Cancels all the hormone notifications in the given indices.
	func cancelRangeOfExpiredHormoneNotifications(from begin: Index, to end: Index) {
		var ids: [String] = []
		for i in begin...end {
			appendHormoneIdToList(at: i, lst: &ids)
		}
		if ids.count > 0 {
			center.removeNotifications(with: ids)
		}
	}

	/// Requests all the hormone notifications between the given indices.
	func requestRangeOfExpiredHormoneNotifications(from begin: Index = 0, to end: Index = -1) {
		if let hormones = sdk?.hormones {
			let e = end >= 0 ? end : hormones.count - 1
			if e < begin { return }
			for i in begin...e {
				if let mone = hormones[i] {
					let id = mone.id.uuidString
					center.removeNotifications(with: [id])
					requestExpiredHormoneNotification(for: mone)
				}
			}
		}
	}

	func requestAllExpiredHormoneNotifications() {
		let end = (sdk?.settings.quantity.rawValue ?? 1) - 1
		requestRangeOfExpiredHormoneNotifications(from: 0, to: end)
	}

	// MARK: - Pills

	/// Request a pill notification from index.
	func requestDuePillNotification(forPillAt index: Index) {
		if let pill = sdk?.pills[index] {
			requestDuePillNotification(pill)
		}
	}

	/// Request a pill notification.
	func requestDuePillNotification(_ pill: Swallowable) {
		if let dueDate = pill.due, Date() < dueDate, let totalDue = sdk?.totalAlerts {
			factory.createDuePillNotification(pill, totalDue: totalDue).request()
		}
	}

	/// Cancels a pill notification.
	func cancelDuePillNotification(_ pill: Swallowable) {
		center.removeNotifications(with: [pill.id.uuidString])
	}

	/// Request a hormone notification that occurs when it's due overnight.
	func requestOvernightExpirationNotification(for hormone: Hormonal) {
		if let sdk = sdk, let expiration = hormone.expiration,
			let notificationTime = DateFactory.createDateBeforeAtEightPM(of: expiration) {
			let params = ExpiredHormoneOvernightNotificationCreationParams(
				triggerDate: notificationTime,
				deliveryMethod: sdk.settings.deliveryMethod.value,
				totalHormonesExpired: sdk.hormones.totalExpired
			)
			factory.createOvernightExpiredHormoneNotification(params).request()
		}
	}

	private func appendHormoneIdToList(at i: Index, lst: inout [String]) {
		if let mone = sdk?.hormones[i] {
			let id = mone.id.uuidString
			lst.append(id)
		}
	}
}
