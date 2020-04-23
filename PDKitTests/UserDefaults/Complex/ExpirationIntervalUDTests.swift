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
		let rv = ExpirationIntervalUD.getRawValue(for: .EveryTwoWeeks)
		let expiration = ExpirationIntervalUD(rv)
		XCTAssertEqual(336, expiration.hours)
	}

	func testHours_whenIsOnceWeekly_returnsExpectedHours() {
		let rv = ExpirationIntervalUD.getRawValue(for: .OnceWeekly)
		let expiration = ExpirationIntervalUD(rv)
		XCTAssertEqual(168, expiration.hours)
	}

	func testHours_whenIsTwiceWeekly_returnsExpectedHours() {
		let rv = ExpirationIntervalUD.getRawValue(for: .TwiceWeekly)
		let expiration = ExpirationIntervalUD(rv)
		XCTAssertEqual(84, expiration.hours)
	}
}
