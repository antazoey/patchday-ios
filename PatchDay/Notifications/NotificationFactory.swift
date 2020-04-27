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

	public func createExpiredHormoneNotification(
        _ params: ExpiredHormoneNotificationCreationParams
    ) -> PDNotificationProtocol {
		ExpiredHormoneNotification(params)
	}

	public func createDuePillNotification(_ pill: Swallowable, totalDue: Int) -> PDNotificationProtocol {
		DuePillNotification(for: pill, totalDue: totalDue)
	}

	public func createOvernightExpiredHormoneNotification(
        _ params: ExpiredHormoneOvernightNotificationCreationParams
    ) -> PDNotificationProtocol {
		ExpiredHormoneOvernightNotification(params)
	}
}
