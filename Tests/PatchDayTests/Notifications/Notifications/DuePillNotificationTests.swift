//
//  DuePillNotificationTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/1/20.

import XCTest
import PDKit
import PDTest

@testable
import PatchDay

class DuePillNotificationTests: XCTestCase {

    private static var testHandlerCallArgs: [(Double, String)] = []
    private let _testHandler: (Double, String) -> Void = {
        interval, id in DuePillNotificationTests.testHandlerCallArgs.append((interval, id))
    }

    func testInit_hasExpectedProperties() {
        let pill = MockPill()
        pill.due = Date()
        pill.name = "Cannabis"
        let not = DuePillNotification(for: pill, currentBadgeValue: 0, requestHandler: _testHandler)
        XCTAssertEqual("Time to take pill: Cannabis", not.title)
        XCTAssertNil(not.body)
    }

    func testRequest_requestsAtExpectedInterval() {
        let pill = MockPill()
        let dueDate = Date(timeInterval: 100, since: Date())
        pill.name = "Cannabis"
        pill.times = [dueDate]
        pill.due = dueDate
        let not = DuePillNotification(for: pill, currentBadgeValue: 0, requestHandler: _testHandler)
        not.request()
        let expected = dueDate.timeIntervalSince(Date())
        let actual = DuePillNotificationTests.testHandlerCallArgs[0].0
        XCTAssert(PDAssert.equiv(expected, actual))
    }

    func testRequest_whenDueDateIsNil_doesNotRequest() {
        let pill = MockPill()
        pill.due = nil
        pill.name = "Cannabis"
        let not = DuePillNotification(for: pill, currentBadgeValue: 0, requestHandler: _testHandler)
        DuePillNotificationTests.testHandlerCallArgs = []
        not.request()
        XCTAssertEqual(0, DuePillNotificationTests.testHandlerCallArgs.count)
    }

    func testRequest_whenDueDateIsInPast_doesNotRequest() {
        let pill = MockPill()
        let dueDate = Date(timeInterval: -100, since: Date())
        pill.name = "Cannabis"
        pill.times = [dueDate]
        pill.due = dueDate
        let not = DuePillNotification(for: pill, currentBadgeValue: 0, requestHandler: _testHandler)
        DuePillNotificationTests.testHandlerCallArgs = []
        not.request()
        XCTAssertEqual(0, DuePillNotificationTests.testHandlerCallArgs.count)
    }
}
