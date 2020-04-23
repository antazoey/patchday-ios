//
// Created by Juliya Smith on 2/3/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import XCTest
import Foundation

@testable
import PDKit

class PDDateFormatterTests: XCTestCase {

	private var formatter: DateFormatter!
	private let timeFormat = "h:mm a"
	private let dateFormat = "EEEE, h:mm a"

	override func setUp() {
		formatter = DateFormatter()
	}

	func testFormatTime_returnsExpectedString() {
		let expected = "7:46 AM"
		let actual = PDDateFormatter.formatTime(Date(timeIntervalSince1970: 1000000))
		XCTAssertEqual(expected, actual)
	}

	func testFormatDate_whenNotTodayYesterdayOrTomorrow_returnsExpectedString() {
		let expected = "Monday, January 12, 7:46 AM"
		let actual = PDDateFormatter.formatDate(Date(timeIntervalSince1970: 1000000))
		XCTAssertEqual(expected, actual)
	}

	func testFormatDate_whenToday_returnsExpectedString() {
		formatter.dateFormat = timeFormat
		let now = Date()
		let expected = "Today, " + formatter.string(from: now)
		let actual = PDDateFormatter.formatDate(now)
		XCTAssertEqual(expected, actual)
	}

	func testFormatDate_whenYesterday_returnsExpectedString() {
		formatter.dateFormat = timeFormat
		let yesterday = Date(timeInterval: -86499, since: Date())
		let expected = "Yesterday, " + formatter.string(from: yesterday)
		let actual = PDDateFormatter.formatDate(yesterday)
		XCTAssertEqual(expected, actual)
	}
    
    func testFormatDate_whenTomorrow_returnsExpecteDstring() {
        formatter.dateFormat = timeFormat
        let yesterday = Date(timeInterval: 86499, since: Date())
        let expected = "Tomorrow, " + formatter.string(from: yesterday)
        let actual = PDDateFormatter.formatDate(yesterday)
        XCTAssertEqual(expected, actual)
    }
    
    func testFormatDay_whenNotToday_returnsExpectedString() {
        let expected = "Monday, 7:46 AM"
        let actual = PDDateFormatter.formatDay(Date(timeIntervalSince1970: 1000000))
        XCTAssertEqual(expected, actual)
    }
    
    func testFormatDay_whenToday_returnsExpectedString() {
        formatter.dateFormat = timeFormat
        let now = Date()
        let expected = "Today, " + formatter.string(from: now)
        let actual = PDDateFormatter.formatDay(now)
        XCTAssertEqual(expected, actual)
    }

    func testFormatDay_whenYesterday_returnsExpectedString() {
        formatter.dateFormat = timeFormat
        let yesterday = Date(timeInterval: -86499, since: Date())
        let expected = "Yesterday, " + formatter.string(from: yesterday)
        let actual = PDDateFormatter.formatDay(yesterday)
        XCTAssertEqual(expected, actual)
    }
    
    func testFormatDay_whenTomorrow_returnsExpecteDstring() {
        formatter.dateFormat = timeFormat
        let yesterday = Date(timeInterval: 86499, since: Date())
        let expected = "Tomorrow, " + formatter.string(from: yesterday)
        let actual = PDDateFormatter.formatDay(yesterday)
        XCTAssertEqual(expected, actual)
    }
}
