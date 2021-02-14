//
//  MockHormone.swift
//  PDMock
//
//  Created by Juliya Smith on 1/9/20.
//  
//

import Foundation
import PDKit

public class MockHormone: Hormonal, PDMocking {
    public var siteImageId: SiteName = ""
    public var id = UUID()
    public var deliveryMethod = DeliveryMethod.Patches
    public var expirationInterval = ExpirationIntervalUD(DefaultSettings.ExpirationIntervalRawValue)
    public var siteId: UUID?
    public var siteName: SiteName = SiteStrings.NewSite
    public var date: Date = Date(timeIntervalSince1970: 0)
    public var expiration: Date?
    public var isExpired = false
    public var isPastNotificationTime = false
    public var expiresOvernight = false
    public var siteNameBackUp: String? = ""
    public var isEmpty = false
    public var hasSite = false
    public var hasDate = false

    public init() { }

    var fromCallArgs: [UserDefaultsReading] = []
    public func from(_ settings: UserDefaultsReading) -> Hormonal {
        fromCallArgs.append(settings)
        return self
    }

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

    public var stampCallCount: Int = 0
    public func stamp() {
        stampCallCount += 1
    }

    public var resetCallCount = 0
    public func reset() {
        resetCallCount += 1
    }

    public var createExpirationDateCallArgs: [Date?] = []
    public var createExpirationDateReturnValue: Date?
    public func createExpirationDate(from startDate: Date) -> Date? {
        createExpirationDateCallArgs.append(startDate)
        return createExpirationDateReturnValue
    }
}
