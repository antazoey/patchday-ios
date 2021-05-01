//
//  PillAttributeTests.swift
//  PDKit
//
//  Created by Juliya Smith on 2/7/21.

import Foundation

import XCTest
@testable
import PDKit

class PillAttributesTests: XCTestCase {

    func testAnyAttributeExists_whenHasNoProps_returnsFalse() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            xDays: nil,
            times: nil,
            notify: nil,
            lastTaken: nil,
            timesTakenToday: nil
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
            timesTakenToday: nil
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
            timesTakenToday: nil
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
            timesTakenToday: nil
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
            timesTakenToday: nil
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
            timesTakenToday: nil
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
            timesTakenToday: nil
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
            timesTakenToday: nil
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
            timesTakenToday: nil
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
            timesTakenToday: nil
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
            timesTakenToday: ""
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
            timesTakenToday: "12:00:00,12:00:01,12:00:02"
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
            timesTakenToday: nil
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
            timesTakenToday: nil
        )
        let exclusions = PillAttributes(attributes)
        XCTAssertFalse(attributes.anyAttributeExists(exclusions: exclusions))
    }

    func testReset_resetsAllPropertiesToNil() {
        let attributes = PillAttributes(
            name: "name",
            expirationIntervalSetting: .EveryDay,
            xDays: "7",
            times: "1200",
            notify: true,
            lastTaken: Date(),
            timesTakenToday: "12:00:00"
        )
        attributes.reset()
        XCTAssertNil(attributes.name)
        XCTAssertNil(attributes.expirationInterval.value)
        XCTAssertNil(attributes.times)
        XCTAssertNil(attributes.notify)
        XCTAssertNil(attributes.timesTakenToday)
        XCTAssertNil(attributes.lastTaken)
        XCTAssertNil(attributes.expirationInterval.xDaysValue)
    }
}
