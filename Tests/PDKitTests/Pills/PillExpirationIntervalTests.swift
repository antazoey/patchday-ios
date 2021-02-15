//
//  PillExpirationIntervalTests.swift
//  PDKit
//
//  Created by Juliya Smith on 2/6/21.

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
        XCTAssertNil(interval.xDaysValue)
    }

    func testInit_whenNotUsingXDaysIntervalAndGivenXDays_doesNotInitializeXDays() {
        let interval = PillExpirationInterval(.EveryDay, xDays: "5")
        XCTAssertNil(interval.xDaysValue)
    }

    func testInit_whenUsingXDaysIntervalAndNotGivenXDays_doesNotInitializeXDays() {
        let interval = PillExpirationInterval(.FirstXDays)
        XCTAssertNil(interval.xDaysValue)
    }

    func testInit_whenUsingXDaysIntervalAndGivenXDays_initializesXDaysWithExpectedDays() {
        let interval = PillExpirationInterval(.FirstXDays, xDays: "5")
        assertDaysOne(5, interval)
    }

    func testInit_whenUsingXDaysIntervalAndGivenXDaysForOnAndOff_initializesXDaysWithExpectedDays() {
        let interval = PillExpirationInterval(.FirstXDays, xDays: "5-8")
        assertDaysOne(5, interval)
        assertDaysTwo(8, interval)
    }

    func testInit_whenUsingXDaysOnXDaysOffAndGivenStartedXDaysForOnAndOff_initializesXDaysWithExpectedDays() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: "5-8-off-7")
        assertDaysOne(5, interval)
        assertDaysTwo(8, interval)
        assertPosition(7, false, interval)
    }

    func testInit_whenGivenUnstartedXDays_returnsNilForExpectedProperties() {
        let interval = PillExpirationInterval(.FirstXDays, xDays: "5-8")
        assertNilPosition(interval)
    }

    func testInit_whenGivenLegacyFirst10Days_migrates() {
        let interval = PillExpirationInterval("firstTenDays")
        XCTAssertEqual(.FirstXDays, interval.value)
        assertDaysOne(10, interval)
        assertNilDaysTwo(interval)
    }

    func testInit_whenGivenLegacyFirst20Days_migrates() {
        let interval = PillExpirationInterval("firstTwentyDays")
        XCTAssertEqual(.FirstXDays, interval.value)
        assertDaysOne(20, interval)
        assertNilDaysTwo(interval)
    }

    func testInit_whenGivenLegacyLast10Days_migrates() {
        let interval = PillExpirationInterval("lastTenDays")
        XCTAssertEqual(.LastXDays, interval.value)
        assertDaysOne(10, interval)
        assertNilDaysTwo(interval)
    }

    func testInit_whenGivenLegacyLast20Days_migrates() {
        let interval = PillExpirationInterval("lastTwentyDays")
        XCTAssertEqual(.LastXDays, interval.value)
        assertDaysOne(20, interval)
        assertNilDaysTwo(interval)
    }

    func testSetValue_setsValue() {
        let interval = PillExpirationInterval(.EveryDay)
        interval.value = .EveryOtherDay
        XCTAssertEqual(.EveryOtherDay, interval.value)
    }

    func testSetValue_whenSettingToNonXDaysValue_setsXDaysInstanceToNil() {
        let interval = PillExpirationInterval(.FirstXDays, xDays: "5-5-on-1")
        interval.value = .EveryDay
        XCTAssertNil(interval.xDaysValue)
    }

    func testSetValue_whenSettingFromXDaysOnXDaysOffToSingleXDays_setsDaysTwoToNil() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: "3-5-on-1")
        interval.value = .FirstXDays
        assertNilDaysTwo(interval)
        XCTAssertEqual("3-on-1", interval.xDaysValue)
    }

    func testXDaysValue_whenNotUsingXDays_returnsNil() {
        let interval = PillExpirationInterval(.EveryDay)
        interval.daysOne = 3
        XCTAssertNil(interval.xDaysValue)
    }

    func testXDaysValue_whenUsingXDays_returnsExpectedValue() {
        let interval = PillExpirationInterval(.FirstXDays)
        interval.daysOne = 3
        XCTAssertEqual("3", interval.xDaysValue)
    }

    func testDaysOne_whenInitializedWithoutXDays_returnsNil() {
        let interval = PillExpirationInterval(.FirstXDays)
        XCTAssertNil(interval.daysOne)
    }

    func testDaysOne_whenInitializedWithXDaysButSwitchedToNotUsingXDays_returnsNil() {
        let interval = PillExpirationInterval(.FirstXDays, xDays: "6")
        interval.value = .EveryDay
        XCTAssertNil(interval.daysOne)
    }

    func testDaysOneSet_whenXDaysPreviouslyInitialized_sets() {
        let interval = PillExpirationInterval(.FirstXDays, xDays: "6")
        interval.daysOne = 7
        XCTAssertEqual(7, interval.daysOne)
    }

    func testDaysOneSet_whenXDaysNotPreviouslyInitialized_sets() {
        let interval = PillExpirationInterval(.FirstXDays)
        interval.daysOne = 7
        XCTAssertEqual(7, interval.daysOne)
    }

    func testDaysOn_whenNotUsingXDays_returnsNil() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff)
        XCTAssertNil(interval.daysOn)
    }

    func testDaysTwo_whenInitializedWithoutXDays_returnsNil() {
        let interval = PillExpirationInterval(.FirstXDays)
        XCTAssertNil(interval.daysTwo)
    }

    func testDaysTwo_whenInitializedWithXDaysButSwitchedToNotUsingXDays_returnsNil() {
        let interval = PillExpirationInterval(.FirstXDays, xDays: "6")
        interval.value = .EveryDay
        XCTAssertNil(interval.daysTwo)
    }

    func testDaysTwoSet_whenXDaysPreviouslyInitialized_sets() {
        let interval = PillExpirationInterval(.FirstXDays, xDays: "6")
        interval.daysTwo = 7
        XCTAssertEqual(7, interval.daysTwo)
    }

    func testDaysTwoSet_whenXDaysNotPreviouslyInitializedAndSetsDaysOneFirst_sets() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff)
        interval.daysOne = 3
        interval.daysTwo = 7
        XCTAssertEqual(7, interval.daysTwo)
    }

    func testDaysTwoSet_whenXDaysNotPreviouslyInitializedAndDoesNotSetDaysOneAtAll_setsDayOne() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff)
        interval.daysTwo = 7
        XCTAssertEqual(7, interval.daysOne)
    }

    func testDaysOff_whenNotUsingXDays_returnsNil() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff)
        XCTAssertNil(interval.daysOff)
    }

    func testXDaysIsOn_whenNotUsingXDays_returnsNil() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff)
        XCTAssertNil(interval.xDaysIsOn)
    }

    func testXDaysIsOn_whenNotUsingXDaysOnXDaysOff_doesNotSet() {
        let interval = PillExpirationInterval(.FirstXDays, xDays: "10")
        interval.xDaysIsOn = true
        assertNilPosition(interval)
    }

    func testXDaysPosition_whenNotUsingXDays_returnsNil() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff)
        XCTAssertNil(interval.xDaysPosition)
    }

    func testXDaysPosition_whenNotUsingXDaysOnXDaysOff_doesNotSet() {
        let interval = PillExpirationInterval(.FirstXDays, xDays: "10")
        interval.xDaysPosition = 4
        assertNilPosition(interval)
    }

    func testXDaysPosition_whenUsingXDaysOnXDaysOff_sets() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: "10-10-on-3")
        interval.xDaysPosition = 4
        assertPosition(4, true, interval)
    }

    func testXDaysIsOnAndPosition_whenUsingXDaysAndSet_returnsExpectedValue() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: "5-5-on-1")
        assertPosition(1, true, interval)
    }

    func testStartPositioning_whenNotUsingXDays_doesNotStart() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: "5-5")
        interval.value = .EveryDay
        interval.startPositioning()
        assertNilPosition(interval)
    }

    func testStartPositioning_whenUsingXDays_starts() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: "5-5")
        interval.startPositioning()
        assertPosition(1, true, interval)
    }

    func testIncrementXDays_whenXDaysOnXDaysOffAndStartedAlready_increments() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: "5-5-on-2")
        interval.incrementXDays()
        assertPosition(3, true, interval)
    }

    func testIncrementXDays_whenNotXDaysOnXDaysOff_doesNothing() {
        let interval = PillExpirationInterval(.FirstXDays, xDays: "5")
        interval.incrementXDays()
        assertNilPosition(interval)
    }

    func testIncrementXDays_whenXDaysOnXDaysOffAndNotYetStarted_increments() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: "5-5")
        interval.incrementXDays()
        assertPosition(2, true, interval)
    }

    func testIncrementXDays_whenJustSwitchedToXDaysOnXDaysOff_increments() {
        let interval = PillExpirationInterval(.EveryDay)
        interval.value = .XDaysOnXDaysOff
        interval.incrementXDays()
        assertPosition(2, true, interval)
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

    func assertDaysOne(_ expected: Int, _ interval: PillExpirationInterval) {
        if interval.xDaysValue == nil {
            XCTFail("xDays did not initalize.")
            return
        }

        XCTAssertEqual(expected, interval.daysOne)
        XCTAssertEqual("\(expected)", interval.daysOn)
    }

    func assertDaysTwo(_ expected: Int, _ interval: PillExpirationInterval) {
        if interval.xDaysValue == nil {
            XCTFail("xDays did not initalize.")
            return
        }

        XCTAssertNotNil(interval.xDaysValue)
        XCTAssertEqual(expected, interval.daysTwo)
        XCTAssertEqual("\(expected)", interval.daysOff)
    }

    func assertNilDaysTwo(_ interval: PillExpirationInterval) {
        XCTAssertNil(interval.daysTwo)
        XCTAssertNil(interval.daysOff)
    }

    func assertPosition(
        _ expectedPos: Int, _ expectedBool: Bool, _ interval: PillExpirationInterval
    ) {
        if interval.xDaysIsOn == nil {
            XCTFail("XDays position is not turned on.")
            return
        } else if interval.xDaysPosition == nil {
            XCTFail("XDays position is not initialized.")
            return
        }
        XCTAssertEqual(expectedBool, interval.xDaysIsOn)
        XCTAssertEqual(expectedPos, interval.xDaysPosition!)
    }

    func assertNilPosition(_ interval: PillExpirationInterval) {
        XCTAssertNil(interval.xDaysIsOn)
        XCTAssertNil(interval.xDaysPosition)
    }
}
