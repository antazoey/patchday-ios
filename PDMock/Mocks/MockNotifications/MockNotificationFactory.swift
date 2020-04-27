//
//  MockNotificationFactory.swift
//  PDMock
//
//  Created by Juliya Smith on 4/26/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

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
    
    public var createExpiredHormoneNotificationCallArgs: [ExpiredHormoneNotificationCreationParams] = []
    public var createExpiredHormoneNotificationReturnValue: PDNotificationProtocol = MockNotification()
    public func createExpiredHormoneNotification(_ params: ExpiredHormoneNotificationCreationParams) -> PDNotificationProtocol {
        createExpiredHormoneNotificationCallArgs.append(params)
        return createExpiredHormoneNotificationReturnValue
    }
    
    public var createDuePillNotificationCallArgs: [(Swallowable, Int)] = []
    public var createDuePillNotificationReturnValue: PDNotificationProtocol = MockNotification()
    public func createDuePillNotification(_ pill: Swallowable, totalDue: Int) -> PDNotificationProtocol {
        createDuePillNotificationCallArgs.append((pill, totalDue))
        return createDuePillNotificationReturnValue
    }
    
    public var createOvernightExpiredHormoneNotificationCallArgs: [ExpiredHormoneOvernightNotificationCreationParams] = []
    public var createOvernightExpiredHormoneNotificationReturnValue: PDNotificationProtocol = MockNotification()
    public func createOvernightExpiredHormoneNotification(_ params: ExpiredHormoneOvernightNotificationCreationParams) -> PDNotificationProtocol {
        createOvernightExpiredHormoneNotificationCallArgs.append(params)
        return createOvernightExpiredHormoneNotificationReturnValue
    }
}
