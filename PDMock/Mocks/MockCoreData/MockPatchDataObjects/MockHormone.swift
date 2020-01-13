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
    public var isEqualToCallArgs: [Hormonal] = []
    public var isEqualToReturnValues: [Bool] = []
    public var resetCallCount = 0
    
    // Hormonal properties
    public var id: UUID = UUID()
    public var deliveryMethod: DeliveryMethod = .Patches
    public var expirationInterval: ExpirationIntervalUD = ExpirationIntervalUD()
    public var siteId: UUID? = nil
    public var siteName: SiteName? = nil
    public var date: Date = Date(timeIntervalSince1970: 0)
    public var expiration: Date? = nil
    public var expirationString: String = ""
    public var isExpired: Bool = false
    public var isPastNotificationTime: Bool = false
    public var expiresOvernight: Bool = false
    public var siteNameBackUp: String? = ""
    public var isEmpty: Bool = false
    public var hasSite: Bool = false
    public var hasDate: Bool = false
    
    public init() {}
    
    public func resetMock() {
        stampCallCount = 0
        isEqualToCallArgs = []
        isEqualToReturnValues = []
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
    
    public func isEqualTo(_ otherHormone: Hormonal) -> Bool {
        isEqualToCallArgs.append(otherHormone)
        if let t = isEqualToReturnValues.first {
            isEqualToReturnValues.remove(at: 0)
            return t
        }
        return false
    }
    
    public func reset() {
        resetCallCount += 1
    }
}
