//
//  NotificationFactory.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/7/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class NotificationFactory: NotificationProducing {

    private let sdk: PatchDataSDK

    public init(sdk: PatchDataSDK) {
        self.sdk = sdk
    }

    public func createExpiredHormoneNotification(hormone: Hormonal) -> PDNotificationProtocol {
        ExpiredHormoneNotification(
            hormone: hormone,
            expiration: sdk.settings.expirationInterval,
            notifyMinutes: Double(sdk.settings.notificationsMinutesBefore.value),
            suggestedSite: sdk.sites.suggested?.name
        )
	}

    public func createDuePillNotification(_ pill: Swallowable) -> PDNotificationProtocol {
        DuePillNotification(for: pill)
	}

    public func createOvernightExpiredHormoneNotification(date: Date) -> PDNotificationProtocol {
		ExpiredHormoneOvernightNotification(date, sdk.settings.deliveryMethod.value)
    }
}
