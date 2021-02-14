//
//  MockNotifications.swift
//  PDMock
//
//  Created by Juliya Smith on 5/10/20.
//  
//

import Foundation
import PDKit

public class MockNotifications: NotificationScheduling {

    public init() {}

    public var setHormoneChangeUpdateViewsHookCallArgs: [() -> Void] = []
    public func setHormoneChangeUpdateViewsHook(hook: @escaping () -> Void) {
        setHormoneChangeUpdateViewsHookCallArgs.append(hook)
    }

    public var cancelExpiredHormoneNotificationCallArgs: [Hormonal] = []
    public func cancelExpiredHormoneNotification(for hormone: Hormonal) {
        cancelExpiredHormoneNotificationCallArgs.append(hormone)
    }

    public var cancelRangeOfExpiredHormoneNotificationsCallArgs: [(Index, Index)] = []
    public func cancelRangeOfExpiredHormoneNotifications(from begin: Index, to end: Index) {
        cancelRangeOfExpiredHormoneNotificationsCallArgs.append((begin, end))
    }

    public var cancelAllExpiredHormoneNotificationsCallCount = 0
    public func cancelAllExpiredHormoneNotifications() {
        cancelAllExpiredHormoneNotificationsCallCount += 1
    }

    public var requestAllExpiredHormoneNotificationCallCount = 0
    public func requestAllExpiredHormoneNotifications() {
        requestAllExpiredHormoneNotificationCallCount += 1
    }

    public var requestExpiredHormoneNotificationCallArgs: [Hormonal] = []
    public func requestExpiredHormoneNotification(for hormone: Hormonal) {
        requestExpiredHormoneNotificationCallArgs.append(hormone)
    }

    public var requestRangeOfExpiredHormoneNotificationsCallArgs: [(Index, Index)] = []
    public func requestRangeOfExpiredHormoneNotifications(from begin: Index, to end: Index) {
        requestRangeOfExpiredHormoneNotificationsCallArgs.append((begin, end))
    }

    public var requestOvernightExpirationNotificationCallArgs: [Hormonal] = []
    public func requestOvernightExpirationNotification(for hormone: Hormonal) {
        requestOvernightExpirationNotificationCallArgs.append(hormone)
    }

    public var cancelDuePillNotificationCallArgs: [Swallowable] = []
    public func cancelDuePillNotification(_ pill: Swallowable) {
        cancelDuePillNotificationCallArgs.append(pill)
    }

    public var requestDuePillNotificationCallArgs: [Swallowable] = []
    public func requestDuePillNotification(_ pill: Swallowable) {
        requestDuePillNotificationCallArgs.append(pill)
    }
}
