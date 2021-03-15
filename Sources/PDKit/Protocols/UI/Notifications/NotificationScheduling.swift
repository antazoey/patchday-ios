//
//  NotificationScheduling.swift
//  PatchDay
//
//  Created by Juliya Smith on 9/25/19.

import Foundation

public protocol NotificationScheduling {

    /// Cancel a single hormone notification.
    func cancelExpiredHormoneNotification(for hormone: Hormonal)

    /// Cancel a range of hormone notifications via hormone indices.
    func cancelRangeOfExpiredHormoneNotifications(from begin: Index, to end: Index)

    /// Cancel every hormone notification.
    func cancelAllExpiredHormoneNotifications()

    /// Request a hormone notification per hormone.
    func requestAllExpiredHormoneNotifications()

    /// Request a single hormone notification.
    func requestExpiredHormoneNotification(for hormone: Hormonal)

    /// Request a range of hormone notifications via hormone indices.
    func requestRangeOfExpiredHormoneNotifications(from begin: Index, to end: Index)

    /// Request an overnight hormone expiration notification.
    func requestOvernightExpirationNotification(for hormone: Hormonal)

    /// Cancel a pill notification.
    func cancelDuePillNotification(_ pill: Swallowable)

    /// Cancel all pill notifications.
    func cancelAllDuePillNotifications()

    /// Request a pill notification.
    func requestDuePillNotification(_ pill: Swallowable)

    /// Request all pill notifications.
    func requestAllDuePillNotifications()
}
