//
//  PillTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 1/16/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
import PDKit
import PDMock

@testable
import PatchData

public class PillTests: XCTestCase {

    func createPill(_ attributes: PillAttributes, _ now: NowProtocol?=nil) -> Pill {
        Pill(pillData: PillStruct(UUID(), attributes), now: now)
    }

    func createDueTime(_ time: Date, days: Double) -> Date {
        let date = Date(timeIntervalSinceNow: days * 86400)
        let calendar = Calendar.current
        let components = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date),
            hour: calendar.component(.hour, from: time),
            minute: calendar.component(.minute, from: time),
            second: calendar.component(.second, from: time)
        )
        return calendar.date(from: components)!
    }

    func createPillAttributes(minutesFromNow: Int) -> PillAttributes {
        var attrs = PillAttributes()
        let today = Date()
        let calendar = Calendar.current
        let components = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: calendar.component(.year, from: today),
            month: calendar.component(.month, from: today),
            day: calendar.component(.day, from: today),
            hour: calendar.component(.hour, from: today),
            minute: calendar.component(.minute, from: today) + minutesFromNow
        )
        // Set them both for convenience in testing
        let times = [calendar.date(from: components), calendar.date(from: components)]
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString(times)
        return attrs
    }

    func testExpirationInterval_whenEveryDay_returnsExpectedString() {
        var attrs = PillAttributes()
        attrs.expirationInterval = PillExpirationInterval.EveryDay.rawValue
        let pill = createPill(attrs)
        let actual = pill.expirationInterval
        let expected = PillStrings.Intervals.EveryDay
        XCTAssertEqual(expected, actual)

        // Test set
        pill.expirationInterval = PillStrings.Intervals.EveryOtherDay
        XCTAssertEqual(PillStrings.Intervals.EveryOtherDay, pill.expirationInterval)
    }

    func testExpirationInterval_whenEveryOtherDay_returnsExpectedString() {
        var attrs = PillAttributes()
        attrs.expirationInterval = PillExpirationInterval.EveryOtherDay.rawValue
        let pill = createPill(attrs)
        let actual = pill.expirationInterval
        let expected = PillStrings.Intervals.EveryOtherDay
        XCTAssertEqual(expected, actual)
    }

    func testExpirationInterval_whenFirstTen_returnsExpectedString() {
        var attrs = PillAttributes()
        attrs.expirationInterval = PillExpirationInterval.FirstTenDays.rawValue
        let pill = createPill(attrs)
        let actual = pill.expirationInterval
        let expected = PillStrings.Intervals.FirstTenDays
        XCTAssertEqual(expected, actual)
    }

    func testExpirationInterval_whenLastTen_returnsExpectedString() {
        var attrs = PillAttributes()
        attrs.expirationInterval = PillExpirationInterval.LastTenDays.rawValue
        let pill = createPill(attrs)
        let actual = pill.expirationInterval
        let expected = PillStrings.Intervals.LastTenDays
        XCTAssertEqual(expected, actual)
    }

    func testExpirationInterval_whenFirstTwenty_returnsExpectedString() {
        var attrs = PillAttributes()
        attrs.expirationInterval = PillExpirationInterval.FirstTwentyDays.rawValue
        let pill = createPill(attrs)
        let actual = pill.expirationInterval
        let expected = PillStrings.Intervals.FirstTwentyDays
        XCTAssertEqual(expected, actual)
    }

    func testExpirationInterval_whenLastTwenty_returnsExpectedString() {
        var attrs = PillAttributes()
        attrs.expirationInterval = PillExpirationInterval.LastTwentyDays.rawValue
        let pill = createPill(attrs)
        let actual = pill.expirationInterval
        let expected = PillStrings.Intervals.LastTwentyDays
        XCTAssertEqual(expected, actual)
    }

    func testTimes_whenNilInAttributes_returnsNil() {
        var attrs = PillAttributes()
        attrs.times = nil
        let pill = createPill(attrs)
        XCTAssertEqual(0, pill.times.count)
    }

    func testTimes_returnsTimeFromAttributes() {
        var attrs = PillAttributes()
        attrs.times = PillTestsUtil.testTimeString
        let pill = createPill(attrs)
        let actual = pill.times[0]
        let expected = PillTestsUtil.testTime
        XCTAssertEqual(1, pill.times.count)
        XCTAssert(PDTest.sameTime(expected, actual))
    }

    func testTimes_whenStoredOutOfOrder_reorders() {
        var attrs = PillAttributes()
        let secondTimeString = PillTestsUtil.createTimeString(
            hour: PillTestsUtil.testHour + 1, minute: 0, second: 0
        )
        attrs.times = "\(secondTimeString),\(PillTestsUtil.testTimeString)"
        let pill = createPill(attrs)
        let actualTimes = pill.times
        XCTAssertEqual(2, actualTimes.count)
        XCTAssert(PDTest.sameTime(PillTestsUtil.testTime, actualTimes[0]))
        let expectedNewTime = Calendar.current.date(
            bySettingHour: PillTestsUtil.testHour + 1, minute: 0, second: 0, of: Date()
        )!
        XCTAssert(PDTest.sameTime(expectedNewTime, actualTimes[1]))
    }

    func testAppendTime_whenGivenDefaultValue_doesNotSet() {
        var attrs = PillAttributes()
        let testTimesString = "\(PillTestsUtil.testTimeString)"
        attrs.times = testTimesString
        let pill = createPill(attrs)
        pill.appendTime(DateFactory.createDefaultDate())
        // Only has original time
        XCTAssertEqual(1, pill.times.count)
        XCTAssert(PDTest.sameTime(PillTestsUtil.testTime, pill.times[0]))
    }

    func testAppendTime_whenTimeSecondAndLessThanFirstTime_maintainsOrder() {
        var attrs = PillAttributes()
        let secondTimeString = PillTestsUtil.createTimeString(
            hour: PillTestsUtil.testHour, minute: PillTestsUtil.testSeconds - 1, second: 0
        )
        let secondTime = DateFactory.createTimesFromCommaSeparatedString(secondTimeString)[0]
        attrs.times = "\(PillTestsUtil.testTimeString)"
        let pill = createPill(attrs)
        pill.appendTime(secondTime)
        let actualTimes = pill.times
        XCTAssertEqual(2, pill.times.count)
        XCTAssert(PDTest.sameTime(secondTime, actualTimes[0]))
        XCTAssert(PDTest.sameTime(PillTestsUtil.testTime, actualTimes[1]))
    }

    func testNotify_whenNilInAttributes_returnsDefaultNotify() {
        var attrs = PillAttributes()
        attrs.notify = nil
        let pill = createPill(attrs)
        XCTAssertEqual(DefaultPillAttributes.notify, pill.notify)
    }

    func testTimesaday_returnsCountOfTimes() {
        var attrs = PillAttributes()
        let t2 = PillTestsUtil.createTimeString(
            hour: PillTestsUtil.testHour, minute: PillTestsUtil.testSeconds - 1, second: 0
        )
        let t3 = PillTestsUtil.createTimeString(
            hour: PillTestsUtil.testHour - 8, minute: PillTestsUtil.testSeconds + 12, second: 0
        )
        attrs.times = "\(PillTestsUtil.testTimeString),\(t2),\(t3)"
        let pill = createPill(attrs)
        XCTAssertEqual(3, pill.timesaday)
    }

    public func testTimesTakenToday_whenNilInAttributes_returnsZero() {
        var attrs = PillAttributes()
        attrs.timesTakenToday = nil
        let pill = createPill(attrs)
        let expected = 0
        let actual = pill.timesTakenToday
        XCTAssertEqual(expected, actual)
    }

    func testTimesTakenToday_whenNotNilInAttributes_returnsValueFromAttributes() {
        var attrs = PillAttributes()
        attrs.timesTakenToday = 19
        let pill = createPill(attrs)
        let expected = 19
        let actual = pill.timesTakenToday
        XCTAssertEqual(expected, actual)
    }

    func testSetExpirationInterval_whenGivenUIString_sets() {
        let pill = createPill(PillAttributes())
        pill.expirationInterval = PillStrings.Intervals.LastTenDays
        XCTAssertEqual(PillStrings.Intervals.LastTenDays, pill.expirationInterval)
    }

    func testSetExpirationInterval_whenGivenRawString_setsAndReturnsUIVersion() {
        let pill = createPill(PillAttributes())
        pill.expirationInterval = PillExpirationInterval.LastTenDays.rawValue
        XCTAssertEqual(PillStrings.Intervals.LastTenDays, pill.expirationInterval)
    }

    func testDue_whenEveryDayAndTimesTakenAndNotYetTaken_returnsTodayAtTimeOne() {
        var attrs = PillAttributes()
        let now = Date()
        let testTime = DateFactory.createDate(byAddingSeconds: 61, to: now)!
        attrs.expirationInterval = PillExpirationInterval.EveryDay.rawValue
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        attrs.lastTaken = DateFactory.createDate(byAddingHours: -23, to: now)!
        attrs.notify = true
        attrs.timesTakenToday = 0
        let pill = createPill(attrs)
        let expected = createDueTime(testTime, days: 0)
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenOnceEveryDayAndTakenOnceToday_returnsTomorrowAtTimeOne() {
        var attrs = PillAttributes()
        let testTime = Date(timeIntervalSinceNow: -234233234352)
        attrs.lastTaken = Date(timeIntervalSinceNow: -1000)
        attrs.expirationInterval = PillExpirationInterval.EveryDay.rawValue
        attrs.timesTakenToday = 1
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        let pill = createPill(attrs)
        let expected = createDueTime(testTime, days: 1) // Tomorrow at time one
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTwiceEveryDayAndTakenOnceToday_returnsTodayAtTimeTwo() {
        var attrs = PillAttributes()
        let testTime = Date(timeIntervalSinceNow: -234233234352)
        let testTimeTwo = DateFactory.createDate(byAddingSeconds: 1, to: testTime)
        attrs.lastTaken = Date(timeIntervalSinceNow: -1000)
        attrs.expirationInterval = PillExpirationInterval.EveryDay.rawValue
        attrs.timesTakenToday = 1
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime, testTimeTwo])
        let pill = createPill(attrs)
        let expected = createDueTime(testTimeTwo!, days: 0) // Today at time two
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTwiceEveryDayAndTakenTwiceToday_returnsTomorrowATimeOne() {
        var attrs = PillAttributes()
        let testTime = Date(timeIntervalSinceNow: -234233234352)
        let testTimeTwo = DateFactory.createDate(byAddingSeconds: 1, to: testTime)
        attrs.lastTaken = Date(timeIntervalSinceNow: -1000)
        attrs.expirationInterval = PillExpirationInterval.EveryDay.rawValue
        attrs.timesTakenToday = 2
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime, testTimeTwo])
        let pill = createPill(attrs)
        let expected = createDueTime(testTime, days: 1) // Tomorrow at time one
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenEveryOtherDayAndTakenTwoDaysAgo_returnsTodayAtTimeOne() {
        var attrs = PillAttributes()
        let testTime = Date(timeIntervalSinceNow: -234233234352)
        let testTimeTwo = DateFactory.createDate(byAddingSeconds: 1, to: testTime)
        attrs.lastTaken = DateFactory.createDate(daysFromNow: -2)
        attrs.expirationInterval = PillExpirationInterval.EveryOtherDay.rawValue
        attrs.timesTakenToday = 0
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime, testTimeTwo])
        let pill = createPill(attrs)
        let expected = createDueTime(testTime, days: 0)
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenOnceEveryOtherDayAndTakenOnceToday_returnsTwoDaysFromNowAtTimeOne() {
        var attrs = PillAttributes()
        let testTime = Date(timeIntervalSinceNow: -234233234352)
        attrs.lastTaken = DateFactory.createDate(daysFromNow: 0)
        attrs.expirationInterval = PillExpirationInterval.EveryOtherDay.rawValue
        attrs.timesTakenToday = 1
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        let pill = createPill(attrs)
        let expected = createDueTime(testTime, days: 2)
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTwiceEveryOtherDayAndTakenOnceToday_returnsTodayAtTimeTwo() {
        var attrs = PillAttributes()
        let testTime = Date(timeIntervalSinceNow: -234233234352)
        let testTimeTwo = DateFactory.createDate(byAddingSeconds: 1, to: testTime)!
        attrs.lastTaken = DateFactory.createDate(daysFromNow: 0)
        attrs.expirationInterval = PillExpirationInterval.EveryOtherDay.rawValue
        attrs.timesTakenToday = 1
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime, testTimeTwo])
        let pill = createPill(attrs)
        let expected = createDueTime(testTimeTwo, days: 0) // Today at time two
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTwiceEveryOtherDayAndTakenTwiceToday_returnsTwosDaysFromNowAtTimeOne() {
        var attrs = PillAttributes()
        let testTime = Date(timeIntervalSinceNow: -234233234352)
        let testTimeTwo = DateFactory.createDate(byAddingSeconds: 1, to: testTime)!
        attrs.lastTaken = DateFactory.createDate(daysFromNow: 0)
        attrs.expirationInterval = PillExpirationInterval.EveryOtherDay.rawValue
        attrs.timesTakenToday = 2
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime, testTimeTwo])
        let pill = createPill(attrs)
        let expected = createDueTime(testTime, days: 2)
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenEveryOtherDayAndTakenYesterday_returnsTomorrowAtTimeOne() {
        var attrs = PillAttributes()
        let testTime = Date(timeIntervalSinceNow: -234233234352)
        attrs.lastTaken = DateFactory.createDate(daysFromNow: -1)
        attrs.expirationInterval = PillExpirationInterval.EveryOtherDay.rawValue
        attrs.timesTakenToday = 0
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        let pill = createPill(attrs)
        let expected = createDueTime(testTime, days: 1)
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenFirstTenDaysAndFinishedOnTenthDay_returnsFirstOfNextMonthAtTimeOne() {
        var attrs = PillAttributes()
        let testTime = Date(timeIntervalSinceNow: -234233234352)
        let cal = Calendar.current
        attrs.lastTaken = cal.date(bySetting: .day, value: 10, of: Date())
        attrs.expirationInterval = PillExpirationInterval.FirstTenDays.rawValue
        attrs.timesTakenToday = 1
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        let pill = createPill(attrs)
        let date = cal.date(bySetting: .day, value: 1, of: attrs.lastTaken!)!
        let expected = DateFactory.createDate(on: date, at: testTime)!
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenEveryFirstTenDaysAndIsDuringThoseTenDays_returnsExpectedDate() {
        var attrs = PillAttributes()
        let testTime = Date(timeIntervalSinceNow: -234233234352)
        attrs.timesTakenToday = 0
        attrs.lastTaken = DateFactory.createDate(daysFromNow: -1)
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        let pill = createPill(attrs)
        let actual = pill.due
        let expected = DateFactory.createDate(on: Date(), at: testTime)
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenFirstTenDaysAndFinishedOnTwentiethDay_returnsFirstOfNextMonthAtTimeOne() {
        var attrs = PillAttributes()
        let testTime = Date(timeIntervalSinceNow: -234233234352)
        let cal = Calendar.current
        attrs.lastTaken = cal.date(bySetting: .day, value: 20, of: Date())
        attrs.expirationInterval = PillExpirationInterval.FirstTenDays.rawValue
        attrs.timesTakenToday = 1
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        let pill = createPill(attrs)
        let date = cal.date(bySetting: .day, value: 1, of: attrs.lastTaken!)!
        let expected = DateFactory.createDate(on: date, at: testTime)!
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenFirstTwentyDaysAndFinishedOnTwentiethDay_returnsFirstOfNextMonthAtTimeOne() {
        var attrs = PillAttributes()
        let testTime = Date(timeIntervalSinceNow: -234233234352)
        let cal = Calendar.current
        attrs.lastTaken = cal.date(bySetting: .day, value: 20, of: Date())
        attrs.expirationInterval = PillExpirationInterval.FirstTwentyDays.rawValue
        attrs.timesTakenToday = 1
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        let pill = createPill(attrs)
        let date = cal.date(bySetting: .day, value: 1, of: attrs.lastTaken!)!
        let expected = DateFactory.createDate(on: date, at: testTime)!
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenFirstTwentyDaysAndNotYetFinishedOnNineteenthDay_returnsSameDayAtTimeOne() {
        var attrs = PillAttributes()
        let testTime = Date(timeIntervalSinceNow: -234233234352)
        let cal = Calendar.current
        attrs.lastTaken = cal.date(bySetting: .day, value: 18, of: Date())
        attrs.expirationInterval = PillExpirationInterval.FirstTwentyDays.rawValue
        attrs.timesTakenToday = 0
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        let now = MockNow()
        now.now = cal.date(bySetting: .day, value: 19, of: Date())!
        let pill = createPill(attrs, now)
        let date = cal.date(bySetting: .day, value: 19, of: attrs.lastTaken!)!
        let expected = DateFactory.createDate(on: date, at: testTime)!
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenFirstTwentyDaysAndFinishedOnNineteenthDay_returnsNextDayAtTimeOne() {
        var attrs = PillAttributes()
        let testTime = Date(timeIntervalSinceNow: -234233234352)
        let cal = Calendar.current
        attrs.lastTaken = cal.date(bySetting: .day, value: 19, of: Date())
        attrs.expirationInterval = PillExpirationInterval.FirstTwentyDays.rawValue
        attrs.timesTakenToday = 1
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        let now = MockNow()
        now.now = cal.date(bySetting: .day, value: 19, of: Date())!
        let pill = createPill(attrs, now)
        let date = cal.date(bySetting: .day, value: 20, of: attrs.lastTaken!)!
        let expected = DateFactory.createDate(on: date, at: testTime)!
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenLastTenDaysAndFinishedOnLastDayOfMonth_returnsExpectedDate() {
        var attrs = PillAttributes()
        let testTime = Date(timeIntervalSinceNow: -234233234352)
        let cal = Calendar.current
        let last = Date().daysInMonth()!
        attrs.lastTaken = cal.date(bySetting: .day, value: last, of: Date())
        attrs.expirationInterval = PillExpirationInterval.LastTenDays.rawValue
        attrs.timesTakenToday = 1
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        let day = attrs.lastTaken!.daysInMonth()! - 10
        let pill = createPill(attrs)
        let date = cal.date(bySetting: .day, value: day, of: attrs.lastTaken!)!
        let expected = DateFactory.createDate(on: date, at: testTime)!
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenLastTakenTwentyDaysAndFinishedOnLastDayOfMonth_returnsExpectedDate() {
        var attrs = PillAttributes()
        let testTime = Date(timeIntervalSinceNow: -234233234352)
        let cal = Calendar.current
        let last = Date().daysInMonth()!
        attrs.lastTaken = cal.date(bySetting: .day, value: last, of: Date())
        attrs.expirationInterval = PillExpirationInterval.LastTwentyDays.rawValue
        attrs.timesTakenToday = 1
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])

        // Set "now" to end of last month.
        let now = MockNow()
        now.now = attrs.lastTaken!

        let day = attrs.lastTaken!.daysInMonth()! - 20
        let pill = createPill(attrs, now)
        let date = cal.date(bySetting: .day, value: day, of: attrs.lastTaken!)!
        let expected = DateFactory.createDate(on: date, at: testTime)!
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenLastTwentyDaysAndIsFirstOfMonth_returnsFirstOfLastTwentyDaysAtTimeOne() {
        let cal = Calendar.current
        let testTime = Date(timeIntervalSinceNow: -234233234352)
        var attrs = PillAttributes()
        let realNow = Date()
        let lastDayNumInCurrentMonth = Date().daysInMonth()!
        attrs.expirationInterval = PillExpirationInterval.LastTwentyDays.rawValue
        attrs.timesTakenToday = 0
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        // Set "now" to first of the month
        var firstOfMonth = cal.date(bySetting: .day, value: 1, of: realNow)!
        firstOfMonth = cal.date(byAdding: .day, value: -lastDayNumInCurrentMonth, to: firstOfMonth)!
        let now = MockNow()
        now.now = firstOfMonth

        // Last taken last day of last month
        let randomDateLastMonth = DateFactory.createDate(byAddingHours: -24, to: Date())!
        let lastDayNumInLastMonth = randomDateLastMonth.daysInMonth()!
        var comps = DateComponents()
        comps.month = -1
        attrs.lastTaken = cal.date(
            byAdding: comps,
            to: cal.date(bySetting: .day, value: lastDayNumInLastMonth, of: randomDateLastMonth)!
        )!
        print(attrs.lastTaken!)
        print(now.now)

        let pill = createPill(attrs, now)
        let timeOne = pill.times[0]
        let expectedDay = cal.date(bySetting: .day, value: lastDayNumInCurrentMonth-19, of: attrs.lastTaken!)!
        let expected = DateFactory.createDate(on: expectedDay, at: timeOne)!
        let actual = pill.due!
        XCTAssertEqual(expected, actual)
    }

    func testIsDue_whenTimesTakenTodayEqualsTimesday_returnsFalse() {
        var attrs = createPillAttributes(minutesFromNow: -5)
        attrs.lastTaken = Date(timeIntervalSinceNow: -1000)
        attrs.timesTakenToday = 2
        attrs.times = "12:00:00,12:00:10"
        let pill = createPill(attrs)
        XCTAssertFalse(pill.isDue)
    }

    func testIsDue_whenPillNotYetTakenAndTimeOneIsPast_returnsTrue() {
        var attrs = createPillAttributes(minutesFromNow: -5)
        let pastDate = Date(timeInterval: -5, since: Date())
        let pastDateString = PDDateFormatter.convertDatesToCommaSeparatedString([pastDate])
        attrs.lastTaken = Date(timeIntervalSinceNow: -1000)
        attrs.timesTakenToday = 0
        attrs.times = pastDateString
        let pill = createPill(attrs)
        XCTAssertTrue(pill.isDue)
    }

    func testIsDue_whenPillTakenTodayAndTimesadayIsOne_returnsFalse() {
        var attrs = createPillAttributes(minutesFromNow: -5)
        attrs.timesTakenToday = 1
        attrs.times = "12:00:00"
        let pill = createPill(attrs)
        XCTAssertFalse(pill.isDue)
    }

    func testIsDue_whenPillTakenOnceAndTimesadayIsTwoAndTimesTwoIsNotPast_returnsFalse() {
        var attrs = createPillAttributes(minutesFromNow: 5)
        let pastDate = Date(timeInterval: -5, since: Date())
        let notPastDate = Date(timeInterval: 5, since: Date())
        let timeString = PDDateFormatter.convertDatesToCommaSeparatedString([notPastDate, pastDate])
        attrs.timesTakenToday = 1
        attrs.times = timeString
        let pill = createPill(attrs)
        XCTAssertFalse(pill.isDue)
    }

    func testIsDue_whenPillTakenOnceAndTimesadayIsTwoAndTimesTwoIsPast_returnsTrue() {
        var attrs = createPillAttributes(minutesFromNow: -5)
        let pastDateOne = Date(timeInterval: -50, since: Date())
        let pastDateTwo = Date(timeInterval: -5, since: Date())
        let timeString = PDDateFormatter.convertDatesToCommaSeparatedString(
            [pastDateOne, pastDateTwo]
        )
        attrs.lastTaken = Date(timeIntervalSinceNow: -1000)
        attrs.timesTakenToday = 1
        attrs.times = timeString
        let pill = createPill(attrs)
        XCTAssert(pill.isDue)
    }

    func testIsDue_whenPillTakenTwiceTodayAndTimesadayIsTwo_returnsFalse() {
        var attrs = createPillAttributes(minutesFromNow: -5)
        attrs.timesTakenToday = 2
        attrs.times = "12:00:00,12:00:10"
        let pill = createPill(attrs)
        XCTAssertFalse(pill.isDue)
    }

    func testIsDue_whenNeverTakenByWayOfNil_returnsFalse() {
        var attrs = createPillAttributes(minutesFromNow: -5)
        attrs.lastTaken = nil
        attrs.times = "12:00:00"
        attrs.timesTakenToday = 0
        let pill = createPill(attrs)
        XCTAssertFalse(pill.isDue)
    }

    func testIsDue_whenNeverTakenByWayOfDefault_returnsFalse() {
        var attrs = createPillAttributes(minutesFromNow: -5)
        attrs.lastTaken = DateFactory.createDefaultDate()
        attrs.times = "12:00:00"
        attrs.timesTakenToday = 0
        let pill = createPill(attrs)
        XCTAssertFalse(pill.isDue)
    }

    func testIsNew_whenLastTakenIsNilAndNameIsDefault_returnsTrue() {
        var attrs = PillAttributes()
        attrs.lastTaken = nil
        attrs.name = PillStrings.NewPill
        let pill = createPill(attrs)
        XCTAssertTrue(pill.isNew)
    }

    func testIsNew_whenLastTakenIsNilAndNameIsEmpty_returnsTrue() {
        var attrs = PillAttributes()
        attrs.lastTaken = nil
        attrs.name = ""
        let pill = createPill(attrs)
        XCTAssertTrue(pill.isNew)
    }

    func testIsNew_whenLastTakenIsNilAndNameIsNotEmpty_returnsFalse() {
        var attrs = PillAttributes()
        attrs.lastTaken = nil
        attrs.name = "Testosterone"
        let pill = createPill(attrs)
        XCTAssertFalse(pill.isNew)
    }

    func testHasName_whenNameIsDefault_returnsFalse() {
        var attrs = PillAttributes()
        attrs.name = PillStrings.NewPill
        let pill = createPill(attrs)
        XCTAssertFalse(pill.hasName)
    }

    func testHasName_whenNameIsEmpty_returnsFalse() {
        var attrs = PillAttributes()
        attrs.name = ""
        let pill = createPill(attrs)
        XCTAssertFalse(pill.hasName)
    }

    func testHasName_whenNameIsSet_returnsTrue() {
        var attrs = PillAttributes()
        attrs.name = "Testosterone"
        let pill = createPill(attrs)
        XCTAssertTrue(pill.hasName)
    }

    func testIsNew_whenLastTakenHasValue_returnsFalse() {
        var attrs = PillAttributes()
        attrs.lastTaken = Date()
        let pill = createPill(attrs)
        XCTAssertFalse(pill.isNew)
    }

    func testIsDone_whenTimesTakenIsLessThanTimesaday_returnsFalse() {
        var attrs = PillAttributes()
        attrs.times = "12:00:00,12:00:10"
        attrs.timesTakenToday = 1
        attrs.lastTaken = Date()
        let pill = createPill(attrs)
        XCTAssertFalse(pill.isDone)
    }

    func testIsDone_whenTimesTakenIsEqualToTimesaday_returnsTrue() {
        var attrs = PillAttributes()
        attrs.times = "12:00:00,12:00:10"
        attrs.timesTakenToday = 2
        attrs.lastTaken = Date()
        let pill = createPill(attrs)
        XCTAssertTrue(pill.isDone)
    }

    func testIsDone_whenTimesTakenIsGreaterThanTimesaday_returnsTrue() {
        var attrs = PillAttributes()
        attrs.times = "12:00:00,12:00:10"
        attrs.timesTakenToday = 3
        attrs.lastTaken = Date()
        let pill = createPill(attrs)
        XCTAssertTrue(pill.isDone)
    }

    func testIsDone_whenLastTakenIsNil_returnsFalse() {
        var attrs = PillAttributes()
        attrs.times = "12:00:00,12:00:10"
        attrs.timesTakenToday = 3
        attrs.lastTaken = nil
        let pill = createPill(attrs)
        XCTAssertFalse(pill.isDone)
    }

    func testSet_setsGivenAttributes() {
        let newName = "New Pill Name"
        let newTime1 = Date()
        let newTime2 = Date()
        let timesString = PDDateFormatter.convertDatesToCommaSeparatedString([newTime1, newTime2])
        let newLastTaken = Date()
        let newExpiration = PillStrings.Intervals.FirstTenDays
        let pill = createPill(PillAttributes())
        var newAttrs = PillAttributes()
        newAttrs.name = newName
        newAttrs.times = timesString
        newAttrs.notify = true
        newAttrs.lastTaken = newLastTaken
        newAttrs.expirationInterval = newExpiration
        pill.set(attributes: newAttrs)
        XCTAssertEqual(newName, pill.name)
        XCTAssert(PDTest.sameTime(newTime1, pill.times[0]))
        XCTAssert(PDTest.sameTime(newTime2, pill.times[1]))
        XCTAssert(pill.notify)
        XCTAssertEqual(newLastTaken, pill.lastTaken)
        XCTAssertEqual(PillStrings.Intervals.FirstTenDays, pill.expirationInterval)
    }

    func testSet_whenGivenNil_doesNotSet() {
        var startAttrs = PillAttributes()
        let testName = "NAME"
        let testDate = Date()
        let testTimeString = "12:00:00"
        startAttrs.name = testName
        startAttrs.lastTaken = testDate
        startAttrs.times = testTimeString
        startAttrs.notify = true
        startAttrs.timesTakenToday = 2
        let pill = createPill(startAttrs)
        var newAttrs = PillAttributes()
        newAttrs.name = nil
        newAttrs.lastTaken = nil
        newAttrs.times = nil
        newAttrs.notify = nil
        newAttrs.timesTakenToday = nil
        pill.set(attributes: newAttrs)
        XCTAssertEqual(testName, pill.name)
        XCTAssertEqual(testDate, pill.lastTaken)
        XCTAssertEqual(
            testTimeString, PDDateFormatter.convertDatesToCommaSeparatedString(pill.times)
        )
        XCTAssert(pill.notify)
        XCTAssertEqual(2, pill.timesTakenToday)
    }

    func testSwallow_whenTimesTakenTodayEqualToTimesaday_doesNotIncreaseTimesTakenToday() {
        var attrs = PillAttributes()
        attrs.times = "12:00:00"
        attrs.timesTakenToday = 1
        attrs.lastTaken = Date()
        let pill = createPill(attrs)
        pill.swallow()
        XCTAssertEqual(1, pill.timesTakenToday)
    }

    func testSwallow_whenTimesTakenTodayEqualToTimesaday_doesNotSetLastTaken() {
        var attrs = PillAttributes()
        let originalLastTaken = Date()
        attrs.lastTaken = originalLastTaken
        attrs.times = "12:00:00"
        attrs.timesTakenToday = 1
        let pill = createPill(attrs)
        pill.swallow()
        XCTAssertEqual(originalLastTaken, pill.lastTaken)
    }

    func testSwallow_whenTimesTakenTodayIsLessThanTimesaday_increasesTimesTakenToday() {
        var attrs = PillAttributes()
        attrs.times = "12:00:00"
        attrs.timesTakenToday = 0
        attrs.lastTaken = Date()
        let pill = createPill(attrs)
        pill.swallow()
        XCTAssertEqual(1, pill.timesTakenToday)
    }

    func testSwallow_whenTimesTakenTodayIsLessThanTimesaday_stampsLastTaken() {
        var attrs = PillAttributes()
        let originalLastTaken = Date()
        attrs.lastTaken = originalLastTaken
        attrs.times = "12:00:00"
        attrs.timesTakenToday = 0
        let pill = createPill(attrs)
        pill.swallow()
        XCTAssert(originalLastTaken < pill.lastTaken! && pill.lastTaken! < Date())
    }

    func testSwallow_whenLastTakenIsNil_increasesTimesTakenToday() {
        var attrs = PillAttributes()
        attrs.times = "12:00:00"
        attrs.timesTakenToday = 1
        attrs.lastTaken = nil
        let pill = createPill(attrs)
        pill.swallow()
        XCTAssertEqual(2, pill.timesTakenToday)
    }

    func testSwallow_whenLastTakenIsNil_stampsLastTaken() {
        var attrs = PillAttributes()
        attrs.lastTaken = nil
        attrs.times = "12:00:00"
        attrs.timesTakenToday = 1
        let pill = createPill(attrs)
        pill.swallow()
        XCTAssert(Date().timeIntervalSince(pill.lastTaken!) < 0.1)
    }

    func testAwaken_whenLastTakenWasToday_doesNotSetTimesTakenTodayToZero() {
        var attrs = PillAttributes()
        attrs.timesTakenToday = 2
        attrs.lastTaken = Date()
        let pill = createPill(attrs)
        pill.awaken()
        XCTAssertEqual(2, pill.timesTakenToday)
    }

    func testAwaken_whenLastTakenWasYesterday_setsTimesTakenTodayToZero() {
        var attrs = PillAttributes()
        attrs.timesTakenToday = 2
        attrs.lastTaken = Date(timeIntervalSinceNow: -86400)
        let pill = createPill(attrs)
        pill.awaken()
        XCTAssertEqual(0, pill.timesTakenToday)
    }
}
