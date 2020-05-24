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
	private let notificationsMinutesBefore: Double
	private let badge: PDBadgeDelegate

	public static let actionId = "estroActionId"
	public static let categoryId = "estroCategoryId"

    init(
        hormone: Hormonal,
        notifyMinutes: Double,
        suggestedSite: SiteName?,
		badge: PDBadgeDelegate,
        requestHandler: ((_ interval: Double, _ id: String)-> Void)?=nil
    ) {
		self.hormone = hormone
        self.notificationsMinutesBefore = notifyMinutes
		self.badge = badge
        let strings = NotificationStrings.get(
            method: hormone.deliveryMethod,
            notifyMinutes: notifyMinutes,
            suggestedSite: suggestedSite
        )
        super.init(
            title: strings.0,
            body: strings.1,
			categoryId: ExpiredHormoneNotification.categoryId,
			badge: badge,
            requestHandler: requestHandler
        )
	}

    private var hormoneId: String { hormone.id.uuidString }

	public func request() {
		guard let expiration = createInterval(), expiration > 0 else { return }
        super.content.categoryIdentifier = ExpiredHormoneNotification.categoryId
        super.request(when: expiration, requestId: hormoneId)
	}

    private func createInterval() -> TimeInterval? {
        guard let interval = createIntervalFromExpirationSetting() else { return nil }
        return accountForNotificationsMinBefore(interval)
    }

    private func createIntervalFromExpirationSetting() -> TimeInterval? {
		let hours = hormone.expirationInterval.hours
		return DateFactory.createTimeInterval(fromAddingHours: hours, to: hormone.date)
    }

    private func accountForNotificationsMinBefore(_ interval: TimeInterval) -> TimeInterval {
        interval - (notificationsMinutesBefore * 60.0)
    }
}
