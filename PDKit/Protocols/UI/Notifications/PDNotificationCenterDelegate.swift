//
//  NotificationProviding.swift
//  PatchDay
//
//  Created by Juliya Smith on 9/24/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import UserNotifications

public protocol NotificationCenterDelegate: UNUserNotificationCenterDelegate {
	func setHormoneChangeUpdateViewsHook(hook: @escaping () -> Void)
	func removeNotifications(with ids: [String])
}
