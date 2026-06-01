//
//  ExpiredHormoneNotificationTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 4/27/20.

import XCTest
import PDKit
import PDTest

@testable
import PatchDay

class ExpiredHormoneNotificationTests: PDTestCase {

    private let _name = "Dat Ass Cheek"
    private let _oldName = "Dat Tummy"

    private static var testHandlerCallArgs: [(Double, String)] = []
    private let _testHandler: (Double, String) -> Void = {
        v, id in ExpiredHormoneNotificationTests.testHandlerCallArgs.append((v, id))
    }

    private func createHormone() -> MockHormone {
        let hormone = MockHormone()
        hormone.siteName = _oldName
        return hormone
    }

    func testInit_whenUsingPatchesAndMinutesBefore_hasExpectedProperties() {
        let hormone = createHormone()
        let notifyMin = Double(30)
        let not = ExpiredHormoneNotification(
            hormone: hormone,
            notifyMinutes: notifyMin,
            currentBadgeValue: 0,
            requestHandler: _testHandler
        )
        XCTAssertEqual("Time for your next patch", not.title)
        XCTAssertEqual("Expired Patch from previous site \(_oldName).", not.body)
    }

    func testInit_whenUsingInjectionsAndMinutesBefore_hasExpectedProperties() {
        let hormone = createHormone()
        hormone.deliveryMethod = .Injections
        let notifyMin = Double(30)

        let not = ExpiredHormoneNotification(
            hormone: hormone,
            notifyMinutes: notifyMin,
            currentBadgeValue: 0,
            requestHandler: _testHandler
        )

        XCTAssertEqual("Time for your next injection", not.title)
        XCTAssertEqual("Expired Injection from previous site \(_oldName).", not.body)
    }

    func testInit_whenUsingGelAndMinutesBefore_hasExpectedProperties() {
        let hormone = createHormone()
        hormone.deliveryMethod = .Gel
        let notifyMin = Double(30)

        let not = ExpiredHormoneNotification(
            hormone: hormone,
            notifyMinutes: notifyMin,
            currentBadgeValue: 0,
            requestHandler: _testHandler
        )

        XCTAssertEqual("Time for your gel", not.title)
        XCTAssertEqual("Expired Gel from previous site \(_oldName).", not.body)
    }

    func testRequest_callsHandlersWithExpectedArgs() {
        let hormone = MockHormone()
        hormone.date = Date()
        hormone.expirationInterval = ExpirationIntervalUD()
        let notifyMin = Double(30)
        let notification = ExpiredHormoneNotification(
            hormone: hormone,
            notifyMinutes: notifyMin,
            currentBadgeValue: 0,
            requestHandler: _testHandler
        )
        let hours = hormone.expirationInterval.hours
        let date = hormone.date
        let expected = DateFactory.createTimeInterval(fromAddingHours: hours, to: date)! - 30 * 60
        ExpiredHormoneNotificationTests.testHandlerCallArgs = []
        notification.request()
        let actual = ExpiredHormoneNotificationTests.testHandlerCallArgs[0].0
        PDAssertEquiv(expected, actual)
        XCTAssertEqual(
            hormone.id.uuidString, ExpiredHormoneNotificationTests.testHandlerCallArgs[0].1
        )
    }

    func testRequest_schedulesOnTimeAlertPlusFollowUpReminders() {
        let hormone = MockHormone()
        hormone.date = Date()
        hormone.expirationInterval = ExpirationIntervalUD()
        let notification = ExpiredHormoneNotification(
            hormone: hormone,
            notifyMinutes: 0,
            currentBadgeValue: 0,
            requestHandler: _testHandler
        )
        ExpiredHormoneNotificationTests.testHandlerCallArgs = []
        notification.request()
        let calls = ExpiredHormoneNotificationTests.testHandlerCallArgs
        // On-time alert + one request per follow-up offset.
        XCTAssertEqual(1 + ExpiredHormoneNotification.followUpOffsetsHours.count, calls.count)
        // First is the on-time alert under the plain hormone id.
        XCTAssertEqual(hormone.id.uuidString, calls[0].1)
        // Follow-ups use suffixed ids and fire later than the on-time alert.
        XCTAssertEqual("\(hormone.id.uuidString)#1", calls[1].1)
        XCTAssertTrue(calls[1].0 > calls[0].0)
    }

    func testRequest_whenHormoneHasNoDate_doesNotRequest() {
        let hormone = MockHormone()
        hormone.expirationInterval = ExpirationIntervalUD()
        let notifyMin = Double(30)

        let notification = ExpiredHormoneNotification(
            hormone: hormone,
            notifyMinutes: notifyMin,
            currentBadgeValue: 0,
            requestHandler: _testHandler
        )
        ExpiredHormoneNotificationTests.testHandlerCallArgs = []
        notification.request()
        PDAssertEmpty(ExpiredHormoneNotificationTests.testHandlerCallArgs)
    }
}
