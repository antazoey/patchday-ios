//
//  ExpiredHormoneNotification .swift
//  PatchDay
//
//  Created by Juliya Smith on 5/27/19.

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
        currentBadgeValue: Int,
        requestHandler: ((_ interval: Double, _ id: String) -> Void)?=nil
    ) {
        self.hormone = hormone
        self.notificationsMinutesBefore = notifyMinutes
        let strings = NotificationStrings(hormone: hormone)
        super.init(
            title: strings.title,
            body: strings.body,
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
        return interval - (notificationsMinutesBefore * 60.0)
    }

    private func createIntervalFromExpirationSetting() -> TimeInterval? {
        let hours = hormone.expirationInterval.hours
        return DateFactory.createTimeInterval(fromAddingHours: hours, to: hormone.date)
    }
}
