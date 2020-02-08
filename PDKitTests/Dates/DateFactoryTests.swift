//
//  PDKitTests.swift
//  PDKitTests
//
//  Created by Juliya Smith on 12/21/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import XCTest

@testable
import PDKit

class DateHelperTests: XCTestCase {

    func testGetDateOnDateAtTime_returnsExpectedDate() {
        let date = Date(timeIntervalSince1970: 999998888)
        let threeAM = Calendar.current.date(bySettingHour: 3, minute: 0, second: 0, of: Date())!
        let expected = Calendar.current.date(bySettingHour: 3, minute: 0, second: 0, of: date)!
        let actual = DateFactory.createDate(on: date, at: threeAM)
        XCTAssertEqual(expected, actual)
    }

    func testGetDateAtTimeDaysFromNow_returnsExpectedDate() {
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

    func testGetDateByAddingHoursToDate_returnsExpectedDate() {
        let expected = Date(timeIntervalSinceNow: 10800)
        let actual = DateFactory.createDate(byAddingHours: 3, to: Date())!
        XCTAssert(actual.timeIntervalSince(expected) < 0.01)
    }

    func testGetTimeInterval_returnsExpectedDate() {
        let expected = 18000.0
        let actual = DateFactory.createTimeInterval(fromAddingHours: 5, to: Date())!
        XCTAssert(abs(expected - actual) < 0.1)
    }

    func testGetTimeInterval_whenGivenNegativeHours_returnsExpectedDate() {
        let expected = -18000.0
        let actual = DateFactory.createTimeInterval(fromAddingHours: -5, to: Date())!
        XCTAssert(abs(expected - actual) < 0.1)
    }

    func testGetTimeInterval_whenGivenDefaultDate_returnsNil() {
        XCTAssertNil(DateFactory.createTimeInterval(fromAddingHours: 9, to: Date(timeIntervalSince1970: 0)))
    }
}
