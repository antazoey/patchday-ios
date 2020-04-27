//
//  ExpiredHormoneOvernightNotification.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/15/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import UserNotifications
import PDKit

public class ExpiredHormoneOvernightNotification: Notification, PDNotificationProtocol {

	private let dateBeforeOvernightExpiration: Date
	private let deliveryMethod: DeliveryMethod

	init(_ params: ExpiredHormoneOvernightNotificationCreationParams) {
		self.dateBeforeOvernightExpiration = params.triggerDate
		self.deliveryMethod = params.deliveryMethod
		let title = NotificationStrings.Overnight[params.deliveryMethod]
		super.init(title: title, body: nil, badge: params.totalHormonesExpired)
	}

	public func request() {
		let interval = dateBeforeOvernightExpiration.timeIntervalSinceNow
		if interval > 0 {
			super.request(when: interval, requestId: "overnight")
		}
	}
}
