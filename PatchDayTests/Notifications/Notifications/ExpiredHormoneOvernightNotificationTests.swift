//
//  ExpiredHormoneOvernightNotificationTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/1/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class ExpiredHormoneOvernightNotificationTests: XCTestCase {

    private static var testHandlerCallCount = 0
    private let _testHandler: (Double, String) -> Void = { v, id in testHandlerCallCount += 1}

    func testInit_whenUsingPatches_hasExpectedProperties() {
        let not = ExpiredHormoneOvernightNotification(
			Date(timeIntervalSinceNow: -100), .Patches, MockBadge(), _testHandler
		)
        XCTAssertEqual("Patch expires overnight.", not.title)
        XCTAssertNil(not.body)
    }

    func testInit_whenUsingInjections_hasExpectedProperties() {
        let not = ExpiredHormoneOvernightNotification(
			Date(timeIntervalSinceNow: -100), .Injections, MockBadge(), _testHandler
		)
        XCTAssertEqual("Injection due overnight.", not.title)
        XCTAssertNil(not.body)
    }

    func testRequest_whenGivenDateInPast_doesNotRequest() {
        let not = ExpiredHormoneOvernightNotification(
			Date(timeIntervalSinceNow: -100), .Patches, MockBadge(),_testHandler
		)
        not.request()
        XCTAssertEqual(0, ExpiredHormoneOvernightNotificationTests.testHandlerCallCount)
    }

    func testRequest_requests() {
        let not = ExpiredHormoneOvernightNotification(
			Date(timeIntervalSinceNow: 100), .Patches, MockBadge(), _testHandler
		)
        not.request()
        XCTAssertEqual(1, ExpiredHormoneOvernightNotificationTests.testHandlerCallCount)
        ExpiredHormoneOvernightNotificationTests.testHandlerCallCount = 0
    }
}
