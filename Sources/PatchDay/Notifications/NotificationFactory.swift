//
//  NotificationFactory.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/7/19.

import Foundation
import PDKit

public class NotificationFactory: NotificationProducing {

    private let sdk: PatchDataSDK
    private let badge: PDBadgeReflective

    public init(sdk: PatchDataSDK, badge: PDBadgeReflective) {
        self.sdk = sdk
        self.badge = badge
    }

    public func createExpiredHormoneNotification(hormone: Hormonal) -> PDNotificationProtocol {
        ExpiredHormoneNotification(
            hormone: hormone,
            notifyMinutes: Double(sdk.settings.notificationsMinutesBefore.value),
            currentBadgeValue: badge.value
        )
    }

    public func createDuePillNotification(_ pill: Swallowable) -> PDNotificationProtocol {
        DuePillNotification(for: pill, currentBadgeValue: badge.value)
    }

    public func createOvernightExpiredHormoneNotification(date: Date) -> PDNotificationProtocol {
        ExpiredHormoneOvernightNotification(date, sdk.settings.deliveryMethod.value)
    }
}
