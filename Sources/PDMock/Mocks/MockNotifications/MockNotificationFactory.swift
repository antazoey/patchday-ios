//
//  MockNotificationFactory.swift
//  PDMock
//
//  Created by Juliya Smith on 4/26/20.

import Foundation
import PDKit

public class MockNotification: PDNotificationProtocol {

    public init() {}

    public var requestCallCount = 0
    public func request() {
        requestCallCount += 1
    }
}

public class MockNotificationFactory: NotificationProducing {

    public init() {}

    public var createExpiredHormoneNotificationCallArgs: [Hormonal] = []
    public var createExpiredHormoneNotificationReturnValue: PDNotificationProtocol = MockNotification()
    public func createExpiredHormoneNotification(hormone: Hormonal) -> PDNotificationProtocol {
        createExpiredHormoneNotificationCallArgs.append(hormone)
        return createExpiredHormoneNotificationReturnValue
    }

    public var createDuePillNotificationCallArgs: [Swallowable] = []
    public var createDuePillNotificationReturnValue: PDNotificationProtocol = MockNotification()
    public func createDuePillNotification(_ pill: Swallowable) -> PDNotificationProtocol {
        createDuePillNotificationCallArgs.append(pill)
        return createDuePillNotificationReturnValue
    }

    public var createOvernightExpiredHormoneNotificationCallArgs: [Date] = []
    public var createOvernightExpiredHormoneNotificationReturnValue = MockNotification()
    public func createOvernightExpiredHormoneNotification(date: Date) -> PDNotificationProtocol {
        createOvernightExpiredHormoneNotificationCallArgs.append(date)
        return createDuePillNotificationReturnValue
    }
}
