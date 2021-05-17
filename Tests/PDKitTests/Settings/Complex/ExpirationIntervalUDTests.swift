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

    func testHours_whenIsEveryTwoWeeks_returnsExpectedHours() {
        let expiration = ExpirationIntervalUD(.EveryTwoWeeks)
        XCTAssertEqual(336, expiration.hours)
    }

    func testHours_whenIsOnceWeekly_returnsExpectedHours() {
        let expiration = ExpirationIntervalUD(.OnceWeekly)
        XCTAssertEqual(168, expiration.hours)
    }

    func testHours_whenIsTwiceWeekly_returnsExpectedHours() {
        let expiration = ExpirationIntervalUD(.TwiceWeekly)
        XCTAssertEqual(84, expiration.hours)
    }

    func testExtractDays_extractsDays() {
        let testString = "Every 5.0 Days"
        let expected = "5.0"
        let actual = ExpirationIntervalUD.extractDays(from: testString)
        XCTAssertEqual(expected, actual)
    }

    func testExtractDays_whenGivenInvalidString_returnsEmptyString() {
        let testString = "Blipity Blop"
        let expected = ""
        let actual = ExpirationIntervalUD.extractDays(from: testString)
        XCTAssertEqual(expected, actual)
    }
}
