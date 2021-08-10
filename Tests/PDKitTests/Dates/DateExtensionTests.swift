//
//  DateExtensionTests.swift
//  PDKitTests
//
//  Created by Juliya Smith on 1/4/19.

import Foundation

import XCTest
@testable
import PDKit
import PDTest

class DateExtensionTests: PDTestCase {

    // Note: If you run these tests at like midnight, you might get weird results.
    // For example, the tests may assume it can add seconds to the current time and have it still be today.

    func testDaysSince_whenGivenADateToday_returnsZeroDays() {
        let eightAM = TestDateFactory.createTestDate(hour: 8)
        let sevenHoursBefore = TestDateFactory.createTestDate(hoursFrom: -7, date: eightAM)
        let expected = 0
        let actual = eightAM.daysSince(sevenHoursBefore)
        XCTAssertEqual(expected, actual)
    }

    func testDaysSince_whenGivenADateFromYesterdayNight_returnsOneDay() {
        let eightAM = TestDateFactory.createTestDate(hour: 8)
        let twelveHoursBefore = TestDateFactory.createTestDate(hoursFrom: -12, date: eightAM)
        let expected = 1
        let actual = eightAM.daysSince(twelveHoursBefore)
        XCTAssertEqual(expected, actual)
    }

    func testDaysSince_whenGivenADateFromYesterdayMorning_returnsOneDay() {
        let eightAM = TestDateFactory.createTestDate(hour: 8)
        let twelveHoursBefore = TestDateFactory.createTestDate(hoursFrom: -24, date: eightAM)
        let expected = 1
        let actual = eightAM.daysSince(twelveHoursBefore)
        XCTAssertEqual(expected, actual)
    }

    func testDaysSince_whenGivenDateFromTwoDaysAgo_returnsTwoDays() {
        let eightAM = TestDateFactory.createTestDate(hour: 4)
        let thirtyBefore = TestDateFactory.createTestDate(hoursFrom: -30, date: eightAM)
        let expected = 2
        let actual = eightAM.daysSince(thirtyBefore)
        XCTAssertEqual(expected, actual)
    }

    func testDayValue() {
        XCTAssertEqual(31, TestDateFactory.defaultDate.dayValue())
    }

    func testIsWithinMinutes_returnsTrueWhenGivenDateThatIsWithinGivenMinutes() {
        XCTAssertTrue(Date().isWithin(minutes: 1, of: Date()))
    }

    func testIsWithinMinutes_returnsFalseWhenDateIsNotWithinGivenMinutes() {
        XCTAssertFalse(Date().isWithin(minutes: 100, of: TestDateFactory.defaultDate))
    }

    func testIsWithinMinutes_whenDatesAreSameAndGivenZeroMinutes_returnsTrue() {
        XCTAssertTrue(Date().isWithin(minutes: 0, of: Date()))
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
        let atMidnight = DateFactory.createMidnight(of: tomorrow)
        XCTAssertFalse(atMidnight!.isInToday())
    }

    func testIsInToday_whenGivenDateThatIs2359Today_returnsTrue() {
        let today = Date()
        let atMidnightIsh = DateFactory.createDate(today, hour: 23, minute: 23, second: 59)
        XCTAssertTrue(atMidnightIsh!.isInToday())
    }

    func testIsInTomorrow_whenGivenDateThatIsTomorrow_returnsTrue() {
        let tomorrow = TestDateFactory.createTestDate(daysFrom: 1)
        XCTAssertTrue(tomorrow.isInTomorrow())
    }

    func testIsInTomorrow_whenGivenDateThatIs0000TheDayAfterTomorrow_returnsFalse() {
        let dayAfterTomorrow = TestDateFactory.createTestDate(daysFrom: 2)
        let atMidnight = TestDateFactory.createTestMidnight(date: dayAfterTomorrow)
        XCTAssertFalse(atMidnight.isInTomorrow())
    }

    func testIsInTomorrow_whenGivenDateThatIsToday_returnsFalse() {
        XCTAssertFalse(Date().isInTomorrow())
    }

    func testIsInTomorrow_whenGivenDateThatIs2359Tomorrow_returnsTrue() {
        let tomorrow = TestDateFactory.createTestDate(daysFrom: 1)
        let atMidnightIsh = TestDateFactory.createTestDate(
            hour: 23, minute: 59, second: 59, date: tomorrow
        )
        XCTAssertTrue(atMidnightIsh.isInTomorrow())
    }

    func testIsInYesterday_whenGivenDateThatIsYesterday_returnsTrue() {
        XCTAssertTrue(TestDateFactory.createYesterday().isInYesterday())
    }

    func testIsInYesterday_whenGivenDateThatIs0000TheDayBeforeYesterday_returnsFalse() {
        let dayBeforeYesterday = TestDateFactory.createTestDate(daysFrom: -2)
        let atMidnight = TestDateFactory.createTestMidnight(date: dayBeforeYesterday)
        XCTAssertFalse(atMidnight.isInYesterday())
    }

    func testIsInYesterday_whenGivenDateThatIsToday_returnsFalse() {
        XCTAssertFalse(Date().isInYesterday())
    }

    func testIsInYesterday_whenGivenDateThatIs2359Yesterday_returnsTrue() {
        let yesterday = TestDateFactory.createYesterday()
        let atMidnightIsh = TestDateFactory.createTestDate(
            hour: 23, minute: 59, second: 59, date: yesterday
        )
        XCTAssertTrue(atMidnightIsh.isInYesterday())
    }

    func testIsOvernight_whenGivenThreeAM_returnsTrue() {
        let threeAM = TestDateFactory.createTestDate(hour: 3)
        XCTAssertTrue(threeAM.isOvernight())
    }

    func testIsOvernight_whenGivenThreePM_returnsFalse() {
        let threePM = TestDateFactory.createTestDate(hour: 15)
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
