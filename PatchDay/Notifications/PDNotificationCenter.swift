//
//  PDNotificationCenter.swift
//  PatchDay
//
//  Created by Juliya Smith on 9/24/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import UserNotifications
import PDKit

class PDNotificationCenter: NSObject, NotificationCenterDelegate {

	private let root: UNUserNotificationCenter
    private lazy var log = PDLog<PDNotificationCenter>()
	var hormoneActionHandler: HormoneNotificationActionHandling
	var pillActionHandler: PillNotificationActionHandling

	init(
		root: UNUserNotificationCenter,
        handleHormone: HormoneNotificationActionHandling,
		handlePill: PillNotificationActionHandling
	) {
		self.hormoneActionHandler = handleHormone
		self.pillActionHandler = handlePill
		self.root = root
		super.init()
		self.root.delegate = self
		self.root.requestAuthorization(options: [.alert, .sound, .badge]) {
			(_, error) in
			if let e = error {
				self.log.error(e)
			}
		}
		self.root.setNotificationCategories(categories)
	}

	private var categories: Set<UNNotificationCategory> {
		let hormoneActionId = ExpiredHormoneNotification.actionId
		let hormoneAction = UNNotificationAction(
			identifier: hormoneActionId,
			title: ActionStrings.Autofill,
			options: []
		)
		let hormoneCatId = ExpiredHormoneNotification.categoryId
		let hormoneCategory = UNNotificationCategory(
			identifier: hormoneCatId,
			actions: [hormoneAction],
			intentIdentifiers: [],
			options: []
		)
		let pillActionId = DuePillNotification.actionId
		let pillAction = UNNotificationAction(
			identifier: pillActionId,
			title: ActionStrings.Take,
			options: []
		)
		let pillCatId = DuePillNotification.categoryId
		let pillCategory = UNNotificationCategory(
			identifier: pillCatId,
			actions: [pillAction],
			intentIdentifiers: [],
			options: []
		)
		return Set([hormoneCategory, pillCategory])
	}

	func removeNotifications(with ids: [String]) {
		root.removePendingNotificationRequests(withIdentifiers: ids)
	}

	/// Handles responses received from interacting with notifications.
	func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		didReceive response: UNNotificationResponse,
		withCompletionHandler completionHandler: @escaping () -> Void
	) {
		let id = response.notification.request.identifier
		switch response.actionIdentifier {
			case ExpiredHormoneNotification.actionId: hormoneActionHandler.handleHormone(id: id)
			case DuePillNotification.actionId: pillActionHandler.handlePill(pillId: id)
			default: return
		}
		completionHandler()
	}
}
