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

    public static let actionId = "estroActionId"

    init(
        hormone: Hormonal,
        notifyMinutes: Double,
        suggestedSite: SiteName?,
        currentBadgeValue: Int,
        requestHandler: ((_ interval: Double, _ id: String)-> Void)?=nil
    ) {
        self.hormone = hormone
        self.notificationsMinutesBefore = notifyMinutes
        let strings = NotificationStrings.get(
            method: hormone.deliveryMethod,
            notifyMinutes: notifyMinutes,
            suggestedSite: suggestedSite
        )
        super.init(
            title: strings.0,
            body: strings.1,
            categoryId: nil,
            currentBadgeValue: currentBadgeValue,
            requestHandler: requestHandler
        )
    }

    private var hormoneId: String { hormone.id.uuidString }

    public func request() {
        guard let expiration = createInterval(), expiration > 0 else { return }
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
