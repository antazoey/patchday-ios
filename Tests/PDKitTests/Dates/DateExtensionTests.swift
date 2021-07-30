//
//  DateExtensionTests.swift
//  PDKitTests
//
//  Created by Juliya Smith on 1/4/19.

import Foundation

import XCTest
@testable
import PDKit

class DateExtensionTests: XCTestCase {

    // Note: If you run these tests at like midnight, you might get weird results.
    // For example, the tests may assume it can add seconds to the current time and have it still be today.

    func testDayValue() {
        let defaultDate = DateFactory.createDefaultDate()
        let actual = defaultDate.dayValue()
        let expected = 31
        XCTAssertEqual(expected, actual)
    }

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
        let atMidnightIsh = Calendar.current.date(
            bySettingHour: 23, minute: 59, second: 59, of: today
        )
        XCTAssertTrue(atMidnightIsh!.isInToday())
    }

    func testIsInTomorrow_whenGivenDateThatIsTomorrow_returnsTrue() {
        guard let tomorrow = DateFactory.createDate(daysFromNow: 1) else {
            XCTFail("Failed creating tomorrow date.")
            return
        }
        XCTAssertTrue(tomorrow.isInTomorrow())
    }

    func testIsInTomorrow_whenGivenDateThatIs0000TheDayAfterTomorrow_returnsFalse() {
        guard let dayAfterTomorrow = DateFactory.createDate(daysFromNow: 2) else {
            XCTFail("Failed creating day after tomorrow date.")
            return
        }
        guard let atMidnight = Calendar.current.date(
            bySettingHour: 0, minute: 0, second: 0, of: dayAfterTomorrow
        ) else {
            XCTFail("Failed creating day after tomorrow at midnight.")
            return
        }
        XCTAssertFalse(atMidnight.isInTomorrow())
    }

    func testIsInTomorrow_whenGivenDateThatIsToday_returnsFalse() {
        XCTAssertFalse(Date().isInTomorrow())
    }

    func testIsInTomorrow_whenGivenDateThatIs2359Tomorrow_returnsTrue() {
        guard let tomorrow = DateFactory.createDate(daysFromNow: 1) else {
            XCTFail("Failed creating tomorrow date.")
            return
        }
        guard let atMidnightIsh = Calendar.current.date(
            bySettingHour: 23, minute: 59, second: 59, of: tomorrow
        ) else {
            XCTFail("Failed creating date tomorrow at midnight ish.")
            return
        }
        XCTAssertTrue(atMidnightIsh.isInTomorrow())
    }

    func testIsInYesterday_whenGivenDateThatIsYesterday_returnsTrue() {
        guard let yesterday = DateFactory.createDate(daysFromNow: -1) else {
            XCTFail("Failed creating yesterday date.")
            return
        }
        tprint(yesterday)
        XCTAssertTrue(yesterday.isInYesterday())
    }

    func testIsInYesterday_whenGivenDateThatIs0000TheDayBeforeYesterday_returnsFalse() {
        guard let dayBeforeYesterday = DateFactory.createDate(daysFromNow: -2) else {
            XCTFail("Failed creating day after yesterday date.")
            return
        }
        guard let atMidnight = Calendar.current.date(
            bySettingHour: 0, minute: 0, second: 0, of: dayBeforeYesterday
        ) else {
            XCTFail("Failed creating day after tomorrow at midnight.")
            return
        }
        XCTAssertFalse(atMidnight.isInYesterday())
    }

    func testIsInYesterday_whenGivenDateThatIsToday_returnsFalse() {
        XCTAssertFalse(Date().isInYesterday())
    }

    func testIsInYesterday_whenGivenDateThatIs2359Yesterday_returnsTrue() {
        guard let yesterday = DateFactory.createDate(daysFromNow: -1) else {
            XCTFail("Failed creating tomorrow date.")
            return
        }
        guard let atMidnightIsh = Calendar.current.date(
            bySettingHour: 23, minute: 59, second: 59, of: yesterday
        ) else {
            XCTFail("Failed creating date tomorrow at midnight ish.")
            return
        }
        XCTAssertTrue(atMidnightIsh.isInYesterday())
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
