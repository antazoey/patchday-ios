//
//  PillAttributeTests.swift
//  PDKit
//
//  Created by Juliya Smith on 2/7/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
@testable
import PDKit

class PillAttributesTests: XCTestCase {

    func testXDays_ifNilReturnsXDaysFromInterval() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: .FirstXDays,
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: nil
        )
        attributes.expirationInterval.daysOne = 4
        XCTAssertEqual("4", attributes.xDays)
    }

    func testAnyAttributeExists_whenHasNoProps_returnsFalse() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: nil
        )
        XCTAssertFalse(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_whenHasName_returnsTrue() {
        let attributes = PillAttributes(
            name: "TEST",
            expirationIntervalSetting: nil,
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: nil
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_handlesExcludedName() {
        let attributes = PillAttributes(
            name: "TEST",
            expirationIntervalSetting: nil,
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: nil
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
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: nil
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_handlesExcludedExpirationInterval() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: .EveryDay,
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: nil
        )
        let exclusions = PillAttributes(attributes)
        exclusions.expirationInterval.value = .EveryDay
        XCTAssertFalse(attributes.anyAttributeExists(exclusions: exclusions))
    }

    func testAnyAttributeExists_whenHasTimes_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            times: "12:30",
            notify: nil,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: nil
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_handlesExcludedTimes() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            times: "12:30",
            notify: nil,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: nil
        )
        let exclusions = PillAttributes(attributes)
        exclusions.times = "12:30"
        XCTAssertFalse(attributes.anyAttributeExists(exclusions: exclusions))
    }

    func testAnyAttributeExists_whenHasNotify_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            times: nil,
            notify: false,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: nil
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_handlesExcludedNotify() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            times: nil,
            notify: false,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: nil
        )
        let exclusions = PillAttributes(attributes)
        exclusions.notify = false
        XCTAssertFalse(attributes.anyAttributeExists(exclusions: exclusions))
    }

    func testAnyAttributeExists_whenHasTimesTakenToday_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            times: nil,
            notify: nil,
            timesTakenToday: 0,
            lastTaken: nil,
            xDays: nil
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_handlesExcludesTimesTakenToday() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            times: nil,
            notify: nil,
            timesTakenToday: 3,
            lastTaken: nil,
            xDays: nil
        )
        let exclusions = PillAttributes(attributes)
        exclusions.timesTakenToday = 3
        XCTAssertFalse(attributes.anyAttributeExists(exclusions: exclusions))
    }

    func testAnyAttributeExists_whenHasLastTaken_returnsTrue() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: Date(),
            xDays: nil
        )
        XCTAssert(attributes.anyAttributeExists())
    }

    func testAnyAttributeExists_handlesExcludedLastTaken() {
        let date = Date()
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: nil,
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: date,
            xDays: nil
        )
        let exclusions = PillAttributes(attributes)
        exclusions.lastTaken = date
        XCTAssertFalse(attributes.anyAttributeExists(exclusions: exclusions))
    }

    func testAnyAttributeExists_handlesExcludedXDays() {
        let attributes = PillAttributes(
            name: nil,
            expirationIntervalSetting: .FirstXDays,
            times: nil,
            notify: nil,
            timesTakenToday: nil,
            lastTaken: nil,
            xDays: "1"
        )
        let exclusions = PillAttributes(attributes)
        exclusions.expirationInterval.daysOne = 1
        XCTAssertFalse(attributes.anyAttributeExists(exclusions: exclusions))
    }

    func testReset_resetsAllPropertiesToNil() {
        let attributes = PillAttributes(
            name: "name",
            expirationIntervalSetting: .EveryDay,
            times: "1200",
            notify: true,
            timesTakenToday: 4,
            lastTaken: Date(),
            xDays: "7"
        )
        attributes.reset()
        XCTAssertNil(attributes.name)
        XCTAssertNil(attributes.expirationIntervalSetting)
        XCTAssertNil(attributes.times)
        XCTAssertNil(attributes.notify)
        XCTAssertNil(attributes.timesTakenToday)
        XCTAssertNil(attributes.lastTaken)
        XCTAssertNil(attributes.xDays)
    }
}
