//
// Created by Juliya Smith on 2/8/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
@testable
import PDKit


class ExpirationIntervalUDTests: XCTestCase {

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
