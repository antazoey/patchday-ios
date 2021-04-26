//
// Created by Juliya Smith on 2/3/20.
// Copyright (c) 2021 Juliya Smith. All rights reserved.
//

import XCTest
import Foundation

@testable
import PDKit

class PDDateFormatterTests: XCTestCase {

    private var formatter: DateFormatter!

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
        formatter.dateFormat = DateFormatterFactory.timeFormat
        let now = Date()
        let expected = "Today, " + formatter.string(from: now)
        let actual = PDDateFormatter.formatDate(now)
        XCTAssertEqual(expected, actual)
    }

    func testFormatDate_whenTodayAndUseWordsIsFalse_excludesDateWord() {
        formatter.dateFormat = DateFormatterFactory.timeFormat
        let now = Date()
        let actual = PDDateFormatter.formatDate(now, useWords: false)
        XCTAssertFalse(actual.contains("Today"))
    }

    func testFormatDate_whenYesterday_returnsExpectedString() {
        formatter.dateFormat = DateFormatterFactory.timeFormat
        let yesterday = Date(timeInterval: -86499, since: Date())
        let expected = "Yesterday, " + formatter.string(from: yesterday)
        let actual = PDDateFormatter.formatDate(yesterday)
        XCTAssertEqual(expected, actual)
    }

    func testFormatDate_whenYesterdayAndUseWordsIsFalse_excludesDateWord() {
        formatter.dateFormat = DateFormatterFactory.timeFormat
        let yesterday = Date(timeInterval: -86499, since: Date())
        let actual = PDDateFormatter.formatDate(yesterday, useWords: false)
        XCTAssertFalse(actual.contains("Yesterday"))
    }

    func testFormatDate_whenTomorrow_returnsExpecteDstring() {
        formatter.dateFormat = DateFormatterFactory.timeFormat
        let yesterday = Date(timeInterval: 86499, since: Date())
        let expected = "Tomorrow, " + formatter.string(from: yesterday)
        let actual = PDDateFormatter.formatDate(yesterday)
        XCTAssertEqual(expected, actual)
    }

    func testFormatDate_whenTomorrowAndUseWordsIsFalse_returnsExpecteDstring() {
        formatter.dateFormat = DateFormatterFactory.timeFormat
        let yesterday = Date(timeInterval: 86499, since: Date())
        let actual = PDDateFormatter.formatDate(yesterday, useWords: false)
        XCTAssertFalse(actual.contains("Tomorrow"))
    }

    func testFormatDay_whenNotToday_returnsExpectedString() {
        let expected = "Monday, 7:46 AM"
        let actual = PDDateFormatter.formatDay(Date(timeIntervalSince1970: 1000000))
        XCTAssertEqual(expected, actual)
    }

    func testFormatDay_whenToday_returnsExpectedString() {
        formatter.dateFormat = DateFormatterFactory.timeFormat
        let now = Date()
        let expected = "Today, " + formatter.string(from: now)
        let actual = PDDateFormatter.formatDay(now)
        XCTAssertEqual(expected, actual)
    }

    func testFormatDay_whenYesterday_returnsExpectedString() {
        formatter.dateFormat = DateFormatterFactory.timeFormat
        let yesterday = Date(timeInterval: -86499, since: Date())
        let expected = "Yesterday, " + formatter.string(from: yesterday)
        let actual = PDDateFormatter.formatDay(yesterday)
        XCTAssertEqual(expected, actual)
    }

    func testFormatDay_whenTomorrow_returnsExpectedString() {
        formatter.dateFormat = DateFormatterFactory.timeFormat
        let yesterday = Date(timeInterval: 86499, since: Date())
        let expected = "Tomorrow, " + formatter.string(from: yesterday)
        let actual = PDDateFormatter.formatDay(yesterday)
        XCTAssertEqual(expected, actual)
    }

    func testConvertTimesToCommaSeparatedString_whenGivenSingleDate_returnsExpectedString() {
        formatter.dateFormat = DateFormatterFactory.internalTimeFormat
        let date = Date()
        let expected = formatter.string(from: date)
        let actual = PDDateFormatter.convertTimesToCommaSeparatedString([date])
        XCTAssertEqual(expected, actual)
    }

    func testConvertTimesToCommaSeparatedString_whenGivenMultipleDates_returnsExpectedString() {
        formatter.dateFormat = DateFormatterFactory.internalTimeFormat
        let dateOne = Date()
        let dateTwo = DateFactory.createDate(byAddingHours: -3, to: dateOne)
        let expected = "\(formatter.string(from: dateOne)),\(formatter.string(from: dateTwo!))"
        let actual = PDDateFormatter.convertTimesToCommaSeparatedString([dateOne, dateTwo])
        XCTAssertEqual(expected, actual)
    }

    func testConvertTimesToCommaSeparatedString_ignoresNils() {
        formatter.dateFormat = DateFormatterFactory.internalTimeFormat
        let date = Date()
        let expected = formatter.string(from: date)
        let actual = PDDateFormatter.convertTimesToCommaSeparatedString([nil, date, nil])
        XCTAssertEqual(expected, actual)
    }

    func testConvertTimesToCommaSeparatedString_returnsExpectedString() {
        formatter.dateFormat = DateFormatterFactory.internalTimeFormat
        let testDate = Calendar.current.date(bySettingHour: 12, minute: 51, second: 30, of: Date())!
        let actual = PDDateFormatter.convertTimesToCommaSeparatedString([testDate])
        XCTAssertEqual("12:51:30", actual)
    }

    func testConvertDatesToCommaSeparatedString_whenGivenSingleDate_returnsExpectedString() {
        let formatter = ISO8601DateFormatter()
        let date = Date()
        let expected = formatter.string(from: date)
        let actual = PDDateFormatter.convertDatesToCommaSeparatedString([date])
        XCTAssertEqual(expected, actual)
    }

    func testConvertDatesToCommaSeparatedString_whenGivenMultipleDates_returnsExpectedString() {
        let formatter = ISO8601DateFormatter()
        let dateOne = Date()
        let dateTwo = DateFactory.createDate(byAddingHours: -3, to: dateOne)
        let expected = "\(formatter.string(from: dateOne)),\(formatter.string(from: dateTwo!))"
        let actual = PDDateFormatter.convertDatesToCommaSeparatedString([dateOne, dateTwo])
        XCTAssertEqual(expected, actual)
    }

    func testConvertDatesTimesToCommaSeparatedString_ignoresNils() {
        let formatter = ISO8601DateFormatter()
        let date = Date()
        let expected = formatter.string(from: date)
        let actual = PDDateFormatter.convertDatesToCommaSeparatedString([nil, date, nil])
        XCTAssertEqual(expected, actual)
    }

    func testConvertDatesToCommaSeparatedString_returnsExpectedString() {
        let defaultDate = DateFactory.createDefaultDate()
        let testDateOne = DateFactory.createDate(byAddingHours: 452322, to: defaultDate)
        let testDateTwo = DateFactory.createDate(byAddingHours: 452342, to: defaultDate)
        let actual = PDDateFormatter.convertDatesToCommaSeparatedString([testDateOne, testDateTwo])
        XCTAssertEqual("2021-08-07T18:00:00Z,2021-08-08T14:00:00Z", actual)
    }
}
