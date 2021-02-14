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
        let expected = PillExpirationIntervalSetting.EveryDay
        XCTAssertEqual(expected, actual)
    }

    func testGetIntervalFromString_whenEveryOtherDay_returnsExpectedInterval() {
        let interval = PillStrings.Intervals.EveryOtherDay
        let actual = PillStrings.Intervals.getIntervalFromString(interval)
        let expected = PillExpirationIntervalSetting.EveryOtherDay
        XCTAssertEqual(expected, actual)
    }

    func testGetIntervalFromString_whenFirstXDays_returnsExpectedInterval() {
        let interval = PillStrings.Intervals.FirstXDays
        let actual = PillStrings.Intervals.getIntervalFromString(interval)
        let expected = PillExpirationIntervalSetting.FirstXDays
        XCTAssertEqual(expected, actual)
    }

    func testGetIntervalFromString_whenLastXDays_returnsExpectedInterval() {
        let interval = PillStrings.Intervals.LastXDays
        let actual = PillStrings.Intervals.getIntervalFromString(interval)
        let expected = PillExpirationIntervalSetting.LastXDays
        XCTAssertEqual(expected, actual)
    }

    func testGetIntervalFromString_whenXDaysOnXDaysOff_returnsExpectedInterval() {
        let interval = PillStrings.Intervals.XDaysOnXDaysOff
        let actual = PillStrings.Intervals.getIntervalFromString(interval)
        let expected = PillExpirationIntervalSetting.XDaysOnXDaysOff
        XCTAssertEqual(expected, actual)
    }
}
