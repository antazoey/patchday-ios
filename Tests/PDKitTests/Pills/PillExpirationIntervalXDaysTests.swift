//
//  PillExpirationIntervalXDaysTests.swift
//  PDKit
//
//  Created by Juliya Smith on 2/9/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

import Foundation

import XCTest
@testable
import PDKit

class PillExpirationIntervalXDaysTests: XCTestCase {

    func testInit_whenGivenTwoValues_returnsObjectWithExpectedProperties() {
        let xDays = PillExpirationIntervalXDays("5-8")
        XCTAssertEqual(5, xDays.one)
        XCTAssertEqual("5", xDays.daysOn)
        XCTAssertEqual(8, xDays.two)
        XCTAssertEqual("8", xDays.daysOff)
    }

    func testInit_whenGivenAStartedSchedule_returnsExpectedProperties() {
        let xDays = PillExpirationIntervalXDays("5-8-on-3")
        XCTAssertEqual(5, xDays.one)
        XCTAssertEqual("5", xDays.daysOn)
        XCTAssertEqual(8, xDays.two)
        XCTAssertEqual("8", xDays.daysOff)
        XCTAssert(xDays.isOn)
        XCTAssertEqual(3, xDays.position)
    }

    func testInit_whenGivenSingleOutBoundsString_setsToDefault() {
        let xDays = PillExpirationIntervalXDays("80")
        XCTAssertEqual(12, xDays.one)
        XCTAssertEqual("12", xDays.daysOn)
        XCTAssertNil(xDays.daysOff)
        XCTAssertNil(xDays.two)
    }

    func testInit_whenGivenDoubleOutBoundsString_setsToDefault() {
        let xDays = PillExpirationIntervalXDays("80-80")
        XCTAssertEqual(12, xDays.one)
        XCTAssertEqual("12", xDays.daysOn)
        XCTAssertNil(xDays.daysOff)
        XCTAssertNil(xDays.two)
    }

    func testInit_whenGivenDoubleStringWithFirstOneOutOfBounds_usesDefault() {
        let xDays = PillExpirationIntervalXDays("50-8")
        XCTAssertEqual(12, xDays.one)
        XCTAssertEqual("12", xDays.daysOn)
        XCTAssertEqual(8, xDays.two)
        XCTAssertEqual("8", xDays.daysOff)
    }

    func testInit_whenGivenDoubleStringWithSecondOneOutOfBounds_usesDefaultValue() {
        let xDays = PillExpirationIntervalXDays("5-80")
        XCTAssertEqual(5, xDays.one)
        XCTAssertEqual("5", xDays.daysOn)
        XCTAssertNil(xDays.daysOff)
        XCTAssertNil(xDays.two)
    }

    func testInit_whenGivenStartedDoubleOutBoundsString_setsToDefault() {
        let xDays = PillExpirationIntervalXDays("80-80-on-3")
        XCTAssertEqual(12, xDays.one)
        XCTAssertEqual("12", xDays.daysOn)
        XCTAssertNil(xDays.daysOff)
        XCTAssertNil(xDays.two)
    }

    func testIsOn_whenInitWithOn_returnsTrue() {
        let xDays = PillExpirationIntervalXDays("5-13-on-1")
        XCTAssert(xDays.isOn)
    }

    func testIsOn_whenInitWithOff_returnsFalse() {
        let xDays = PillExpirationIntervalXDays("5-13-off-1")
        XCTAssertFalse(xDays.isOn)
    }

    func testValue_whenInitializedWithoutPosition_includesStartPosition() {
        let expected = "5-13-on-1"
        let xDays = PillExpirationIntervalXDays("5-13")
        let actual = xDays.value
        XCTAssertEqual(expected, actual)
    }

    func testValue_reflectsUpdates() {
        let expected = "3-9-on-1"
        let xDays = PillExpirationIntervalXDays("5-13-on-1")
        xDays.one = 3
        xDays.two = 9
        let actual = xDays.value
        XCTAssertEqual(expected, actual)
    }

    func testDaysOne_cannotBeSetOutsideLimit() {
        let xDays = PillExpirationIntervalXDays("5-13")
        xDays.one = -1
        XCTAssertEqual(5, xDays.one)
        xDays.one = 26
        XCTAssertEqual(5, xDays.one)
    }

    func testDaysOne_canBeSetWithinTheLimit() {
        let xDays = PillExpirationIntervalXDays("5-13")
        xDays.one = 6
        XCTAssertEqual(6, xDays.one)
        xDays.one = 2
        XCTAssertEqual(2, xDays.one)
    }

    func testDaysTwo_whenValueIsOutOfBound_canBeSet() {
        let xDays = PillExpirationIntervalXDays("5-13")
        xDays.two = -1
        XCTAssertEqual(13, xDays.two)
        xDays.two = 26
        XCTAssertEqual(13, xDays.two)
    }

    func testDaysTwo_whenValueIsInBounds_canBeSet() {
        let xDays = PillExpirationIntervalXDays("5-13")
        xDays.two = 3
        XCTAssertEqual(3, xDays.two)
        xDays.two = 5
        XCTAssertEqual(5, xDays.two)
    }
}
