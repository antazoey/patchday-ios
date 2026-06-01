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

    /// Hours after expiration to send follow-up "still due" reminders, so a
    /// missed first notification still nudges the user. (#79)
    public static let followUpOffsetsHours: [Double] = [2, 6]

    /// Every notification identifier PatchDay may schedule for one hormone —
    /// the on-time alert plus its follow-up reminders — so cancellation clears
    /// all of them.
    public static func notificationIds(for hormoneId: String) -> [String] {
        [hormoneId] + followUpOffsetsHours.indices.map { "\(hormoneId)#\($0 + 1)" }
    }

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
        guard let expirationInterval = createIntervalFromExpirationSetting() else { return }
        let firstFire = expirationInterval - (notificationsMinutesBefore * 60.0)
        if firstFire > 0 {
            super.request(when: firstFire, requestId: hormoneId)
        }
        // Follow-up reminders after the dose is overdue (#79). These still fire
        // even if the on-time alert is already in the past, so a hormone that's
        // overdue when rescheduled still gets nudged.
        for (index, hours) in ExpiredHormoneNotification.followUpOffsetsHours.enumerated() {
            let fire = expirationInterval + (hours * 3600.0)
            guard fire > 0 else { continue }
            super.request(when: fire, requestId: "\(hormoneId)#\(index + 1)")
        }
    }

    private func createIntervalFromExpirationSetting() -> TimeInterval? {
        let hours = hormone.expirationInterval.hours
        return DateFactory.createTimeInterval(fromAddingHours: hours, to: hormone.date)
    }
}
