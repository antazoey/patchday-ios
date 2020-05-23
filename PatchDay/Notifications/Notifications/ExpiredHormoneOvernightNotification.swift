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

    init(
		_ date: Date,
		_ method: DeliveryMethod,
		_ requestHandler: ((_ interval: Double, _ id: String)-> Void
		)?=nil) {
		self.dateBeforeOvernightExpiration = date
		self.deliveryMethod = method
		let title = NotificationStrings.Overnight[method]
		super.init(title: title, body: nil, requestHandler: requestHandler)
	}

	public func request() {
		let interval = dateBeforeOvernightExpiration.timeIntervalSinceNow
		if interval > 0 {
			super.request(when: interval, requestId: "overnight")
		}
	}
}
