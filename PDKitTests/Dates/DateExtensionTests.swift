//
//  DateExtensionTests.swift
//  PDKitTests
//
//  Created by Juliya Smith on 1/4/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
@testable
import PDKit

class DateExtensionTests: XCTestCase {

	// Note: If you run these tests at like midnight, you might get weird results.
	// For example, the tests may assume it can add seconds to the current time and have it still be today.

	func testIsWithinMinutes_returnsTrueWhenGivenDateThatIsWithinGivenMinutes() {
		let d1 = Date()
		let d2 = Date()
		XCTAssertTrue(d1.isWithin(minutes: 1, of: d2))
	}

	func testIsWithinMinutes_returnsFalseWhenDateIsNotWithinGivenMinutes() {
		let d1 = Date()
		let d3 = DateFactory.createDefaultDate()
		XCTAssertFalse(d1.isWithin(minutes: 100, of: d3))
	}

	func testIsWithinMinutes_whenDatesAreSameAndGivenZeroMinutes_returnsTrue() {
		let d1 = Date()
		XCTAssertTrue(d1.isWithin(minutes: 0, of: d1))
	}

	func testIsInPast_whenGivenDateThatIsInPast_returnsTrue() {
		let past = Date(timeInterval: -5000, since: Date())
		XCTAssertTrue(past.isInPast())
	}

	func testIsInPast_whenGivenDateThatIsInInFuture_returnsFalse() {
		let future = Date(timeInterval: 5000, since: Date())
		XCTAssertFalse(future.isInPast())
	}

	func testIsInToday_whenGivenDateThatIsNow_returnsTrue() {
		XCTAssertTrue(Date().isInToday())
	}

	func testIsInToday_whenGivenDateThatIs0000Tomorrow_returnsFalse() {
		let tomorrow = Date(timeIntervalSinceNow: 86400)
		let atMidnight = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow)
		XCTAssertFalse(atMidnight!.isInToday())
	}

	func testIsInToday_whenGivenDateThatIs2359Today_returnsTrue() {
		let today = Date()
		let atMidnightIsh = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: today)
		XCTAssertTrue(atMidnightIsh!.isInToday())
	}

	func testIsOvernight_whenGivenThreeAM_returnsTrue() {
		let threeAM = Calendar.current.date(bySettingHour: 3, minute: 0, second: 0, of: Date())!
		XCTAssertTrue(threeAM.isOvernight())
	}

	func testIsOvernight_whenGivenThreePM_returnsFalse() {
		let threePM = Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: Date())!
		XCTAssertFalse(threePM.isOvernight())
	}

	func testIsDefault_whenIsDefault_returnsTrue() {
		let defaultDate = Date(timeIntervalSince1970: 0)
		XCTAssertTrue(defaultDate.isDefault())
	}

	func testIsDefault_whenIsNotDefault_returnsFalse() {
		XCTAssertFalse(Date().isDefault())
	}
}
