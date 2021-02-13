//
//  PillExpirationIntervalTests.swift
//  PDKit
//
//  Created by Juliya Smith on 2/6/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
@testable
import PDKit

class PillExpirationIntervalTests: XCTestCase {

    func testInit_initsValue() {
        let interval = PillExpirationInterval(.EveryDay)
        XCTAssertEqual(.EveryDay, interval.value)
    }

    func testInit_whenNotUsingXDaysInterval_doesNotInitializeXDays() {
        let interval = PillExpirationInterval(.EveryDay)
        XCTAssertNil(interval.xDays)
    }

    func testInit_whenNotUsingXDaysIntervalAndGivenXDays_doesNotInitializeXDays() {
        let interval = PillExpirationInterval(.EveryDay, xDays: "5")
        XCTAssertNil(interval.xDays)
    }

    func testInit_whenUsingXDaysIntervalAndNotGivenXDays_doesNotInitializeXDays() {
        let interval = PillExpirationInterval(.FirstXDays)
        XCTAssertNil(interval.xDays)
    }

    func testInit_whenUsingXDaysIntervalAndGivenXDays_initializesXDaysWithExpectedDays() {
        let interval = PillExpirationInterval(.FirstXDays, xDays: "5")
        XCTAssertNotNil(interval.xDays)
        XCTAssertEqual("5", interval.xDays?.daysOn)
        XCTAssertEqual(5, interval.xDays?.one)
    }

    func testInit_whenUsingXDaysIntervalAndGivenXDaysForOnAndOff_initializesXDaysWithExpectedDays() {
        let interval = PillExpirationInterval(.FirstXDays, xDays: "5-8")
        if interval.xDays == nil {
            XCTFail("xDays did not initalize.")
            return
        }

        let xDays = interval.xDays!
        XCTAssertEqual("5", xDays.daysOn)
        XCTAssertEqual(5, xDays.one)
        XCTAssertEqual("8", xDays.daysOff)
        XCTAssertEqual(8, xDays.two)
    }

    func testInit_whenUsingXDaysIntervalAndGivenStartedXDaysForOnAndOff_initializesXDaysWithExpectedDays() {
        let interval = PillExpirationInterval(.FirstXDays, xDays: "5-8-off-7")
        if interval.xDays == nil {
            XCTFail("xDays did not initalize.")
            return
        }

        let xDays = interval.xDays!
        XCTAssertEqual("5", xDays.daysOn)
        XCTAssertEqual(5, xDays.one)
        XCTAssertEqual("8", xDays.daysOff)
        XCTAssertEqual(8, xDays.two)
        XCTAssertFalse(xDays.isOn!)
        XCTAssertEqual(7, xDays.position!)
    }

    func testInit_whenGivenUnstartedXDays_returnsNilForExpectedProperties() {
        let interval = PillExpirationInterval(.FirstXDays, xDays: "5-8")
        if interval.xDays == nil {
            XCTFail("xDays did not initalize.")
            return
        }

        let xDays = interval.xDays!
        XCTAssertNil(xDays.isOn)
        XCTAssertNil(xDays.position)
    }

    func testInit_whenGivenLegacyFirst10Days_migrates() {
        let interval = PillExpirationInterval("firstTenDays")
        XCTAssertEqual(.FirstXDays, interval.value)
        XCTAssertEqual(10, interval.xDays?.one)
        XCTAssertEqual("10", interval.xDays?.daysOn)
        XCTAssertNil(interval.xDays?.daysOff)
    }

    func testInit_whenGivenLegacyFirst20Days_migrates() {
        let interval = PillExpirationInterval("firstTwentyDays")
        XCTAssertEqual(.FirstXDays, interval.value)
        XCTAssertEqual(20, interval.xDays?.one)
        XCTAssertEqual("20", interval.xDays?.daysOn)
        XCTAssertNil(interval.xDays?.daysOff)
    }

    func testInit_whenGivenLegacyLast10Days_migrates() {
        let interval = PillExpirationInterval("lastTenDays")
        XCTAssertEqual(.LastXDays, interval.value)
        XCTAssertEqual(10, interval.xDays?.one)
        XCTAssertEqual("10", interval.xDays?.daysOn)
        XCTAssertNil(interval.xDays?.daysOff)
    }

    func testInit_whenGivenLegacyLast20Days_migrates() {
        let interval = PillExpirationInterval("lastTwentyDays")
        XCTAssertEqual(.LastXDays, interval.value)
        XCTAssertEqual(20, interval.xDays?.one)
        XCTAssertEqual("20", interval.xDays?.daysOn)
        XCTAssertNil(interval.xDays?.daysOff)
    }

    func testSetValue_setsValue() {
        let interval = PillExpirationInterval(.EveryDay)
        interval.value = .EveryOtherDay
        XCTAssertEqual(.EveryOtherDay, interval.value)
    }

    func testSetValue_whenSettingToNonXDaysValue_setsXDaysInstanceToNil() {
        let interval = PillExpirationInterval(.FirstXDays, xDays: "5-5-on-1")
        interval.value = .EveryDay
        XCTAssertNil(interval.xDays)
    }

    func testSetValue_whenSettingFromXDaysOnXDaysOffToSingleXDays_setsDaysTwoToNil() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: "3-5-on-1")
        interval.value = .FirstXDays
        let xDays = interval.xDays!
        XCTAssertNil(xDays.two)
        XCTAssertNil(xDays.daysOff)
        let expected = "3-on-1"
        XCTAssertEqual(expected, xDays.value)
    }

    func testOptions_containsAllOptions() {
        // WAIT: If this test did not compile for you, that means you are adding a new interval.
        // I just want to remind you to make sure to also add that interval to the static list
        // `PillExpirationInterval.options`.
        for opt in PillExpirationInterval.options {
            switch opt {
                case .EveryDay: break
                case .EveryOtherDay: break
                case .FirstXDays: break
                case .LastXDays: break
                case .XDaysOnXDaysOff: break
            }
        }
    }
}
