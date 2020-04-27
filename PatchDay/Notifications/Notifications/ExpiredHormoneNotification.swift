//
//  ExpiredHormoneNotification .swift
//  PatchDay
//
//  Created by Juliya Smith on 5/27/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import UserNotifications
import PDKit


public class ExpiredHormoneNotification: Notification, PDNotificationProtocol {

	private let hormone: Hormonal
	private let expiration: ExpirationIntervalUD
	private let notificationsMinutesBefore: Double

	public static let actionId = "estroActionId"
	public static let categoryId = "estroCategoryId"

	init(_ params: ExpiredHormoneNotificationCreationParams) {
		self.hormone = params.hormone
		self.expiration = params.expiration
        self.notificationsMinutesBefore = params.notificationsMinutesBefore
		let strings = NotificationStrings[params]
		super.init(title: strings.0, body: strings.1, badge: params.totalHormonesExpired)
	}

	public func request() {
		let hours = expiration.hours
        let expirationInterval = DateFactory.createTimeInterval(fromAddingHours: hours, to: hormone.date)
		guard var expiration = expirationInterval else { return }
		expiration = expiration - (self.notificationsMinutesBefore * 60.0)
        guard expiration > 0 else { return }
        let id = self.hormone.id.uuidString
        super.content.categoryIdentifier = ExpiredHormoneNotification.categoryId
        super.request(when: expiration, requestId: id)
	}
}
