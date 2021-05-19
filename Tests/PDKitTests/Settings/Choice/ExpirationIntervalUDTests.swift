//
// Created by Juliya Smith on 2/8/20.
// Copyright (c) 2021 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
@testable
import PDKit

class ExpirationIntervalUDTests: XCTestCase {

    func testValue_whenInitWithOnceDailyKey_returnsOnceDaily() {
        let rawValue = ExpirationIntervalUD.getRawValue(for: .OnceDaily)
        let expiration = ExpirationIntervalUD(rawValue)
        XCTAssertEqual(.OnceDaily, expiration.value)
    }

    func testValue_whenInitWithTwiceWeeklyKey_returnsTwiceWeekly() {
        let rawValue = ExpirationIntervalUD.getRawValue(for: .TwiceWeekly)
        let expiration = ExpirationIntervalUD(rawValue)
        XCTAssertEqual(.TwiceWeekly, expiration.value)
    }

    func testValue_whenInitWithOnceWeeklyKey_returnsOnceWeekly() {
        let rawValue = ExpirationIntervalUD.getRawValue(for: .OnceWeekly)
        let expiration = ExpirationIntervalUD(rawValue)
        XCTAssertEqual(.OnceWeekly, expiration.value)
    }

    func testValue_whenInitWithEveryTwoWeeksKey_returnsEveryTwoWeeks() {
        let rv = ExpirationIntervalUD.getRawValue(for: .EveryTwoWeeks)
        let expiration = ExpirationIntervalUD(rv)
        XCTAssertEqual(.EveryTwoWeeks, expiration.value)
    }

    func testHours_whenIsOnceDaily_returnsExpectedHours() {
        let expiration = ExpirationIntervalUD(.OnceDaily)
        XCTAssertEqual(24, expiration.hours)
    }

    func testHours_whenIsTwiceWeekly_returnsExpectedHours() {
        let expiration = ExpirationIntervalUD(.TwiceWeekly)
        XCTAssertEqual(84, expiration.hours)
    }

    func testHours_whenIsOnceWeekly_returnsExpectedHours() {
        let expiration = ExpirationIntervalUD(.OnceWeekly)
        XCTAssertEqual(168, expiration.hours)
    }

    func testHours_whenIsEveryTwoWeeks_returnsExpectedHours() {
        let expiration = ExpirationIntervalUD(.EveryTwoWeeks)
        XCTAssertEqual(336, expiration.hours)
    }

    func testHours_whenIsCustomSingleDigitWholeNumber_returnsExpectedHours() {
        let expiration = ExpirationIntervalUD(.EveryXDays)
        expiration.xDays.rawValue = "3.0"
        let expected = 3 * Hours.InDay
        let actual = expiration.hours
        XCTAssertEqual(expected, actual)
    }

    func testHours_whenIsCustomSingleDigitHalfNumber_returnsExpectedHours() {
        let expiration = ExpirationIntervalUD(.EveryXDays)
        expiration.xDays.rawValue = "3.5"
        let expected = Int(3.5 * Double(Hours.InDay))
        let actual = expiration.hours
        XCTAssertEqual(expected, actual)
    }

    func testHours_whenIsCustomDoubleDigitWholeNumber_returnsExpectedHours() {
        let expiration = ExpirationIntervalUD(.EveryXDays)
        expiration.xDays.rawValue = "13.0"
        let expected = 13 * Hours.InDay
        let actual = expiration.hours
        XCTAssertEqual(expected, actual)
    }

    func testHours_whenIsCustomDoubleDigitHalfNumber_returnsExpectedHours() {
        let expiration = ExpirationIntervalUD(.EveryXDays)
        expiration.xDays.rawValue = "13.5"
        let expected = Int(13.5 * Double(Hours.InDay))
        let actual = expiration.hours
        XCTAssertEqual(expected, actual)
    }

    func testDays_whenIsOnceDaily_returnsExpectedDays() {
        let expiration = ExpirationIntervalUD(.OnceDaily)
        XCTAssertEqual(1.0, expiration.days)
    }

    func testDays_whenIsTwiceWeekly_returnsExpectedHours() {
        let expiration = ExpirationIntervalUD(.TwiceWeekly)
        XCTAssertEqual(3.5, expiration.days)
    }

    func testDays_whenIsOnceWeekly_returnsExpectedDays() {
        let expiration = ExpirationIntervalUD(.OnceWeekly)
        XCTAssertEqual(7.0, expiration.days)
    }

    func testDays_whenIsEveryTwoWeeks_returnsExpectedDays() {
        let expiration = ExpirationIntervalUD(.EveryTwoWeeks)
        XCTAssertEqual(14, expiration.days)
    }

    func testDays_whenIsCustomSingleDigitWholeNumber_returnsExpectedDays() {
        let expiration = ExpirationIntervalUD(.EveryXDays)
        expiration.xDays.rawValue = "3.0"
        XCTAssertEqual(3.0, expiration.days)
    }

    func testDays_whenIsCustomSingleDigitHalfNumber_returnsExpectedDays() {
        let expiration = ExpirationIntervalUD(.EveryXDays)
        expiration.xDays.rawValue = "3.5"
        XCTAssertEqual(3.5, expiration.days)
    }

    func testDays_whenIsCustomDoubleDigitWholeNumber_returnsExpectedDays() {
        let expiration = ExpirationIntervalUD(.EveryXDays)
        expiration.xDays.rawValue = "13.0"
        XCTAssertEqual(13.0, expiration.days)
    }

    func testDays_whenIsCustomDoubleDigitHalfNumber_returnsExpectedDays() {
        let expiration = ExpirationIntervalUD(.EveryXDays)
        expiration.xDays.rawValue = "13.5"
        XCTAssertEqual(13.5, expiration.days)
    }

    func testDisplayableString_whenIsOnceDaily_returnsExpectedString() {
        let expiration = ExpirationIntervalUD(.OnceDaily)
        let expected = SettingsOptions.OnceDaily
        let actual = expiration.displayableString
        XCTAssertEqual(expected, actual)
    }

    func testDisplayableString_whenIsTwiceWeekly_returnsExpectedString() {
        let expiration = ExpirationIntervalUD(.TwiceWeekly)
        let expected = SettingsOptions.TwiceWeekly
        let actual = expiration.displayableString
        XCTAssertEqual(expected, actual)
    }

    func testDisplayableString_whenIsOnceWeekly_returnsExpectedString() {
        let expiration = ExpirationIntervalUD(.OnceWeekly)
        let expected = SettingsOptions.OnceWeekly
        let actual = expiration.displayableString
        XCTAssertEqual(expected, actual)
    }

    func testDisplayableString_whenIsEveryTwoWeeks_returnsExpectedString() {
        let expiration = ExpirationIntervalUD(.EveryTwoWeeks)
        let expected = SettingsOptions.OnceEveryTwoWeeks
        let actual = expiration.displayableString
        XCTAssertEqual(expected, actual)
    }

    func testDisplayableString_whenIsCustom_returnsExpectedString() {
        let expiration = ExpirationIntervalUD(.EveryXDays)
        expiration.xDays.rawValue = "1.5"
        XCTAssertEqual("Every 1½ Days", expiration.displayableString)
        expiration.xDays.rawValue = "2.5"
        XCTAssertEqual("Every 2½ Days", expiration.displayableString)
        expiration.xDays.rawValue = "20.0"
        XCTAssertEqual("Every 20 Days", expiration.displayableString)
    }
}
