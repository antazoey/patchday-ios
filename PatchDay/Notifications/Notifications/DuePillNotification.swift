//
//  DuePillNotification.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/15/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import UserNotifications
import PDKit

public class DuePillNotification: Notification, PDNotificationProtocol {

	private let pill: Swallowable
	private let badge: PDBadgeDelegate

	public static var actionId = { "takeActionId" }()
	public static var categoryId = { "pillCategoryId" }()

	init(
		for pill: Swallowable,
		badge: PDBadgeDelegate,
		requestHandler: ((_ interval: Double, _ id: String)-> Void)?=nil
	) {
		self.pill = pill
		self.badge = badge
		let title = "\(NotificationStrings.takePill)\(pill.name)"
		super.init(title: title, body: nil, badge: badge, requestHandler: requestHandler)
	}

	public func request() {
		super.content.categoryIdentifier = DuePillNotification.categoryId
		if let interval = pill.due?.timeIntervalSince(Date()), interval > 0 {
			super.request(when: interval, requestId: pill.id.uuidString)
		}
	}
}
