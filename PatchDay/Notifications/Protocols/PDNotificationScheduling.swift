//
//  NotificationScheduling.swift
//  PatchDay
//
//  Created by Juliya Smith on 9/25/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

protocol NotificationScheduling {
    func cancelExpiredHormoneNotification(at index: Index)
    func cancelExpiredHormoneNotification(for hormone: Hormonal)
    func cancelExpiredHormoneNotifications(from begin: Index, to end: Index)
    func cancelAllExpiredHormoneNotifications()
    func resendAllExpiredHormoneNotifications()
    func requestExpiredHormoneNotification(for hormone: Hormonal)
    func resendExpiredHormoneNotifications(from begin: Index, to end: Index)
    func requestOvernightExpirationNotification(for hormone: Hormonal)
    func requestDuePillNotification(forPillAt index: Index)
    func cancelDuePillNotification(_ pill: Swallowable)
    func requestDuePillNotification(_ pill: Swallowable)
}
