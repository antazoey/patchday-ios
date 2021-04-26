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
            timesTakenToday: nil,
            lastTaken: nil,
            todayLastTakensString: nil
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
            timesTakenToday: nil,
            lastTaken: nil,
            todayLastTakensString: nil
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
            timesTakenToday: nil,
            lastTaken: nil,
            todayLastTakensString: nil
        )
        let exclusions = PillAttributes(attributes)
        exclusions
            .name = "TEST"
        XCTAssertFalse(attributes.anyAttributeExists(exclusions: exclusions))
    }

    func testAnyAttributeExists_whenHasExpirationInterval_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: .EveryDay,
            xDays: nil,
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: nil,
            todayLastTakensString: nil
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
            timesTakenToday: nil,
            lastTaken: nil,
            todayLastTakensString: nil
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
            timesTakenToday: nil,
            lastTaken: nil,
            todayLastTakensString: nil
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
            timesTakenToday: nil,
            lastTaken: nil,
            todayLastTakensString: nil
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
            timesTakenToday: nil,
            lastTaken: nil,
            todayLastTakensString: nil
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
            timesTakenToday: nil,
            lastTaken: nil,
            todayLastTakensString: nil
        )
        let exclusions = PillAttributes(attributes)
        exclusions.notify = false
        XCTAssertFalse(attributes.anyAttributeExists(exclusions: exclusions))
    }

    func testAnyAttributeExists_whenHasTimesTakenToday_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            xDays: nil,
            times: nil,
            notify: nil,
            timesTakenToday: 0,
            lastTaken: nil,
            todayLastTakensString: nil
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_handlesExcludesTimesTakenToday() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            xDays: nil,
            times: nil,
            notify: nil,
            timesTakenToday: 3,
            lastTaken: nil,
            todayLastTakensString: nil
        )
        let exclusions = PillAttributes(attributes)
        XCTAssertFalse(attributes.anyAttributeExists(exclusions: exclusions))
    }

    func testAnyAttributeExists_whenHasLastTaken_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            xDays: nil,
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: Date(),
            todayLastTakensString: nil
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_handlesExcludedLastTaken() {
        let date = Date()
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            xDays: nil,
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: date,
            todayLastTakensString: nil
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
            timesTakenToday: nil,
            lastTaken: nil,
            todayLastTakensString: nil
        )
        let exclusions = PillAttributes(attributes)
        XCTAssertFalse(attributes.anyAttributeExists(exclusions: exclusions))
    }

    func testAnyAttributeExists_handlesExcludedTodayLastTakens() {
        let lastTakensString = PDDateFormatter.formatDate(Date())
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            xDays: nil,
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: nil,
            todayLastTakensString: lastTakensString
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
            timesTakenToday: 4,
            lastTaken: Date(),
            todayLastTakensString: nil
        )
        attributes.reset()
        XCTAssertNil(attributes.name)
        XCTAssertNil(attributes.expirationInterval.value)
        XCTAssertNil(attributes.times)
        XCTAssertNil(attributes.notify)
        XCTAssertNil(attributes.timesTakenToday)
        XCTAssertNil(attributes.lastTaken)
        XCTAssertNil(attributes.expirationInterval.xDaysValue)
        XCTAssertNil(attributes.todayLastTakensString)
    }
}
