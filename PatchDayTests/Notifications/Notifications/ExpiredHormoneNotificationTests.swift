//
//  ExpiredHormoneNotificationTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 4/27/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchDay


class ExpiredHormoneNotificationTests: XCTestCase {
    
    private let _name = "Dat Ass Cheek"
    private let _oldName = "Dat Tummy"
    
    private static var testHandlerCallCount = 0
    private let _testHandler: (Double, String) -> () = { v, id in testHandlerCallCount += 1}

    func testInit_whenUsingPatchesAndMinutesBefore_hasExpectedTitleAndBody() {
        let hormone = MockHormone()
        hormone.siteName = _oldName
        hormone.deliveryMethod = .Patches
        let expiration = ExpirationIntervalUD()
        let notifyMin = Double(30)
        let suggestedSiteName = _name
        let alerts = 30
        
        let not = ExpiredHormoneNotification(
            hormone: hormone,
            expiration: expiration,
            notifyMinutes: notifyMin,
            suggestedSite: suggestedSiteName,
            badge: alerts,
            requestHandler: _testHandler
        )
        
        XCTAssertEqual("Almost time for your next patch", not.title)
        XCTAssertEqual("Suggested next site: \(suggestedSiteName)", not.body)
    }
    
    func testInit_whenUsingInjectionsAndMinutesBefore_hasExpectedTitleAndBody() {
        let hormone = MockHormone()
        hormone.deliveryMethod = .Injections
        let expiration = ExpirationIntervalUD()
        let notifyMin = Double(30)
        let suggestedSiteName = "Dat Ass Cheek"
        let alerts = 30
        
        let not = ExpiredHormoneNotification(
            hormone: hormone,
            expiration: expiration,
            notifyMinutes: notifyMin,
            suggestedSite: suggestedSiteName,
            badge: alerts,
            requestHandler: _testHandler
        )
        
        XCTAssertEqual("Almost time for your next injection", not.title)
        XCTAssertEqual("Suggested next site: \(suggestedSiteName)", not.body)
    }
    
    func testRequest_callsHandlers() {
        let hormone = MockHormone()
        hormone.date = Date()
        let expiration = ExpirationIntervalUD()
        let notifyMin = Double(30)
        let suggestedSiteName = "Dat Ass Cheek"
        let alerts = 30
        
        let not = ExpiredHormoneNotification(
            hormone: hormone,
            expiration: expiration,
            notifyMinutes: notifyMin,
            suggestedSite: suggestedSiteName,
            badge: alerts,
            requestHandler: _testHandler
        )
        
        not.request()
        XCTAssertEqual(1, ExpiredHormoneNotificationTests.testHandlerCallCount)
        ExpiredHormoneNotificationTests.testHandlerCallCount = 0
    }
    
    func testRequest_whenHormoneHasNoDate_doesNotRequest() {
        let hormone = MockHormone()
        let expiration = ExpirationIntervalUD()
        let notifyMin = Double(30)
        let suggestedSiteName = "Dat Ass Cheek"
        let alerts = 30
        
        let not = ExpiredHormoneNotification(
            hormone: hormone,
            expiration: expiration,
            notifyMinutes: notifyMin,
            suggestedSite: suggestedSiteName,
            badge: alerts,
            requestHandler: _testHandler
        )
        
        not.request()
        XCTAssertEqual(0, ExpiredHormoneNotificationTests.testHandlerCallCount)
    }
}
