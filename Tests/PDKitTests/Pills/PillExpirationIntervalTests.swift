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

    func testInit_whenGivenModernValue_initsExpectedly() {
        let interval = PillExpirationInterval(.EveryDay)
        XCTAssertEqual(.EveryDay, interval.value)
    }

    func testInit_whenGivenLegacyFirst10Days_migrates() {
        let interval = PillExpirationInterval("firstTenDays")
        XCTAssertEqual(.FirstXDays, interval.value)
        XCTAssertEqual(10, interval.daysOne)
        XCTAssertEqual("10", interval.daysOn)
        XCTAssertNil(interval.daysOff)
    }

    func testInit_whenGivenLegacyFirst20Days_migrates() {
        let interval = PillExpirationInterval("firstTwentyDays")
        XCTAssertEqual(.FirstXDays, interval.value)
        XCTAssertEqual(20, interval.daysOne)
        XCTAssertEqual("20", interval.daysOn)
        XCTAssertNil(interval.daysOff)
    }

    func testInit_whenGivenLegacyLast10Days_migrates() {
        let interval = PillExpirationInterval("lastTenDays")
        XCTAssertEqual(.LastXDays, interval.value)
        XCTAssertEqual(10, interval.daysOne)
        XCTAssertEqual("10", interval.daysOn)
    }

    func testInit_whenGivenLegacyLast20Days_migrates() {
        let interval = PillExpirationInterval("lastTwentyDays")
        XCTAssertEqual(.LastXDays, interval.value)
        XCTAssertEqual(20, interval.daysOne)
        XCTAssertEqual("20", interval.daysOn)
    }

    func testInit_whenGivenFirstXDaysAndOutOfBoundsXDays_setToNil() {
        let interval = PillExpirationInterval(.FirstXDays, xDays: "80")
        XCTAssertEqual(.FirstXDays, interval.value)
        XCTAssertNil(interval.daysOne)
        XCTAssertNil(interval.daysOn)
        XCTAssertNil(interval.daysTwo)
        XCTAssertNil(interval.daysOff)
    }

    func testInit_whenGivenLastXDaysAndOutOfBoundsXDays_setsToNil() {
        let interval = PillExpirationInterval(.LastXDays, xDays: "80")
        XCTAssertEqual(.LastXDays, interval.value)
        XCTAssertNil(interval.daysOne)
        XCTAssertNil(interval.daysOff)
        XCTAssertNil(interval.daysTwo)
        XCTAssertNil(interval.daysOff)
    }

    func testInit_whenGivenXDaysOnXDaysOffAndXDaysWithTwoValues_returnsObjectWithExpectedProperties() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: "5-8")
        XCTAssertEqual(.XDaysOnXDaysOff, interval.value)
        XCTAssertEqual(5, interval.daysOne)
        XCTAssertEqual("5", interval.daysOn)
        XCTAssertEqual(8, interval.daysTwo)
        XCTAssertEqual("8", interval.daysOff)
    }

    func testInit_whenGivenXDaysOnXDaysOffAndDaysOneIncludesOutOfBoundsValue_usesNil() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: "50-8")
        XCTAssertEqual(.XDaysOnXDaysOff, interval.value)
        XCTAssertNil(interval.daysOne)
        XCTAssertNil(interval.daysOn)
    }

    func testInit_whenGivenXDaysOnXDaysOffAndDaysTwoIncludesOutOfBoundsValue_usesDefaultValue() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: "5-80")
        XCTAssertEqual(.XDaysOnXDaysOff, interval.value)
        XCTAssertNil(interval.daysTwo)
        XCTAssertNil(interval.daysOff)
    }

    func testInit_whenGivenXDaysOnXDaysOffAndXDaysWithOneValue_usesDefaultAsSecondValue() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: "5")
        XCTAssertEqual(.XDaysOnXDaysOff, interval.value)
        XCTAssertEqual(5, interval.daysOne)
        XCTAssertEqual("5", interval.daysOn)
        XCTAssertNil(interval.daysTwo)
        XCTAssertNil(interval.daysOff)
    }

    func testDaysOne_cannotBeSetOutsideLimit() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: "5-13")
        interval.daysOne = 3
        interval.daysOne = -1
        XCTAssertEqual(3, interval.daysOne)
        interval.daysOne = 26
        XCTAssertEqual(3, interval.daysOne)
    }

    func testDaysTwo_cannotBeSetOutsideLimit() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: "5-13")
        interval.daysTwo = 3
        interval.daysTwo = -1
        XCTAssertEqual(3, interval.daysTwo)
        interval.daysTwo = 26
        XCTAssertEqual(3, interval.daysTwo)
    }

    func testXDays_whenNoChanges_isSameValueAsInitialized() {
        let expected = "5-13"
        let interval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: expected)
        let actual = interval.xDays
        XCTAssertEqual(expected, actual)
    }

    func testXDays_reflectsSetDays() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: "5-13")
        interval.daysOne = 3
        let expected = "3-13"
        let actual = interval.xDays
        XCTAssertEqual(expected, actual)
    }

    func testXDays_whenDaysOneSetOutOfRange_doesNotSet() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: "5-13")
        interval.daysOne = 30
        let expected = "5-13"
        let actual = interval.xDays
        XCTAssertEqual(expected, actual)
    }

    func testXDays_whenDaysTwoSetOutOfRange_doesNotSet() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: "5-13")
        interval.daysTwo = 30
        let expected = "5-13"
        let actual = interval.xDays
        XCTAssertEqual(expected, actual)
    }

    func testXDays_whenFirstXDays_returnsStringDays() {
        let interval = PillExpirationInterval(.FirstXDays, xDays: "5")
        let expected = "5"
        let actual = interval.xDays
        XCTAssertEqual(expected, actual)
    }

    func testXDays_whenLastXDays_returnsStringDays() {
        let interval = PillExpirationInterval(.LastXDays, xDays: "5")
        let expected = "5"
        let actual = interval.xDays
        XCTAssertEqual(expected, actual)
    }

    func testXDays_whenNonXDaysInterval_returnsNil() {
        let interval = PillExpirationInterval(.EveryDay, xDays: "5")
        XCTAssertNil(interval.xDays)
    }

    func testXDays_whenSingleXDaysValueAndInitializedWithMultiple_() {
        let interval = PillExpirationInterval(.LastXDays, xDays: "8-8")
        let expected = "8"
        let actual = interval.xDays
        XCTAssertEqual(expected, actual)
    }

    func testXDays_whenMultipleXDaysAndGivenSingle_doesNotIncludeSecond() {
        let interval = PillExpirationInterval(.XDaysOnXDaysOff, xDays: "8")
        let expected = "8"
        let actual = interval.xDays
        XCTAssertEqual(expected, actual)
    }
}
