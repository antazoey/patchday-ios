//
//  NotificationProducing.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/7/19.

import Foundation

public protocol NotificationProducing {
    func createExpiredHormoneNotification(hormone: Hormonal) -> PDNotificationProtocol
    func createDuePillNotification(_ pill: Swallowable) -> PDNotificationProtocol
    func createOvernightExpiredHormoneNotification(date: Date) -> PDNotificationProtocol
}
