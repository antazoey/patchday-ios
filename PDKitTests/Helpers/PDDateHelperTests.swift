//
//  PDKitTests.swift
//  PDKitTests
//
//  Created by Juliya Smith on 12/21/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import XCTest
@testable import PDKit

class PDDateHelperTests: XCTestCase {
    let d1 = Date(timeIntervalSince1970: 0)
    let today = Date()
    let halfweek_interval = PDStrings.PickerData.expirationIntervals[0]
    let week_interval = PDStrings.PickerData.expirationIntervals[1]
    let two_weeks_interval = PDStrings.PickerData.expirationIntervals[2]

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testDayOfWeek() {
        let dateStr = PDDateHelper.dayOfWeekString(date: d1)
        let expected = "Wednesday, 6:00 PM"
        XCTAssertEqual(dateStr, expected)
    }
    
    func testDateWord() {
        var dateWord = PDDateHelper.dateWord(from: today)
        var expected = "Today"
        XCTAssertEqual(dateWord, expected)
        
        let yesterday = Date(timeInterval: -86400, since: today)
        dateWord = PDDateHelper.dateWord(from: yesterday)
        expected = "Yesterday"
        XCTAssertEqual(dateWord, expected)
        
        let tomorrow = Date(timeInterval: 86400, since: today)
        dateWord = PDDateHelper.dateWord(from: tomorrow)
        expected = "Tomorrow"
        XCTAssertEqual(dateWord, expected)
    }
    
    func testGetDateOnDateAtTime() {
        let time = Time()
        if let testDate = PDDateHelper.getDate(on: d1, at: time) {
            let calendar = Calendar.current
            let t_year = calendar.component(.year, from: testDate)
            let t_mon = calendar.component(.month, from: testDate)
            let t_day = calendar.component(.day, from: testDate)
            let t_hour = calendar.component(.hour, from: testDate)
            let t_min = calendar.component(.minute, from: testDate)
            
            let e_year = calendar.component(.year, from: d1)
            let e_mon = calendar.component(.month, from: d1)
            let e_day = calendar.component(.day, from: d1)
            let e_hour = calendar.component(.hour, from: time)
            let e_min = calendar.component(.minute, from: time)
            
            XCTAssertEqual(t_year, e_year)
            XCTAssertEqual(t_mon, e_mon)
            XCTAssertEqual(t_day, e_day)
            XCTAssertEqual(t_hour, e_hour)
            XCTAssertEqual(t_min, e_min)
        } else {
            XCTFail()
        }
    }
    
    func testGetDateAtTimeWithDaysToAdd() {
        let now = Date()
        if let actualDate = PDDateHelper.getDate(at: now, daysFromNow: 3) {
            let expectedDate = Date(timeInterval: 3*86400, since: now)
            let actual = PDDateHelper.dayOfWeekString(date: actualDate)
            let expected = PDDateHelper.dayOfWeekString(date: expectedDate)
            XCTAssertEqual(actual, expected)
        } else {
            XCTFail()
        }
    }
    
    func testCalculateHours() {
        let expected1 = 84
        let expected2 = 168
        let expected3 = 336
        let actual1 = PDDateHelper.calculateHours(of: halfweek_interval)
        let actual2 = PDDateHelper.calculateHours(of: week_interval)
        let actual3 = PDDateHelper.calculateHours(of: two_weeks_interval)
        let actual4 = PDDateHelper.calculateHours(of: "NONSENSE")
        XCTAssertEqual(actual1, expected1)
        XCTAssertEqual(actual2, expected2)
        XCTAssertEqual(actual3, expected3)
        XCTAssertEqual(actual4, expected1)
    }
    
    func testExpirationDate() {
        let testDate = Date(timeInterval: 21000, since: d1)
        let actual_expDate1 = PDDateHelper.expirationDate(from: testDate, halfweek_interval)
        let actual_expDate2 = PDDateHelper.expirationDate(from: testDate, week_interval)
        let actual_expDate3 = PDDateHelper.expirationDate(from: testDate, two_weeks_interval)
        
        let expected_expDate1 = Date(timeInterval: 302400, since: testDate)
        let expected_expDate2 = Date(timeInterval: 604800, since: testDate)
        let expected_expDate3 = Date(timeInterval: 1209600, since: testDate)
        
        XCTAssertEqual(actual_expDate1, expected_expDate1)
        XCTAssertEqual(actual_expDate2, expected_expDate2)
        XCTAssertEqual(actual_expDate3, expected_expDate3)
    }
    
    func testExpirationInterval() {
        let now = Date()
        if let actual_interval_1 = PDDateHelper.expirationInterval(halfweek_interval, date: now),
            let expected_interval_1 = TimeInterval(exactly: 302400) {
                let a1 = Float(actual_interval_1)
                let e1 = Float(expected_interval_1)
                XCTAssertEqual(a1, e1, accuracy: 0.01)
        } else {
            XCTFail()
        }
        if let actual_interval_2 = PDDateHelper.expirationInterval(week_interval, date: now),
            let expected_interval_2 = TimeInterval(exactly: 604800) {
            let a2 = Float(actual_interval_2)
            let e2 = Float(expected_interval_2)
            XCTAssertEqual(a2, e2, accuracy: 0.01)
        } else {
            XCTFail()
        }
        if let actual_interval_3 = PDDateHelper.expirationInterval(two_weeks_interval, date: now),
            let expected_interval_3 = TimeInterval(exactly: 1209600) {
            let a3 = Float(actual_interval_3)
            let e3 = Float(expected_interval_3)
            XCTAssertEqual(a3, e3, accuracy: 0.01)
        } else {
            XCTFail()
        }
    }

    
    func testDateBeforeOvernight() {
        let now = Date()
        if let eightPM = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: now) {
            let eightPM_before = Calendar.current.date(byAdding: .day, value: -1, to: eightPM)
            let actual = PDDateHelper.dateBeforeOvernight(overnightDate: now)
            XCTAssertEqual(actual, eightPM_before)
        } else {
            XCTFail()
        }
    }
    
    func testFormatTime() {
        let actual = PDDateHelper.format(time: d1)
        XCTAssertEqual(actual, "6:00 PM")
    }
    
    func testFormatDate() {
        var actual = PDDateHelper.format(date: d1, useWords: false)
        let now = Date()
        let expected = "Dec 31, 6:00 PM"
        XCTAssertEqual(actual, expected)
        actual = PDDateHelper.format(date: d1, useWords: true)
        XCTAssertEqual(actual, expected)
        actual = PDDateHelper.format(date: now, useWords: true)
        XCTAssert(actual.range(of: "Today") != nil)
    }
}
