//
//  PillAttributeTests.swift
//  PDKit
//
//  Created by Juliya Smith on 2/7/21.

import Foundation

import XCTest
import PDTest
@testable
import PDKit

class PillAttributesTests: PDTestCase {

    func testAnyAttributeExists_whenHasNoProps_returnsFalse() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            xDays: nil,
            times: nil,
            notify: nil,
            lastTaken: nil,
            timesTakenToday: nil,
            lastWakeUp: nil,
            isCreated: nil
        )
        XCTAssertFalse(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_whenHasName_returnsTrue() {
        let attributes = PillAttributes(
            name: "TEST",
            expirationIntervalSetting: nil,
            xDays: nil,
            times: nil,
            notify: nil,
            lastTaken: nil,
            timesTakenToday: nil,
            lastWakeUp: nil,
            isCreated: nil
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_handlesExcludedName() {
        let attributes = PillAttributes(
            name: "TEST",
            expirationIntervalSetting: nil,
            xDays: nil,
            times: nil,
            notify: nil,
            lastTaken: nil,
            timesTakenToday: nil,
            lastWakeUp: nil,
            isCreated: nil
        )
        let exclusions = PillAttributes(attributes)
        exclusions.name = "TEST"
        XCTAssertFalse(attributes.anyAttributeExists(exclusions: exclusions))
    }

    func testAnyAttributeExists_whenHasExpirationInterval_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: .EveryDay,
            xDays: nil,
            times: nil,
            notify: nil,
            lastTaken: nil,
            timesTakenToday: nil,
            lastWakeUp: nil,
            isCreated: nil
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_handlesExcludedExpirationInterval() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: .EveryDay,
            xDays: nil,
            times: nil,
            notify: nil,
            lastTaken: nil,
            timesTakenToday: nil,
            lastWakeUp: nil,
            isCreated: nil
        )
        let exclusions = PillAttributes(attributes)
        exclusions.expirationInterval.value = .EveryDay
        XCTAssertFalse(attributes.anyAttributeExists(exclusions: exclusions))
    }

    func testAnyAttributeExists_whenHasTimes_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            xDays: nil,
            times: "12:30",
            notify: nil,
            lastTaken: nil,
            timesTakenToday: nil,
            lastWakeUp: nil,
            isCreated: nil
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_handlesExcludedTimes() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            xDays: nil,
            times: "12:30",
            notify: nil,
            lastTaken: nil,
            timesTakenToday: nil,
            lastWakeUp: nil,
            isCreated: nil
        )
        let exclusions = PillAttributes(attributes)
        exclusions.times = "12:30"
        XCTAssertFalse(attributes.anyAttributeExists(exclusions: exclusions))
    }

    func testAnyAttributeExists_whenHasNotify_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            xDays: nil,
            times: nil,
            notify: false,
            lastTaken: nil,
            timesTakenToday: nil,
            lastWakeUp: nil,
            isCreated: nil
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_handlesExcludedNotify() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            xDays: nil,
            times: nil,
            notify: false,
            lastTaken: nil,
            timesTakenToday: nil,
            lastWakeUp: nil,
            isCreated: nil
        )
        let exclusions = PillAttributes(attributes)
        exclusions.notify = false
        XCTAssertFalse(attributes.anyAttributeExists(exclusions: exclusions))
    }

    func testAnyAttributeExists_whenHasLastTaken_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            xDays: nil,
            times: nil,
            notify: nil,
            lastTaken: Date(),
            timesTakenToday: nil,
            lastWakeUp: nil,
            isCreated: nil
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_whenHasTimesTakenToday_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            xDays: nil,
            times: nil,
            notify: nil,
            lastTaken: nil,
            timesTakenToday: "",
            lastWakeUp: nil,
            isCreated: nil
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_whenHasLastWakeUp_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            xDays: nil,
            times: nil,
            notify: nil,
            lastTaken: nil,
            timesTakenToday: nil,
            lastWakeUp: Date(),
            isCreated: nil
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_whenHasIsCreated_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            xDays: nil,
            times: nil,
            notify: nil,
            lastTaken: nil,
            timesTakenToday: nil,
            lastWakeUp: nil,
            isCreated: false
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_handlesExcludedTimesTakenToday() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            xDays: nil,
            times: nil,
            notify: nil,
            lastTaken: nil,
            timesTakenToday: "12:00:00,12:00:01,12:00:02",
            lastWakeUp: nil,
            isCreated: nil
        )
        let exclusions = PillAttributes(attributes)
        XCTAssertFalse(attributes.anyAttributeExists(exclusions: exclusions))
    }

    func testAnyAttributeExists_handlesExcludedLastTaken() {
        let date = Date()
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            xDays: nil,
            times: nil,
            notify: nil,
            lastTaken: date,
            timesTakenToday: nil,
            lastWakeUp: nil,
            isCreated: nil
        )
        let exclusions = PillAttributes(attributes)
        XCTAssertFalse(attributes.anyAttributeExists(exclusions: exclusions))
    }

    func testAnyAttributeExists_handlesExcludedXDays() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: .FirstXDays,
            xDays: "1",
            times: nil,
            notify: nil,
            lastTaken: nil,
            timesTakenToday: nil,
            lastWakeUp: nil,
            isCreated: nil
        )
        let exclusions = PillAttributes(attributes)
        XCTAssertFalse(attributes.anyAttributeExists(exclusions: exclusions))
    }

    func testAnyAttributeExists_handlesExcludedLastWakeUp() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: .FirstXDays,
            xDays: nil,
            times: nil,
            notify: nil,
            lastTaken: nil,
            timesTakenToday: nil,
            lastWakeUp: Date(),
            isCreated: nil
        )
        let exclusions = PillAttributes(attributes)
        XCTAssertFalse(attributes.anyAttributeExists(exclusions: exclusions))
    }

    func testAnyAttributeExists_handlesExcludedIsCreated() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: .FirstXDays,
            xDays: nil,
            times: nil,
            notify: nil,
            lastTaken: nil,
            timesTakenToday: nil,
            lastWakeUp: nil,
            isCreated: true
        )
        let exclusions = PillAttributes(attributes)
        XCTAssertFalse(attributes.anyAttributeExists(exclusions: exclusions))
    }

    func testUpdate_updates() {
        let attributes = PillAttributes(
            name: "Old",
            expirationIntervalSetting: .FirstXDays,
            xDays: nil,
            times: "23:00:33,23:11:11",
            notify: false,
            lastTaken: DateFactory.createDate(byAddingHours: -3, to: Date()),
            timesTakenToday: "23:00:33,23:11:11",
            lastWakeUp: Date(),
            isCreated: true
        )
        let newName = "New"
        let newInterval = PillExpirationIntervalSetting.XDaysOnXDaysOff
        let newXDays = "12-12-on-3"
        let newLastTaken = Date()
        let newTimes = "12:00:11,3:03:03"
        let newTimesTakenToday = "23:33:33,23:22:11"
        let newLastWakeUp = DateFactory.createDate(byAddingHours: 3, to: Date())
        let newAttributes = PillAttributes(
            name: newName,
            expirationIntervalSetting: newInterval,
            xDays: newXDays,
            times: newTimes,
            notify: true,
            lastTaken: newLastTaken,
            timesTakenToday: newTimesTakenToday,
            lastWakeUp: newLastWakeUp,
            isCreated: false
        )
        attributes.update(newAttributes)
        XCTAssertEqual(newName, attributes.name)
        XCTAssertEqual(newInterval, attributes.expirationInterval.value)
        XCTAssertEqual(newXDays, attributes.expirationInterval.xDaysValue)
        XCTAssertTrue(attributes.notify ?? false)
        XCTAssertEqual(newLastTaken, attributes.lastTaken)
        XCTAssertEqual(newTimes, attributes.times)
        XCTAssertEqual(newTimesTakenToday, attributes.timesTakenToday)
        XCTAssertEqual(newLastWakeUp, attributes.lastWakeUp)
        XCTAssertFalse(attributes.isCreated ?? true)
    }

    func testReset_resetsAllPropertiesToNil() {
        let attributes = PillAttributes(
            name: "name",
            expirationIntervalSetting: .EveryDay,
            xDays: "7",
            times: "1200",
            notify: true,
            lastTaken: Date(),
            timesTakenToday: "12:00:00",
            lastWakeUp: Date(),
            isCreated: true
        )
        attributes.reset()
        XCTAssertNil(attributes.name)
        XCTAssertNil(attributes.expirationInterval.value)
        XCTAssertNil(attributes.times)
        XCTAssertNil(attributes.notify)
        XCTAssertNil(attributes.timesTakenToday)
        XCTAssertNil(attributes.lastTaken)
        XCTAssertNil(attributes.expirationInterval.xDaysValue)
        XCTAssertNil(attributes.lastWakeUp)
        XCTAssertNil(attributes.isCreated)
    }
}
