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

    private static var testHandlerCallArgs: [(Double, String)] = []
    private let _testHandler: (Double, String) -> Void = {
        v, id in ExpiredHormoneNotificationTests.testHandlerCallArgs.append((v, id))
    }

    func testInit_whenUsingPatchesAndMinutesBefore_hasExpectedProperties() {
        let hormone = MockHormone()
        hormone.siteName = _oldName
        hormone.deliveryMethod = .Patches
        let notifyMin = Double(30)
        let suggestedSiteName = _name
        let not = ExpiredHormoneNotification(
            hormone: hormone,
            notifyMinutes: notifyMin,
            suggestedSite: suggestedSiteName,
            currentBadgeValue: 0,
            requestHandler: _testHandler
        )
        XCTAssertEqual("Almost time for your next patch", not.title)
        XCTAssertEqual("Suggested next site: \(suggestedSiteName)", not.body)
    }

    func testInit_whenUsingInjectionsAndMinutesBefore_hasExpectedProperties() {
        let hormone = MockHormone()
        hormone.deliveryMethod = .Injections
        let notifyMin = Double(30)
        let suggestedSiteName = "Dat Ass Cheek"

        let not = ExpiredHormoneNotification(
            hormone: hormone,
            notifyMinutes: notifyMin,
            suggestedSite: suggestedSiteName,
            currentBadgeValue: 0,
            requestHandler: _testHandler
        )

        XCTAssertEqual("Almost time for your next injection", not.title)
        XCTAssertEqual("Suggested next site: \(suggestedSiteName)", not.body)
    }

    func testRequest_callsHandlersWithExpectedArgs() {
        let hormone = MockHormone()
        hormone.date = Date()
        hormone.expirationInterval = ExpirationIntervalUD()
        let notifyMin = Double(30)
        let suggestedSiteName = "Dat Ass Cheek"

        let not = ExpiredHormoneNotification(
            hormone: hormone,
            notifyMinutes: notifyMin,
            suggestedSite: suggestedSiteName,
            currentBadgeValue: 0,
            requestHandler: _testHandler
        )
        let hours = hormone.expirationInterval.hours
        let date = hormone.date
        let expected = DateFactory.createTimeInterval(fromAddingHours: hours, to: date)! - 30 * 60
        ExpiredHormoneNotificationTests.testHandlerCallArgs = []
        not.request()
        let actual = ExpiredHormoneNotificationTests.testHandlerCallArgs[0].0
        XCTAssert(PDTest.equiv(expected, actual))
        XCTAssertEqual(hormone.id.uuidString, ExpiredHormoneNotificationTests.testHandlerCallArgs[0].1)
    }

    func testRequest_whenHormoneHasNoDate_doesNotRequest() {
        let hormone = MockHormone()
        hormone.expirationInterval = ExpirationIntervalUD()
        let notifyMin = Double(30)
        let suggestedSiteName = "Dat Ass Cheek"

        let not = ExpiredHormoneNotification(
            hormone: hormone,
            notifyMinutes: notifyMin,
            suggestedSite: suggestedSiteName,
            currentBadgeValue: 0,
            requestHandler: _testHandler
        )
        ExpiredHormoneNotificationTests.testHandlerCallArgs = []
        not.request()
        XCTAssertEqual(0, ExpiredHormoneNotificationTests.testHandlerCallArgs.count)
    }
}
