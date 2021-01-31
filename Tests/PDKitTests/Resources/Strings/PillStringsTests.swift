//
//  PillStringsTests.swift
//  PatchDay
//
//  Created by Juliya Smith on 1/31/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
@testable
import PDKit

class PillStringsTests: XCTestCase {

    func testGetIntervalFromString_whenEveryDay_returnsExpectedInterval() {
        let interval = PillStrings.Intervals.EveryDay
        let actual = PillStrings.Intervals.getIntervalFromString(interval)
        let expected = PillExpirationInterval.EveryDay
        XCTAssertEqual(expected, actual)
    }

    func testGetIntervalFromString_whenEveryOtherDay_returnsExpectedInterval() {
        let interval = PillStrings.Intervals.EveryOtherDay
        let actual = PillStrings.Intervals.getIntervalFromString(interval)
        let expected = PillExpirationInterval.EveryOtherDay
        XCTAssertEqual(expected, actual)
    }

    func testGetIntervalFromString_whenFirstTenDays_returnsExpectedInterval() {
        let interval = PillStrings.Intervals.FirstTenDays
        let actual = PillStrings.Intervals.getIntervalFromString(interval)
        let expected = PillExpirationInterval.FirstTenDays
        XCTAssertEqual(expected, actual)
    }

    func testGetIntervalFromString_whenFirstTwentyDays_returnsExpectedInterval() {
        let interval = PillStrings.Intervals.FirstTwentyDays
        let actual = PillStrings.Intervals.getIntervalFromString(interval)
        let expected = PillExpirationInterval.FirstTwentyDays
        XCTAssertEqual(expected, actual)
    }

    func testGetIntervalFromString_whenLastTenDays_returnsExpectedInterval() {
        let interval = PillStrings.Intervals.LastTenDays
        let actual = PillStrings.Intervals.getIntervalFromString(interval)
        let expected = PillExpirationInterval.LastTenDays
        XCTAssertEqual(expected, actual)
    }

    func testGetIntervalFromString_whenLastTwentyDays_returnsExpectedInterval() {
        let interval = PillStrings.Intervals.LastTwentyDays
        let actual = PillStrings.Intervals.getIntervalFromString(interval)
        let expected = PillExpirationInterval.LastTwentyDays
        XCTAssertEqual(expected, actual)
    }

    func testGetIntervalFromString_whenXDaysOnXDaysOff_returnsExpectedInterval() {
        let interval = PillStrings.Intervals.XDaysOnXDaysOff
        let actual = PillStrings.Intervals.getIntervalFromString(interval)
        let expected = PillExpirationInterval.XDaysOnXDaysOff
        XCTAssertEqual(expected, actual)
    }
}
