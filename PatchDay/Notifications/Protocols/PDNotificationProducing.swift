//
//  NotificationProducing.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/7/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


protocol NotificationProducing {
	func createExpiredHormoneNotification(_ params: ExpiredHormoneNotificationCreationParams) -> ExpiredHormoneNotifying
	func createDuePillNotification(_ pill: Swallowable, totalDue: Int) -> DuePillNotifying
	func createOvernightExpiredHormoneNotification(_ params: ExpiredHormoneOvernightNotificationCreationParams) -> ExpiredHormoneOvernightNotifying
}
