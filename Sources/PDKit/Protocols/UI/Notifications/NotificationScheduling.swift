//
//  NotificationScheduling.swift
//  PatchDay
//
//  Created by Juliya Smith on 9/25/19.

import Foundation

public protocol NotificationScheduling {

    func cancelExpiredHormoneNotification(for hormone: Hormonal)

    func cancelRangeOfExpiredHormoneNotifications(from begin: Index, to end: Index)

    func cancelAllExpiredHormoneNotifications()

    func requestAllExpiredHormoneNotifications()

    func requestExpiredHormoneNotification(for hormone: Hormonal)

    func requestRangeOfExpiredHormoneNotifications(from begin: Index, to end: Index)

    func requestOvernightExpirationNotification(for hormone: Hormonal)

    func cancelDuePillNotification(_ pill: Swallowable)

    func requestDuePillNotification(_ pill: Swallowable)
}
