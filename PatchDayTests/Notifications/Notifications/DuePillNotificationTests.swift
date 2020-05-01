//
//  DuePillNotificationTests.swift
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


class DuePillNotificationTests: XCTestCase {

    private static var testHandlerCallCount = 0
    private let _testHandler: (Double, String) -> () = { v, id in testHandlerCallCount += 1}
    
    func testInit_hasExpectedProperties() {
        let pill = MockPill()
        pill.name = "Cannabis"
        let not = DuePillNotification(for: pill, badge: 1, requestHandler: _testHandler)
        XCTAssertEqual("Time to take pill: Cannabis", not.title)
        XCTAssertNil(not.body)
    }

    func testRequests_requests() {
        let pill = MockPill()
        pill.name = "Cannabis"
        let not = DuePillNotification(for: pill, badge: 1, requestHandler: _testHandler)
        not.request()
        XCTAssertEqual(1, DuePillNotificationTests.testHandlerCallCount)
        DuePillNotificationTests.testHandlerCallCount = 0
    }
    
    func testRequests_whenDueDateIsNil_doesNotRequest() {
        let pill = MockPill()
        pill.due = nil
        pill.name = "Cannabis"
        let not = DuePillNotification(for: pill, badge: 1, requestHandler: _testHandler)
        not.request()
        XCTAssertEqual(0, DuePillNotificationTests.testHandlerCallCount)
    }
}
