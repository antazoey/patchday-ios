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
            currentBadgeValue: currentAlertCount
        )
    }

    public func createDuePillNotification(_ pill: Swallowable) -> PDNotificationProtocol {
        DuePillNotification(for: pill, currentBadgeValue: currentAlertCount)
    }

    /// The live alert count to base a notification's badge on. We use the SDK's
    /// fresh `totalAlerts` rather than the last-cached icon badge value: a
    /// notification is scheduled right after a change (e.g. changing an expired
    /// patch), and the cached badge still counts the item being changed — so
    /// "cached + 1" double-counted and showed 2 for a single new alert.
    private var currentAlertCount: Int {
        sdk.totalAlerts
    }

    public func createOvernightExpiredHormoneNotification(date: Date) -> PDNotificationProtocol {
        ExpiredHormoneOvernightNotification(date, sdk.settings.deliveryMethod.value)
    }
}
