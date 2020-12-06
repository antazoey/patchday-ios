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

    func createDueTime(_ time: Date, days: Double, now: Date) -> Date {
        let date = DateFactory.createDate(byAddingHours: Int(days) * 24, to: now)!
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

    func testExpirationInterval_whenNothingSet_returnsDefault() {
        var attrs = PillAttributes()
        attrs.expirationInterval = nil
        let pill = createPill(attrs)
        let actual = pill.expirationInterval
        let expected = DefaultPillAttributes.expirationInterval
        XCTAssertEqual(expected, actual)
    }

    func testExpirationInterval_whenEveryDay_returnsExpectedInterval() {
        var attrs = PillAttributes()
        attrs.expirationInterval = PillExpirationInterval.EveryDay
        let pill = createPill(attrs)
        let actual = pill.expirationInterval
        let expected = PillExpirationInterval.EveryDay
        XCTAssertEqual(expected, actual)

        // Test set
        pill.expirationInterval = PillExpirationInterval.EveryDay
        XCTAssertEqual(PillExpirationInterval.EveryDay, pill.expirationInterval)
    }

    func testExpirationInterval_whenEveryOtherDay_returnsExpectedInterval() {
        var attrs = PillAttributes()
        attrs.expirationInterval = PillExpirationInterval.EveryOtherDay
        let pill = createPill(attrs)
        let actual = pill.expirationInterval
        XCTAssertEqual(PillExpirationInterval.EveryOtherDay, actual)
    }

    func testExpirationInterval_whenFirstTen_returnsExpectedInterval() {
        var attrs = PillAttributes()
        attrs.expirationInterval = PillExpirationInterval.FirstTenDays
        let pill = createPill(attrs)
        let actual = pill.expirationInterval
        XCTAssertEqual(PillExpirationInterval.FirstTenDays, actual)
    }

    func testExpirationInterval_whenLastTen_returnsExpectedInterval() {
        var attrs = PillAttributes()
        attrs.expirationInterval = PillExpirationInterval.LastTenDays
        let pill = createPill(attrs)
        let actual = pill.expirationInterval
        XCTAssertEqual(PillExpirationInterval.LastTenDays, actual)
    }

    func testExpirationInterval_whenFirstTwenty_returnsExpectedInterval() {
        var attrs = PillAttributes()
        attrs.expirationInterval = PillExpirationInterval.FirstTwentyDays
        let pill = createPill(attrs)
        let actual = pill.expirationInterval
        XCTAssertEqual(PillExpirationInterval.FirstTwentyDays, actual)
    }

    func testExpirationInterval_whenLastTwenty_returnsExpectedString() {
        var attrs = PillAttributes()
        attrs.expirationInterval = PillExpirationInterval.LastTwentyDays
        let pill = createPill(attrs)
        let actual = pill.expirationInterval
        XCTAssertEqual(PillExpirationInterval.LastTwentyDays, actual)
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

    func testDue_whenEveryDayAndNotYetTaken_returnsTodayAtTimeOne() {
        var attrs = PillAttributes()
        let now = Date()
        let testTime = DateFactory.createDate(byAddingSeconds: 61, to: now)!
        attrs.expirationInterval = PillExpirationInterval.EveryDay
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        attrs.lastTaken = DateFactory.createDate(byAddingHours: -23, to: now)!
        attrs.notify = true
        attrs.timesTakenToday = 0
        let pill = createPill(attrs)
        let expected = createDueTime(testTime, days: 0, now: now)
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenEveryDayAndNotYetTakenAndIsPastTime_returnsTodayAtTimeOne() {
        var attrs = PillAttributes()
        let now = Date()
        let testTime = DateFactory.createDate(byAddingSeconds: -61, to: now)!
        attrs.expirationInterval = PillExpirationInterval.EveryDay
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        attrs.lastTaken = DateFactory.createDate(byAddingHours: -23, to: now)!
        attrs.notify = true
        attrs.timesTakenToday = 0
        let pill = createPill(attrs)
        let expected = createDueTime(testTime, days: 0, now: now)
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenOnceEveryDayAndTakenOnceToday_returnsTomorrowAtTimeOne() {
        var attrs = PillAttributes()
        let now = MockNow()
        now.now = DateFactory.createDate(byAddingMonths: 2, to: DateFactory.createDefaultDate())!
        let testTime = DateFactory.createDate(byAddingMinutes: -5, to: now.now)!
        attrs.lastTaken = DateFactory.createDate(byAddingSeconds: -1, to: now.now)
        attrs.expirationInterval = PillExpirationInterval.EveryDay
        attrs.timesTakenToday = 1
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        let pill = createPill(attrs, now)
        let expected = createDueTime(testTime, days: 1, now: now.now) // Tomorrow at time one
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTwiceEveryDayAndTakenOnceToday_returnsTodayAtTimeTwo() {
        var attrs = PillAttributes()
        let now = MockNow()
        now.now = DateFactory.createDate(byAddingMonths: 2, to: DateFactory.createDefaultDate())!
        let testTime = DateFactory.createDate(byAddingMinutes: -5, to: now.now)!
        let testTimeTwo = DateFactory.createDate(byAddingSeconds: 1, to: testTime)
        attrs.lastTaken = DateFactory.createDate(byAddingSeconds: -1, to: now.now)
        attrs.expirationInterval = PillExpirationInterval.EveryDay
        attrs.timesTakenToday = 1
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime, testTimeTwo])
        let pill = createPill(attrs, now)
        let expected = createDueTime(testTimeTwo!, days: 0, now: now.now) // Today at time two
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTwiceEveryDayAndTakenTwiceToday_returnsTomorrowATimeOne() {
        var attrs = PillAttributes()
        let now = MockNow()
        now.now = DateFactory.createDate(byAddingMonths: 2, to: DateFactory.createDefaultDate())!
        let testTime = DateFactory.createDate(byAddingMinutes: -5, to: now.now)!
        let testTimeTwo = DateFactory.createDate(byAddingSeconds: 1, to: testTime)
        attrs.lastTaken = DateFactory.createDate(byAddingSeconds: -1, to: now.now)
        attrs.expirationInterval = PillExpirationInterval.EveryDay
        attrs.timesTakenToday = 2
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime, testTimeTwo])
        let pill = createPill(attrs, now)
        let expected = createDueTime(testTime, days: 1, now: now.now) // Tomorrow at time one
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenThriceEveryDayAndTakenTwiceToday_returnsTodayATimeThree() {
        var attrs = PillAttributes()
        let now = MockNow()
        now.now = DateFactory.createDate(byAddingMonths: 2, to: DateFactory.createDefaultDate())!
        attrs.lastTaken = DateFactory.createDate(byAddingSeconds: -1, to: now.now)
        let testTime = DateFactory.createDate(byAddingMinutes: -5, to: now.now)!
        let testTimeTwo = DateFactory.createDate(byAddingSeconds: 1, to: testTime)!
        let testTimeThree = DateFactory.createDate(byAddingSeconds: 100, to: testTime)!
        let times = [testTime, testTimeTwo, testTimeThree]
        attrs.lastTaken = DateFactory.createDate(byAddingSeconds: -1, to: now.now)
        attrs.expirationInterval = PillExpirationInterval.EveryDay
        attrs.timesTakenToday = 2
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString(times)
        let pill = createPill(attrs, now)
        let expected = createDueTime(testTimeThree, days: 0, now: now.now)  // Today at time three
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenFourTimesEveryDayAndTakenFourTimesToday_returnsTomorrowATimeOne() {
        var attrs = PillAttributes()
        let now = MockNow()
        now.now = DateFactory.createDate(byAddingMonths: 2, to: DateFactory.createDefaultDate())!
        let testTime = DateFactory.createDate(byAddingMinutes: -5, to: now.now)!
        let testTimeTwo = DateFactory.createDate(byAddingSeconds: 1, to: testTime)!
        let testTimeThree = DateFactory.createDate(byAddingSeconds: 100, to: testTime)!
        let testTimeFour = DateFactory.createDate(byAddingSeconds: 250, to: testTime)!
        let times = [testTime, testTimeTwo, testTimeThree, testTimeFour]
        attrs.lastTaken = DateFactory.createDate(byAddingSeconds: -1, to: now.now)
        attrs.expirationInterval = PillExpirationInterval.EveryDay
        attrs.timesTakenToday = 4
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString(times)
        let pill = createPill(attrs, now)
        let expected = createDueTime(testTime, days: 1, now: now.now) // Tomorrow at time one
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenEveryOtherDayAndTakenTwoDaysAgo_returnsTodayAtTimeOne() {
        var attrs = PillAttributes()
        let now = MockNow()
        now.now = DateFactory.createDate(byAddingMonths: 2, to: DateFactory.createDefaultDate())!
        let testTime = DateFactory.createDate(byAddingMinutes: 5, to: now.now)!
        let testTimeTwo = DateFactory.createDate(byAddingSeconds: 1, to: testTime)
        attrs.lastTaken = DateFactory.createDate(byAddingSeconds: -1, to: now.now)
        attrs.expirationInterval = PillExpirationInterval.EveryOtherDay
        attrs.timesTakenToday = 0
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime, testTimeTwo])
        let pill = createPill(attrs, now)
        let expected = createDueTime(testTime, days: 0, now: now.now)
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenEveryOtherDayAndTakenOnceToday_returnsTwoDaysFromNowAtTimeOne() {
        var attrs = PillAttributes()
        let now = MockNow()
        now.now = DateFactory.createDate(byAddingMonths: 2, to: DateFactory.createDefaultDate())!
        let testTime = DateFactory.createDate(byAddingMinutes: 5, to: now.now)!
        attrs.lastTaken = DateFactory.createDate(daysFromNow: 0, now: now)
        attrs.expirationInterval = PillExpirationInterval.EveryOtherDay
        attrs.timesTakenToday = 1
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        let pill = createPill(attrs, now)
        let expected = createDueTime(testTime, days: 2, now: now.now)
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTwiceEveryOtherDayAndTakenOnceToday_returnsTodayAtTimeTwo() {
        var attrs = PillAttributes()
        let now = MockNow()
        now.now = DateFactory.createDate(byAddingMonths: 2, to: DateFactory.createDefaultDate())!
        let testTime = DateFactory.createDate(byAddingMinutes: -5, to: now.now)!
        let testTimeTwo = DateFactory.createDate(byAddingSeconds: 1, to: testTime)!
        attrs.lastTaken = DateFactory.createDate(daysFromNow: 0, now: now)
        attrs.expirationInterval = PillExpirationInterval.EveryOtherDay
        attrs.timesTakenToday = 1
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime, testTimeTwo])
        let pill = createPill(attrs, now)
        let expected = createDueTime(testTimeTwo, days: 0, now: now.now) // Today at time two
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTwiceEveryOtherDayAndTakenTwiceToday_returnsTwoDaysFromNowAtTimeOne() {
        var attrs = PillAttributes()
        let now = MockNow()
        now.now = DateFactory.createDate(byAddingMonths: 2, to: DateFactory.createDefaultDate())!
        let testTime = DateFactory.createDate(byAddingMinutes: 5, to: now.now)!
        let testTimeTwo = DateFactory.createDate(byAddingSeconds: 1, to: testTime)!
        attrs.lastTaken = DateFactory.createDate(daysFromNow: 0, now: now)
        attrs.expirationInterval = PillExpirationInterval.EveryOtherDay
        attrs.timesTakenToday = 2
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime, testTimeTwo])
        let pill = createPill(attrs, now)
        let expected = createDueTime(testTime, days: 2, now: now.now)
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenEveryOtherDayAndTakenYesterday_returnsTomorrowAtTimeOne() {
        var attrs = PillAttributes()
        let now = MockNow()
        now.now = DateFactory.createDate(byAddingMonths: 2, to: DateFactory.createDefaultDate())!
        now.isInYesterdayReturnValue = true
        let testTime = DateFactory.createDate(byAddingMinutes: -5, to: now.now)!
        attrs.lastTaken = DateFactory.createDate(daysFromNow: -1, now: now)
        attrs.expirationInterval = PillExpirationInterval.EveryOtherDay
        attrs.timesTakenToday = 0
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        let pill = createPill(attrs, now)
        let expected = createDueTime(testTime, days: 1, now: now.now)
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenFirstTenDaysAndFinishedOnTenthDay_returnsFirstOfNextMonthAtTimeOne() {
        var attrs = PillAttributes()
        attrs.expirationInterval = PillExpirationInterval.FirstTenDays
        attrs.timesTakenToday = 1
        let now = MockNow()

        // 01/01
        let startDate = DateFactory.createDate(
            byAddingHours: 12, to: DateFactory.createDefaultDate()
        )!

        // 01/10
        let lastTaken = DateFactory.createDate(byAddingHours: 24*9, to: startDate)!

        // 01/10
        now.now = lastTaken

        // 02/01
        let expectedDay = DateFactory.createDate(byAddingHours: 24*31, to: startDate)!

        let testTime = DateFactory.createDate(byAddingHours: -1, to: now.now)!
        attrs.lastTaken = lastTaken
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        let pill = createPill(attrs, now)
        let expected = DateFactory.createDate(on: expectedDay, at: testTime)!
        let actual = pill.due!
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenEveryFirstTenDaysAndIsDuringThoseTenDays_returnsExpectedDate() {
        var attrs = PillAttributes()
        attrs.expirationInterval = PillExpirationInterval.FirstTenDays
        attrs.timesTakenToday = 1
        let now = MockNow()

        // 01/01
        let startDate = DateFactory.createDate(
            byAddingHours: 12, to: DateFactory.createDefaultDate()
        )!

        // 01/08
        let lastTaken = DateFactory.createDate(byAddingHours: 24*7, to: startDate)!

        // 01/09
        now.now = DateFactory.createDate(byAddingHours: 24*8, to: startDate)!

        // 01/10
        let expectedDay = DateFactory.createDate(byAddingHours: 24*9, to: startDate)!

        let testTime = DateFactory.createDate(byAddingHours: -1, to: now.now)!
        attrs.lastTaken = lastTaken
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        let pill = createPill(attrs, now)
        let expected = DateFactory.createDate(on: expectedDay, at: testTime)!
        let actual = pill.due!
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenFirstTenDaysAndFinishedOnTwentiethDay_returnsFirstOfNextMonthAtTimeOne() {
        var attrs = PillAttributes()
        attrs.expirationInterval = PillExpirationInterval.FirstTenDays
        attrs.timesTakenToday = 0
        let now = MockNow()

        // 01/01
        let startDate = DateFactory.createDate(
            byAddingHours: 12, to: DateFactory.createDefaultDate()
        )!

        // 01/10
        let lastTaken = DateFactory.createDate(byAddingHours: 24*9, to: startDate)!

        // 01/20
        let lastDay = DateFactory.createDate(byAddingHours: 24*19, to: startDate)!
        now.now = lastDay

        // 02/01
        let expectedDay = DateFactory.createDate(byAddingHours: 24*31, to: startDate)!

        let testTime = DateFactory.createDate(byAddingHours: -1, to: now.now)!
        attrs.lastTaken = lastTaken
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        let pill = createPill(attrs, now)
        let expected = DateFactory.createDate(on: expectedDay, at: testTime)!
        let actual = pill.due!
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenFirstTwentyDaysAndFinishedOnTwentiethDay_returnsFirstOfNextMonthAtTimeOne() {
        var attrs = PillAttributes()
        attrs.expirationInterval = PillExpirationInterval.FirstTwentyDays
        attrs.timesTakenToday = 1
        let now = MockNow()

        // 01/01
        let startDate = DateFactory.createDate(
            byAddingHours: 12, to: DateFactory.createDefaultDate()
        )!

        // 01/20
        let lastDay = DateFactory.createDate(byAddingHours: 24*19, to: startDate)!
        now.now = lastDay

        // 02/01
        let expectedDay = DateFactory.createDate(byAddingHours: 24*31, to: startDate)!

        let testTime = DateFactory.createDate(byAddingHours: -1, to: now.now)!
        attrs.lastTaken = testTime
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        let pill = createPill(attrs, now)
        let expected = DateFactory.createDate(on: expectedDay, at: testTime)!
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenFirstTwentyDaysAndNotYetFinishedOnNineteenthDay_returnsSameDayAtNextTime() {
        var attrs = PillAttributes()
        attrs.expirationInterval = PillExpirationInterval.FirstTwentyDays
        attrs.timesTakenToday = 0
        let now = MockNow()

        // 01/01
        let startDate = DateFactory.createDate(
            byAddingHours: 12, to: DateFactory.createDefaultDate()
        )!

        // 01/19
        let lastDay = DateFactory.createDate(byAddingHours: 24*18, to: startDate)!
        now.now = lastDay

        let testTime = DateFactory.createDate(byAddingHours: -24, to: now.now)!
        attrs.lastTaken = testTime
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        let pill = createPill(attrs, now)
        let expected = DateFactory.createDate(on: now.now, at: testTime)!
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenFirstTwentyDaysAndFinishedOnNineteenthDay_returnsNextDayAtTimeOne() {
        var attrs = PillAttributes()
        attrs.expirationInterval = PillExpirationInterval.FirstTwentyDays
        attrs.timesTakenToday = 1
        let now = MockNow()

        // 01/01
        let startDate = DateFactory.createDate(
            byAddingHours: 12, to: DateFactory.createDefaultDate()
        )!

        // 01/19
        let lastDay = DateFactory.createDate(byAddingHours: 24*18, to: startDate)!
        now.now = lastDay

        let testTime = DateFactory.createDate(byAddingMinutes: -5, to: now.now)!
        attrs.lastTaken = testTime
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])
        let pill = createPill(attrs, now)
        let date = DateFactory.createDate(byAddingHours: 24, to: now.now)!
        let expected = DateFactory.createDate(on: date, at: testTime)!
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenLastTenDaysAndFinishedOnLastDayOfMonth_returnsExpectedDate() {
        var attrs = PillAttributes()
        attrs.expirationInterval = PillExpirationInterval.LastTenDays
        attrs.timesTakenToday = 1
        let now = MockNow()

        // 01/01
        let startDate = DateFactory.createDate(
            byAddingHours: 12, to: DateFactory.createDefaultDate()
        )!

        // 01/31
        attrs.lastTaken = DateFactory.createDate(byAddingHours: 24*30, to: startDate)!

        // 02/01
        now.now = attrs.lastTaken!

        // 02/09
        let expectedDay = DateFactory.createDate(byAddingHours: 24*49, to: startDate)!

        let testTime = DateFactory.createDate(byAddingMinutes: 5, to: now.now)!
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])

        let pill = createPill(attrs, now)
        let expected = DateFactory.createDate(on: expectedDay, at: testTime)!
        let actual = pill.due!

        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenLastTenDaysAndIsFirstOfMonth_returnsExpectedDate() {
        var attrs = PillAttributes()
        attrs.expirationInterval = PillExpirationInterval.LastTenDays
        attrs.timesTakenToday = 0
        let now = MockNow()

        // 01/01
        let startDate = DateFactory.createDate(
            byAddingHours: 12, to: DateFactory.createDefaultDate()
        )!

        // 01/31
        attrs.lastTaken = DateFactory.createDate(byAddingHours: 24*30, to: startDate)!

        // 02/01
        now.now = DateFactory.createDate(byAddingHours: 24*31, to: startDate)!

        // 02/09
        let expectedDay = DateFactory.createDate(byAddingHours: 24*49, to: startDate)!

        let testTime = DateFactory.createDate(byAddingMinutes: 5, to: now.now)!
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])

        let pill = createPill(attrs, now)
        let expected = DateFactory.createDate(on: expectedDay, at: testTime)!
        let actual = pill.due!

        XCTAssertEqual(expected, actual)
    }

    func testDue_whenLastTakenTwentyDaysAndFinishedOnLastDayOfMonth_returnsExpectedDate() {
        var attrs = PillAttributes()
        attrs.expirationInterval = PillExpirationInterval.LastTwentyDays
        attrs.timesTakenToday = 0
        let now = MockNow()

        // 01/01
        let startDate = DateFactory.createDate(
            byAddingHours: 12, to: DateFactory.createDefaultDate()
        )!

        // 01/31
        attrs.lastTaken = DateFactory.createDate(byAddingHours: 24*30, to: startDate)!

        // 02/01
        now.now = attrs.lastTaken!

        // 02/09
        let expectedDay = DateFactory.createDate(byAddingHours: 24*39, to: startDate)!

        let testTime = DateFactory.createDate(byAddingMinutes: 5, to: now.now)!
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])

        let pill = createPill(attrs, now)
        let expected = DateFactory.createDate(on: expectedDay, at: testTime)!
        let actual = pill.due!

        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenLastTwentyDaysAndIsFirstOfMonth_returnsFirstOfLastTwentyDaysAtTimeOne() {
        var attrs = PillAttributes()
        attrs.expirationInterval = PillExpirationInterval.LastTwentyDays
        attrs.timesTakenToday = 0
        let now = MockNow()

        // 01/01
        let startDate = DateFactory.createDate(
            byAddingHours: 12, to: DateFactory.createDefaultDate()
        )!

        // 01/31
        attrs.lastTaken = DateFactory.createDate(byAddingHours: 24*30, to: startDate)!

        // 02/01
        now.now = DateFactory.createDate(byAddingHours: 24*31, to: startDate)!

        // 02/09
        let expectedDay = DateFactory.createDate(byAddingHours: 24*39, to: startDate)!

        let testTime = DateFactory.createDate(byAddingMinutes: 5, to: now.now)!
        attrs.times = PDDateFormatter.convertDatesToCommaSeparatedString([testTime])

        let pill = createPill(attrs, now)
        let expected = DateFactory.createDate(on: expectedDay, at: testTime)!
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
        let newExpiration = PillExpirationInterval.FirstTenDays
        let pill = createPill(PillAttributes())
        var newAttrs = PillAttributes()
        let timesTakenToday = 5
        newAttrs.name = newName
        newAttrs.times = timesString
        newAttrs.notify = true
        newAttrs.lastTaken = newLastTaken
        newAttrs.expirationInterval = newExpiration
        newAttrs.timesTakenToday = timesTakenToday
        pill.set(attributes: newAttrs)
        XCTAssertEqual(newName, pill.name)
        XCTAssert(PDTest.sameTime(newTime1, pill.times[0]))
        XCTAssert(PDTest.sameTime(newTime2, pill.times[1]))
        XCTAssert(pill.notify)
        XCTAssertEqual(newLastTaken, pill.lastTaken)
        XCTAssertEqual(newExpiration, pill.expirationInterval)
        XCTAssertEqual(timesTakenToday, pill.timesTakenToday)
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
