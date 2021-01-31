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
        let expected = PillExpirationInterval.Option.EveryDay
        XCTAssertEqual(expected, actual)
    }

    func testGetIntervalFromString_whenEveryOtherDay_returnsExpectedInterval() {
        let interval = PillStrings.Intervals.EveryOtherDay
        let actual = PillStrings.Intervals.getIntervalFromString(interval)
        let expected = PillExpirationInterval.Option.EveryOtherDay
        XCTAssertEqual(expected, actual)
    }

    func testGetIntervalFromString_whenFirstXDays_returnsExpectedInterval() {
        let interval = PillStrings.Intervals.FirstXDays
        let actual = PillStrings.Intervals.getIntervalFromString(interval)
        let expected = PillExpirationInterval.Option.FirstXDays
        XCTAssertEqual(expected, actual)
    }

    func testGetIntervalFromString_whenLastXDays_returnsExpectedInterval() {
        let interval = PillStrings.Intervals.LastXDays
        let actual = PillStrings.Intervals.getIntervalFromString(interval)
        let expected = PillExpirationInterval.Option.LastXDays
        XCTAssertEqual(expected, actual)
    }

    func testGetIntervalFromString_whenXDaysOnXDaysOff_returnsExpectedInterval() {
        let interval = PillStrings.Intervals.XDaysOnXDaysOff
        let actual = PillStrings.Intervals.getIntervalFromString(interval)
        let expected = PillExpirationInterval.Option.XDaysOnXDaysOff
        XCTAssertEqual(expected, actual)
    }
}
