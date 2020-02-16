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

    func testHours_whenIsOnceAWeek_returnsExpectedHours() {
        let expiration = ExpirationIntervalUD(.OnceAWeek)
        XCTAssertEqual(168, expiration.hours)
    }

    func testHours_whenIsTwiceAWeek_returnsExpectedHours() {
        let expiration = ExpirationIntervalUD(.TwiceAWeek)
        XCTAssertEqual(84, expiration.hours)
    }
}
