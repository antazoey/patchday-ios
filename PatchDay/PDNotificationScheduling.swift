//
//  PDNotificationScheduling.swift
//  PatchDay
//
//  Created by Juliya Smith on 9/25/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

protocol PDNotificationScheduling {
    func cancelExpiredHormoneNotification(at index: Index)
    func cancelExpiredHormoneNotifications(from begin: Index, to end: Index)
    func cancelAllExpiredHormoneNotifications()
    func resendAllExpiredExpiredNotifications()
    func requestExpiredHormoneNotification(for hormone: Hormonal)
    func resendExpiredHormoneNotifications(from begin: Index, to end: Index)
    func requestOvernightExpirationNotification(_ hormone: Hormonal)
    func requestDuePillNotification(forPillAt index: Index)
    func cancelDuePillNotification(_ pill: Swallowable)
    func requestDuePillNotification(_ pill: Swallowable)
}
