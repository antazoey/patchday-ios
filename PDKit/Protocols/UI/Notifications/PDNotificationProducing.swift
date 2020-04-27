//
//  NotificationProducing.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/7/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public protocol NotificationProducing {
	func createExpiredHormoneNotification(_ params: ExpiredHormoneNotificationCreationParams) -> PDNotificationProtocol
	func createDuePillNotification(_ pill: Swallowable, totalDue: Int) -> PDNotificationProtocol
	func createOvernightExpiredHormoneNotification(_ params: ExpiredHormoneOvernightNotificationCreationParams) -> PDNotificationProtocol
}
