//
//  DateFactoryTests.swift
//  PDKitTests
//
//  Created by Juliya Smith on 12/21/18.

import XCTest
import PDTest

@testable
import PDKit

class DateFactoryTests: XCTestCase {

    func testCreateDate_onDateAtTime_returnsExpectedDate() {
        let date = Date(timeIntervalSince1970: 999998888)
        let expected = TestDateFactory.createTestDate(hour: 3, date: date)
        let threeAM = TestDateFactory.createTestDate(hour: 3)
        let actual = DateFactory.createDate(on: date, at: threeAM)
        XCTAssertEqual(expected, actual)
    }

    func testCreateDate_atTimeDaysFromNow_returnsExpectedDate() {
        let now = MockNow()
        now.now = DateFactory.createDate(byAddingHours: 1, to: DateFactory.createDefaultDate())!
        let days = 5
        let midnight = TestDateFactory.createTestDate(hour: 19, now: now)
        let expected = midnight.addingTimeInterval(TimeInterval(days * 86400))
        guard let actual = DateFactory.createDate(daysFrom: Int(days), at: midnight, now: now) else {
            XCTFail("Actual was nil")
            return
        }
        XCTAssertEqual(expected, actual)
    }

    func testCreateDate_byAddingHoursToDate_returnsExpectedDate() {
        let expected = Date(timeIntervalSinceNow: 10800)

        guard let actual = DateFactory.createDate(byAddingHours: 3, to: Date()) else {
            XCTFail("Actual was nil")
            return
        }

        PDAssertEquiv(expected, actual)
    }

    func testCreateDate_byAddingMinutesToDate_returnsExpectedDate() {
        let expected = Date(timeIntervalSinceNow: 10800)
        guard let actual = DateFactory.createDate(byAddingMinutes: 180, to: Date()) else {
            XCTFail("Actual was nil")
            return
        }
        PDAssertEquiv(expected, actual)
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
        guard let actual = DateFactory.createTimeInterval(fromAddingHours: 5, to: Date()) else {
            XCTFail("Actual was nil")
            return
        }
        PDAssertEquiv(expected, actual)
    }

    func testCreateTimeInterval_whenGivenNegativeHours_returnsExpectedTimeInterval() {
        let expected = -18000.0
        guard let actual = DateFactory.createTimeInterval(fromAddingHours: -5, to: Date()) else {
            XCTFail("Actual was nil")
            return
        }
        PDAssertEquiv(expected, actual)
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

    /// Tests a PDTest test method
    public func testSameTime() {
        let dateOne = TestDateFactory.createTestDate(daysFrom: 5)
        let dateTwo = TestDateFactory.createTestDate(daysFrom: -9)
        PDAssertSameTime(dateOne, dateTwo)
        let dateThree = TestDateFactory.createTestDate(minutesFrom: 12)
        let dateFour = TestDateFactory.createTestDate(minutesFrom: -19)
        PDAssertDifferentTime(dateThree, dateFour)
    }
}
