//
//  MockHormone.swift
//  PDMock
//
//  Created by Juliya Smith on 1/9/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class MockHormone: Hormonal, PDMocking {

    // Mock-related properties
    public var stampCallCount: Int = 0
    public var resetCallCount = 0
    
    // Hormonal properties
    public var id = UUID()
    public var deliveryMethod = DeliveryMethod.Patches
    public var expirationInterval = ExpirationIntervalUD(DefaultSettings.ExpirationIntervalRawValue)
    public var siteId: UUID? = nil
    public var siteName: SiteName? = nil
    public var date: Date = Date(timeIntervalSince1970: 0)
    public var expiration: Date? = nil
    public var expirationString = ""
    public var isExpired = false
    public var isPastNotificationTime = false
    public var expiresOvernight = false
    public var siteNameBackUp: String? = ""
    public var isEmpty = false
    public var hasSite = false
    public var hasDate = false
    
    public init() {}
    
    public func resetMock() {
        stampCallCount = 0
        resetCallCount = 0
    }
    
    @discardableResult
    public static func createList(count: Int) -> [MockHormone] {
        var hormoneList: [MockHormone] = []
        for _ in 0..<count {
            hormoneList.append(MockHormone())
        }
        return hormoneList
    }
    
    public func stamp() {
        stampCallCount += 1
    }
    
    public func reset() {
        resetCallCount += 1
    }
}
