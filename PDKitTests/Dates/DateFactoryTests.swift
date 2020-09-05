//
//  DateFactoryTests.swift
//  PDKitTests
//
//  Created by Juliya Smith on 12/21/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import XCTest
import PDMock

@testable
import PDKit

class DateFactoryTests: XCTestCase {

    func testCreateDate_onDateAtTime_returnsExpectedDate() {
        let date = Date(timeIntervalSince1970: 999998888)
        let expected = Calendar.current.date(bySettingHour: 3, minute: 0, second: 0, of: date)!
        let threeAM = Calendar.current.date(bySettingHour: 3, minute: 0, second: 0, of: Date())!
        let actual = DateFactory.createDate(on: date, at: threeAM)
        XCTAssertEqual(expected, actual)
    }

    func testCreateDate_atTimeDaysFromNow_returnsExpectedDate() {
        let days = 5
        let midnight = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date())!
        let expected = midnight.addingTimeInterval(TimeInterval(days * 86400))
        let actual = DateFactory.createDate(at: midnight, daysFromToday: Int(days))!
        XCTAssertEqual(expected, actual, """
                                         Note: This test does not work within five days of daylight-savings time.
                                         This is because the test function makes use of the Calendar object,
                                         and the call to get `expected` just adds a TimeInterval.
                                         """)
    }

    func testCreateDate_byAddingHoursToDate_returnsExpectedDate() {
        let expected = Date(timeIntervalSinceNow: 10800)
        let actual = DateFactory.createDate(byAddingHours: 3, to: Date())!
        XCTAssert(PDTest.equiv(expected, actual))
    }

    func testCreateDate_byAddingMinutesToDate_returnsExpectedDate() {
        let expected = Date(timeIntervalSinceNow: 10800)
        let actual = DateFactory.createDate(byAddingMinutes: 180, to: Date())!
        XCTAssert(PDTest.equiv(expected, actual))
    }

    func testCreateTimesFromCommaSeparatedString_handlesSingleDate() {
        let actual = DateFactory.createTimesFromCommaSeparatedString("06:05:04")
        XCTAssertNotNil(actual)
    }

    func testCreateTimesFromCommaSeparatedString_handlesMultipleDates() {
        let actual = DateFactory.createTimesFromCommaSeparatedString("06:05:04,07:08:09")
        XCTAssertEqual(2, actual.count)
    }

    func testCreateTimeInterval_returnsExpectedTimeInterval() {
        let expected = 18000.0
        let actual = DateFactory.createTimeInterval(fromAddingHours: 5, to: Date())!
        XCTAssert(PDTest.equiv(expected, actual))
    }

    func testCreateTimeInterval_whenGivenNegativeHours_returnsExpectedTimeInterval() {
        let expected = -18000.0
        let actual = DateFactory.createTimeInterval(fromAddingHours: -5, to: Date())!
        XCTAssert(PDTest.equiv(expected, actual))
    }

    func testCreateTimeInterval_whenGivenDefaultDate_returnsNil() {
        XCTAssertNil(DateFactory.createTimeInterval(fromAddingHours: 9, to: Date(timeIntervalSince1970: 0)))
    }

    func testCreateDateBeforeAtEightPM_doesNotReturnNil() {
        XCTAssertNotNil(DateFactory.createDateBeforeAtEightPM(of: Date()))
    }

    func testCreateDateBeforeAtEightPM_returnsExpectedDate() {
        let yesterday = Date(timeIntervalSinceNow: -86400)
        let expected = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: yesterday)
        let actual = DateFactory.createDateBeforeAtEightPM(of: Date())
        XCTAssertEqual(expected, actual)
    }

    /// Tests a PDMock test method
    public func testSameTime() {
        let time = Date()
        let d1 = DateFactory.createDate(at: time, daysFromToday: 5)!
        let d2 = DateFactory.createDate(at: time, daysFromToday: -9)!
        XCTAssert(PDTest.sameTime(d1, d2))

        let d3 = DateFactory.createDate(byAddingMinutes: 12, to: time)!
        let d4 = DateFactory.createDate(byAddingMinutes: -19, to: time)!
        XCTAssertFalse(PDTest.sameTime(d3, d4))
    }
}
