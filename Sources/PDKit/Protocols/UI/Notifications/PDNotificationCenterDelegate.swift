//
//  NotificationProviding.swift
//  PatchDay
//
//  Created by Juliya Smith on 9/24/19.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import UserNotifications

public protocol NotificationCenterDelegate: UNUserNotificationCenterDelegate {
    func removeNotifications(with ids: [String])
}
