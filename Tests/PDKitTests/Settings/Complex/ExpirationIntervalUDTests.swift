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
        let rv = ExpirationIntervalUD.getRawValue(for: .OnceDaily)
        let expiration = ExpirationIntervalUD(rv)
        XCTAssertEqual(.OnceDaily, expiration.value)
    }

    func testValue_whenInitWithTwiceWeeklyKey_returnsTwiceWeekly() {
        let rv = ExpirationIntervalUD.getRawValue(for: .TwiceWeekly)
        let expiration = ExpirationIntervalUD(rv)
        XCTAssertEqual(.TwiceWeekly, expiration.value)
    }

    func testValue_whenInitWithOnceWeeklyKey_returnsOnceWeekly() {
        let rv = ExpirationIntervalUD.getRawValue(for: .OnceWeekly)
        let expiration = ExpirationIntervalUD(rv)
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
}
