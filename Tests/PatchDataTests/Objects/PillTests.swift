//
//  PillTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 1/16/20.

import Foundation

import XCTest
import PDKit
import PDTest

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
        let attrs = PillAttributes()
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
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString(times)
        return attrs
    }

    func testAttributes_returnsExpectedName() {
        let attrs = PillAttributes()
        attrs.name = "TestName"
        let pill = createPill(attrs)
        XCTAssertEqual("TestName", pill.attributes.name)
    }

    func testAttributes_returnsExpectedInterval() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = PillExpirationIntervalSetting.FirstXDays
        let pill = createPill(attrs)
        let actual = pill.attributes.expirationInterval.value
        XCTAssertEqual(PillExpirationIntervalSetting.FirstXDays, actual)
    }

    func testAttributes_returnsExpectedTimes() {
        let attrs = PillAttributes()
        attrs.times = "12:00:00,06:40:00"
        let pill = createPill(attrs)
        let actual = pill.attributes.times
        XCTAssertEqual("12:00:00,06:40:00", actual)
    }

    func testExpirationInterval_whenNothingSet_returnsDefault() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = nil
        let pill = createPill(attrs)
        let actual = pill.expirationIntervalSetting
        let expected = DefaultPillAttributes.EXPIRATION_INTERVAL
        XCTAssertEqual(expected, actual)
    }

    func testExpirationInterval_whenEveryDay_returnsExpectedInterval() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .EveryDay
        let pill = createPill(attrs)
        let actual = pill.expirationInterval
        let expected = PillExpirationIntervalSetting.EveryDay
        XCTAssertEqual(expected, actual.value)
    }

    func testExpirationInterval_whenEveryOtherDay_returnsExpectedInterval() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .EveryOtherDay
        let pill = createPill(attrs)
        let actual = pill.expirationInterval
        XCTAssertEqual(.EveryOtherDay, actual.value)
    }

    func testExpirationInterval_whenFirstTen_returnsExpectedInterval() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .FirstXDays
        attrs.expirationInterval.daysOne = 10
        let pill = createPill(attrs)
        let actual = pill.expirationInterval
        XCTAssertEqual(.FirstXDays, actual.value)
    }

    func testExpirationInterval_whenLastTen_returnsExpectedInterval() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .LastXDays
        attrs.expirationInterval.daysOne = 10
        let pill = createPill(attrs)
        let actual = pill.expirationInterval
        XCTAssertEqual(.LastXDays, actual.value)
    }

    func testExpirationInterval_whenFirstTwenty_returnsExpectedInterval() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .FirstXDays
        attrs.expirationInterval.daysOne = 20
        let pill = createPill(attrs)
        let actual = pill.expirationInterval
        XCTAssertEqual(.FirstXDays, actual.value)
    }

    func testExpirationInterval_whenLastTwenty_returnsExpectedString() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .LastXDays
        attrs.expirationInterval.daysOne = 20
        let pill = createPill(attrs)
        let actual = pill.expirationInterval
        XCTAssertEqual(.LastXDays, actual.value)
    }

    func testTimes_whenNilInAttributes_returnsNil() {
        let attrs = PillAttributes()
        attrs.times = nil
        let pill = createPill(attrs)
        PDAssertEmpty(pill.times)
    }

    func testTimes_returnsTimeFromAttributes() {
        let attrs = PillAttributes()
        attrs.times = PillTestsUtil.testTimeString
        let pill = createPill(attrs)
        let actual = pill.times[0]
        let expected = PillTestsUtil.testTime
        PDAssertSingle(pill.times)
        PDAssertSameTime(expected, actual)
    }

    func testTimes_whenStoredOutOfOrder_reorders() {
        let attrs = PillAttributes()
        let secondTimeString = PillTestsUtil.createTimeString(
            hour: PillTestsUtil.testHour + 1, minute: 0, second: 0
        )
        attrs.times = "\(secondTimeString),\(PillTestsUtil.testTimeString)"
        let pill = createPill(attrs)
        let actualTimes = pill.times
        XCTAssertEqual(2, actualTimes.count)
        PDAssertSameTime(PillTestsUtil.testTime, actualTimes[0])
        guard let expectedNewTime = Calendar.current.date(
            bySettingHour: PillTestsUtil.testHour + 1, minute: 0, second: 0, of: Date()
        ) else {
            XCTFail("Was unable to create the expected new time")
            return
        }
        PDAssertSameTime(expectedNewTime, actualTimes[1])
    }

    func testAppendTime_whenGivenDefaultValue_doesNotSet() {
        let attrs = PillAttributes()
        let testTimesString = "\(PillTestsUtil.testTimeString)"
        attrs.times = testTimesString
        let pill = createPill(attrs)
        pill.appendTime(DateFactory.createDefaultDate())
        // Only has original time
        PDAssertSingle(pill.times)
        PDAssertSameTime(PillTestsUtil.testTime, pill.times[0])
    }

    func testAppendTime_whenTimeSecondAndLessThanFirstTime_maintainsOrder() {
        let attrs = PillAttributes()
        let secondTimeString = PillTestsUtil.createTimeString(
            hour: PillTestsUtil.testHour, minute: PillTestsUtil.testSeconds - 1, second: 0
        )
        let secondTime = DateFactory.createTimesFromCommaSeparatedString(secondTimeString)[0]
        attrs.times = "\(PillTestsUtil.testTimeString)"
        let pill = createPill(attrs)
        pill.appendTime(secondTime)
        let actualTimes = pill.times
        XCTAssertEqual(2, pill.times.count)
        PDAssertSameTime(secondTime, actualTimes[0])
        PDAssertSameTime(PillTestsUtil.testTime, actualTimes[1])
    }

    func testNotify_whenNilInAttributes_returnsDefaultNotify() {
        let attrs = PillAttributes()
        attrs.notify = nil
        let pill = createPill(attrs)
        XCTAssertEqual(DefaultPillAttributes.NOTIFY, pill.notify)
    }

    func testTimesaday_returnsCountOfTimes() {
        let attrs = PillAttributes()
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
        let attrs = PillAttributes()
        attrs.timesTakenToday = nil
        let pill = createPill(attrs)
        let expected = 0
        let actual = pill.timesTakenToday
        XCTAssertEqual(expected, actual)
    }

    func testTimesTakenToday_whenNotNilInAttributes_returnsCountFromTimesFromAttributes() {
        let attrs = PillAttributes()
        attrs.timesTakenToday = "12:00:00,12:00:01,12:00:02"
        let pill = createPill(attrs)
        let expected = 3
        let actual = pill.timesTakenToday
        XCTAssertEqual(expected, actual)
    }

    func testLastTaken_returnsLastTakenFromAtttributes() {
        let attrs = PillAttributes()
        let testDate = Date()
        attrs.lastTaken = testDate
        let pill = createPill(attrs)
        let actual = pill.lastTaken
        XCTAssertEqual(testDate, actual)
    }

    func testLastTaken_isSettable() {
        let testDate = Date()
        let pill = createPill(PillAttributes())
        pill.lastTaken = testDate
        let actual = pill.lastTaken
        XCTAssertEqual(testDate, actual)
    }

    func testTimesTakenTodayList_returnsObjectWithExpectedDates() {
        let attrs = PillAttributes()
        let timeString = "12:00:10,13:45:30"
        attrs.timesTakenToday = timeString
        let pill = createPill(attrs)
        let actual = pill.timesTakenTodayList
        let expectedDates = DateFactory.createTimesFromCommaSeparatedString(timeString)
        XCTAssertEqual(2, actual.count)
        PDAssertEquiv(expectedDates[0], actual[0])
        PDAssertEquiv(expectedDates[1], actual[1])
    }

    func testXDays_whenHasSupportedExpirationInterval_returnsDaysOnDaysOffFromAtttributes() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .XDaysOnXDaysOff
        attrs.expirationInterval.daysOne = 12
        attrs.expirationInterval.daysTwo = 12
        let pill = createPill(attrs)
        let actual = pill.expirationInterval.xDaysValue
        XCTAssertEqual("12-12", actual)
    }

    func testXDays_whenHasUnsupportedExpirationInterval_returnsNil() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .EveryOtherDay
        attrs.expirationInterval.daysOne = 12
        let pill = createPill(attrs)
        XCTAssertNil(pill.expirationInterval.xDaysValue)
    }

    func testDue_whenEveryDayAndNotYetTaken_returnsTodayAtTimeOne() {
        let attrs = PillAttributes()
        let now = Date()
        let testTime = DateFactory.createDate(byAddingSeconds: 61, to: now)!
        attrs.expirationInterval.value = .EveryDay
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        attrs.lastTaken = DateFactory.createDate(byAddingHours: -23, to: now)!
        attrs.notify = true
        attrs.timesTakenToday = ""
        let pill = createPill(attrs)
        let expected = createDueTime(testTime, days: 0, now: now)
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenEveryDayAndNotYetTakenAndIsPastTime_returnsTodayAtTimeOne() {
        let attrs = PillAttributes()
        let now = Date()
        let testTime = DateFactory.createDate(byAddingSeconds: -61, to: now)!
        attrs.expirationInterval.value = .EveryDay
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        attrs.lastTaken = DateFactory.createDate(byAddingHours: -23, to: now)!
        attrs.notify = true
        attrs.timesTakenToday = ""
        let pill = createPill(attrs)
        let expected = createDueTime(testTime, days: 0, now: now)
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenOnceEveryDayAndTakenOnceToday_returnsTomorrowAtTimeOne() {
        let attrs = PillAttributes()
        let now = MockNow()
        now.now = DateFactory.createDate(byAddingMonths: 2, to: DateFactory.createDefaultDate())!
        let testTime = DateFactory.createDate(byAddingMinutes: -5, to: now.now)!
        attrs.lastTaken = DateFactory.createDate(byAddingSeconds: -1, to: now.now)
        attrs.expirationInterval.value = .EveryDay
        attrs.timesTakenToday = "12:00:00"
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attrs, now)
        let expected = createDueTime(testTime, days: 1, now: now.now) // Tomorrow at time one
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTwiceEveryDayAndTakenOnceToday_returnsTodayAtTimeTwo() {
        let attrs = PillAttributes()
        let now = MockNow()
        now.now = DateFactory.createDate(byAddingMonths: 2, to: DateFactory.createDefaultDate())!
        let testTime = DateFactory.createDate(byAddingMinutes: -5, to: now.now)!
        let testTimeTwo = DateFactory.createDate(byAddingSeconds: 1, to: testTime)
        attrs.lastTaken = DateFactory.createDate(byAddingSeconds: -1, to: now.now)
        attrs.expirationInterval.value = .EveryDay
        attrs.timesTakenToday = "12:00:00"
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime, testTimeTwo])
        let pill = createPill(attrs, now)
        let expected = createDueTime(testTimeTwo!, days: 0, now: now.now) // Today at time two
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTwiceEveryDayAndTakenTwiceToday_returnsTomorrowATimeOne() {
        let attrs = PillAttributes()
        let now = MockNow()
        now.now = DateFactory.createDate(byAddingMonths: 2, to: DateFactory.createDefaultDate())!
        let testTime = DateFactory.createDate(byAddingMinutes: -5, to: now.now)!
        let testTimeTwo = DateFactory.createDate(byAddingSeconds: 1, to: testTime)
        attrs.lastTaken = DateFactory.createDate(byAddingSeconds: -1, to: now.now)
        attrs.expirationInterval.value = .EveryDay
        attrs.timesTakenToday = "12:00:00,01:10:10"
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime, testTimeTwo])
        let pill = createPill(attrs, now)
        let expected = createDueTime(testTime, days: 1, now: now.now) // Tomorrow at time one
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenThriceEveryDayAndTakenTwiceToday_returnsTodayATimeThree() {
        let attrs = PillAttributes()
        let now = MockNow()
        now.now = DateFactory.createDate(byAddingMonths: 2, to: DateFactory.createDefaultDate())!
        attrs.lastTaken = DateFactory.createDate(byAddingSeconds: -1, to: now.now)
        let testTime = DateFactory.createDate(byAddingMinutes: -5, to: now.now)!
        let testTimeTwo = DateFactory.createDate(byAddingSeconds: 1, to: testTime)!
        let testTimeThree = DateFactory.createDate(byAddingSeconds: 100, to: testTime)!
        let times = [testTime, testTimeTwo, testTimeThree]
        attrs.lastTaken = DateFactory.createDate(byAddingSeconds: -1, to: now.now)
        attrs.expirationInterval.value = .EveryDay
        attrs.timesTakenToday = "12:00:00,01:10:10"
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString(times)
        let pill = createPill(attrs, now)
        let expected = createDueTime(testTimeThree, days: 0, now: now.now)  // Today at time three
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenFourTimesEveryDayAndTakenFourTimesToday_returnsTomorrowATimeOne() {
        let attrs = PillAttributes()
        let now = MockNow()
        now.now = DateFactory.createDate(byAddingMonths: 2, to: DateFactory.createDefaultDate())!
        let testTime = DateFactory.createDate(byAddingMinutes: -5, to: now.now)!
        let testTimeTwo = DateFactory.createDate(byAddingSeconds: 1, to: testTime)!
        let testTimeThree = DateFactory.createDate(byAddingSeconds: 100, to: testTime)!
        let testTimeFour = DateFactory.createDate(byAddingSeconds: 250, to: testTime)!
        let times = [testTime, testTimeTwo, testTimeThree, testTimeFour]
        attrs.lastTaken = DateFactory.createDate(byAddingSeconds: -1, to: now.now)
        attrs.expirationInterval.value = .EveryDay
        attrs.timesTakenToday = "12:00:00,01:10:10,02:20:20,03:30:30"
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString(times)
        let pill = createPill(attrs, now)
        let expected = createDueTime(testTime, days: 1, now: now.now) // Tomorrow at time one
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenEveryOtherDayAndTakenTwoDaysAgo_returnsTodayAtTimeOne() {
        let attrs = PillAttributes()
        let now = MockNow()
        now.now = DateFactory.createDate(byAddingMonths: 2, to: DateFactory.createDefaultDate())!
        let testTime = DateFactory.createDate(byAddingMinutes: 5, to: now.now)!
        let testTimeTwo = DateFactory.createDate(byAddingSeconds: 1, to: testTime)
        attrs.lastTaken = DateFactory.createDate(byAddingSeconds: -1, to: now.now)
        attrs.expirationInterval.value = .EveryOtherDay
        attrs.timesTakenToday = ""
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime, testTimeTwo])
        let pill = createPill(attrs, now)
        let expected = createDueTime(testTime, days: 0, now: now.now)
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenEveryOtherDayAndTakenOnceToday_returnsTwoDaysFromNowAtTimeOne() {
        let attrs = PillAttributes()
        let now = MockNow()
        now.now = DateFactory.createDate(byAddingMonths: 2, to: DateFactory.createDefaultDate())!
        let testTime = DateFactory.createDate(byAddingMinutes: 5, to: now.now)!
        attrs.lastTaken = DateFactory.createDate(daysFromNow: 0, now: now)
        attrs.expirationInterval.value = .EveryOtherDay
        attrs.timesTakenToday = "12:00:00"
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attrs, now)
        let expected = createDueTime(testTime, days: 2, now: now.now)
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTwiceEveryOtherDayAndTakenOnceToday_returnsTodayAtTimeTwo() {
        let attrs = PillAttributes()
        let now = MockNow()
        now.now = DateFactory.createDate(byAddingMonths: 2, to: DateFactory.createDefaultDate())!
        let testTime = DateFactory.createDate(byAddingMinutes: -5, to: now.now)!
        let testTimeTwo = DateFactory.createDate(byAddingSeconds: 1, to: testTime)!
        attrs.lastTaken = DateFactory.createDate(daysFromNow: 0, now: now)
        attrs.expirationInterval.value = .EveryOtherDay
        attrs.timesTakenToday = "12:00:00"
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime, testTimeTwo])
        let pill = createPill(attrs, now)
        let expected = createDueTime(testTimeTwo, days: 0, now: now.now) // Today at time two
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTwiceEveryOtherDayAndTakenTwiceToday_returnsTwoDaysFromNowAtTimeOne() {
        let attrs = PillAttributes()
        let now = MockNow()
        now.now = DateFactory.createDate(byAddingMonths: 2, to: DateFactory.createDefaultDate())!
        let testTime = DateFactory.createDate(byAddingMinutes: 5, to: now.now)!
        let testTimeTwo = DateFactory.createDate(byAddingSeconds: 1, to: testTime)!
        attrs.lastTaken = DateFactory.createDate(daysFromNow: 0, now: now)
        attrs.expirationInterval.value = .EveryOtherDay
        attrs.timesTakenToday = "12:00:00,01:10:10"
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime, testTimeTwo])
        let pill = createPill(attrs, now)
        let expected = createDueTime(testTime, days: 2, now: now.now)
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenEveryOtherDayAndTakenYesterday_returnsTomorrowAtTimeOne() {
        let attrs = PillAttributes()
        let now = MockNow()
        now.now = DateFactory.createDate(byAddingMonths: 2, to: DateFactory.createDefaultDate())!
        now.isInYesterdayReturnValue = true
        let testTime = DateFactory.createDate(byAddingMinutes: -5, to: now.now)!
        attrs.lastTaken = DateFactory.createDate(daysFromNow: -1, now: now)
        attrs.expirationInterval.value = .EveryOtherDay
        attrs.timesTakenToday = ""
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attrs, now)
        let expected = createDueTime(testTime, days: 1, now: now.now)
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenFirstTenDaysAndFinishedOnTenthDay_returnsFirstOfNextMonthAtTimeOne() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .FirstXDays
        attrs.expirationInterval.daysOne = 10
        attrs.timesTakenToday = "12:00:00"
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
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attrs, now)
        let expected = DateFactory.createDate(on: expectedDay, at: testTime)!
        let actual = pill.due!
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenFirstTwelveDaysAndFinishedOnTwelvthDay_returnsFirstOfNextMonthAtTimeOne() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .FirstXDays
        attrs.expirationInterval.daysOne = 12
        attrs.timesTakenToday = "12:00:00"
        let now = MockNow()

        // 01/01
        let startDate = DateFactory.createDate(
            byAddingHours: 12, to: DateFactory.createDefaultDate()
        )!

        // 01/10
        let lastTaken = DateFactory.createDate(byAddingHours: 24*11, to: startDate)!

        // 01/10
        now.now = lastTaken

        // 02/01
        let expectedDay = DateFactory.createDate(byAddingHours: 24*31, to: startDate)!

        let testTime = DateFactory.createDate(byAddingHours: -1, to: now.now)!
        attrs.lastTaken = lastTaken
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attrs, now)
        let expected = DateFactory.createDate(on: expectedDay, at: testTime)!
        let actual = pill.due!
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenEveryFirstTenDaysAndIsDuringThoseTenDays_returnsExpectedDate() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .FirstXDays
        attrs.expirationInterval.daysOne = 10
        attrs.timesTakenToday = "12:00:00"
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
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attrs, now)
        let expected = DateFactory.createDate(on: expectedDay, at: testTime)!
        let actual = pill.due!
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenEveryFirstTwelveDaysAndIsDuringThoseTwelveDays_returnsExpectedDate() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .FirstXDays
        attrs.expirationInterval.daysOne = 12
        attrs.timesTakenToday = "12:00:00"
        let now = MockNow()

        // 01/01
        let startDate = DateFactory.createDate(
            byAddingHours: 12, to: DateFactory.createDefaultDate()
        )!

        // 01/08
        let lastTaken = DateFactory.createDate(byAddingHours: 24*9, to: startDate)!

        // 01/09
        now.now = DateFactory.createDate(byAddingHours: 24*10, to: startDate)!

        // 01/10
        let expectedDay = DateFactory.createDate(byAddingHours: 24*11, to: startDate)!

        let testTime = DateFactory.createDate(byAddingHours: -1, to: now.now)!
        attrs.lastTaken = lastTaken
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attrs, now)
        let expected = DateFactory.createDate(on: expectedDay, at: testTime)!
        let actual = pill.due!
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenFirstTenDaysAndFinishedOnTwentiethDay_returnsFirstOfNextMonthAtTimeOne() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .FirstXDays
        attrs.expirationInterval.daysOne = 10
        attrs.timesTakenToday = ""
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
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attrs, now)
        let expected = DateFactory.createDate(on: expectedDay, at: testTime)!
        let actual = pill.due!
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenFirstTwentyDaysAndFinishedOnTwentiethDay_returnsFirstOfNextMonthAtTimeOne() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .FirstXDays
        attrs.expirationInterval.daysTwo = 20
        attrs.timesTakenToday = "12:00:00"
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
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attrs, now)
        let expected = DateFactory.createDate(on: expectedDay, at: testTime)!
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenFirstTwentyDaysAndNotYetFinishedOnNineteenthDay_returnsSameDayAtNextTime() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .FirstXDays
        attrs.expirationInterval.daysOne = 20
        attrs.timesTakenToday = ""
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
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attrs, now)
        let expected = DateFactory.createDate(on: now.now, at: testTime)!
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenFirstTwentyDaysAndFinishedOnNineteenthDay_returnsNextDayAtTimeOne() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .FirstXDays
        attrs.expirationInterval.daysOne = 20
        attrs.timesTakenToday = "12:00:00"
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
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attrs, now)
        let date = DateFactory.createDate(byAddingHours: 24, to: now.now)!
        let expected = DateFactory.createDate(on: date, at: testTime)!
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenLastTenDaysAndFinishedOnLastDayOfMonth_returnsExpectedDate() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .LastXDays
        attrs.expirationInterval.daysOne = 10
        attrs.timesTakenToday = "12:00:00"
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
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])

        let pill = createPill(attrs, now)
        let expected = DateFactory.createDate(on: expectedDay, at: testTime)!
        let actual = pill.due!

        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenLastTenDaysAndIsFirstOfMonth_returnsExpectedDate() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .LastXDays
        attrs.expirationInterval.daysOne = 10
        attrs.timesTakenToday = ""
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
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])

        let pill = createPill(attrs, now)
        let expected = DateFactory.createDate(on: expectedDay, at: testTime)!
        let actual = pill.due!

        XCTAssertEqual(expected, actual)
    }

    func testDue_whenLastTakenTwentyDaysAndFinishedOnLastDayOfMonth_returnsExpectedDate() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .LastXDays
        attrs.expirationInterval.daysTwo = 20
        attrs.timesTakenToday = ""
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
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])

        let pill = createPill(attrs, now)
        let expected = DateFactory.createDate(on: expectedDay, at: testTime)!
        let actual = pill.due!

        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenLastTwentyDaysAndIsFirstOfMonth_returnsFirstOfLastTwentyDaysAtTimeOne() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .LastXDays
        attrs.expirationInterval.daysOne = 20
        attrs.timesTakenToday = ""
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
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])

        let pill = createPill(attrs, now)
        let expected = DateFactory.createDate(on: expectedDay, at: testTime)!
        let actual = pill.due!

        XCTAssertEqual(expected, actual)
    }

    func testDue_whenXDaysOnXDaysOffAndHasNotStarted_returnsNil() {
        let attrs = PillAttributes()
        attrs.lastTaken = Date()
        attrs.expirationInterval.value = .XDaysOnXDaysOff
        let pill = createPill(attrs)
        XCTAssertNil(pill.due)
    }

    func testDue_whenXDaysOnXDaysOffAndHasJustStarted_returnsTodayAtTimeOne() {
        let now = MockNow()
        let testTime = DateFactory.createDate(byAddingMinutes: 5, to: now.now)!
        let attrs = PillAttributes()
        attrs.lastTaken = Date()
        attrs.expirationInterval.value = .XDaysOnXDaysOff
        attrs.expirationInterval.daysOne = 12
        attrs.expirationInterval.daysTwo = 4
        attrs.expirationInterval.startPositioning()
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attrs, now)

        let expected = DateFactory.createDate(on: Date(), at: testTime)!
        let actual = pill.due!
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenXDaysOnXDaysOffAndHasTakenOnceOutOfTwiceOnStartDay_returnsTodayAtTimeTwo() {
        let now = MockNow()
        let testTimeOne = DateFactory.createDate(byAddingMinutes: 5, to: now.now)!
        let testTimeTwo = DateFactory.createDate(byAddingMinutes: 20, to: now.now)!
        let attrs = PillAttributes()
        attrs.lastTaken = Date()
        attrs.expirationInterval.value = .XDaysOnXDaysOff
        attrs.expirationInterval.daysOne = 12
        attrs.expirationInterval.daysTwo = 4
        attrs.timesTakenToday = "12:00:00"
        attrs.expirationInterval.startPositioning()
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTimeOne, testTimeTwo])
        let pill = createPill(attrs, now)

        let expected = DateFactory.createDate(on: Date(), at: testTimeTwo)!
        let actual = pill.due!
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenXDaysOnXDaysOffAndHasTakenTwiceOutOfTwiceOnStartDay_returnsTomorrowAtTimeTwo() {
        let now = MockNow()
        let testTimeOne = DateFactory.createDate(byAddingMinutes: 5, to: now.now)!
        let testTimeTwo = DateFactory.createDate(byAddingMinutes: 20, to: now.now)!
        let attrs = PillAttributes()
        attrs.lastTaken = Date()
        attrs.expirationInterval.value = .XDaysOnXDaysOff
        attrs.expirationInterval.daysOne = 12
        attrs.expirationInterval.daysTwo = 4
        attrs.timesTakenToday = "12:00:00,01:10:10"
        attrs.expirationInterval.startPositioning()
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTimeOne, testTimeTwo])
        let pill = createPill(attrs, now)

        let expected = createDueTime(testTimeOne, days: 1, now: now.now) // Tomorrow at time one
        let actual = pill.due!
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenXDaysOnXDaysOffAndIsOnLastOnDayAndTakenOnce_returnsLastDateAtTimeTwo() {
        let now = MockNow()
        let attrs = PillAttributes()

        // 01/01
        let startDate = DateFactory.createDate(
            byAddingHours: 12, to: DateFactory.createDefaultDate()
        )!

        // 02/01
        now.now = DateFactory.createDate(byAddingHours: 24*31, to: startDate)!
        let dateLastTaken = DateFactory.createDate(byAddingHours: -1, to: now.now)
        attrs.lastTaken = dateLastTaken

        // 01/31
        attrs.lastTaken = DateFactory.createDate(byAddingHours: 24*30, to: startDate)!

        let testTimeOne = DateFactory.createDate(byAddingMinutes: 5, to: now.now)!
        let testTimeTwo = DateFactory.createDate(byAddingMinutes: 20, to: now.now)!

        attrs.expirationInterval.value = .XDaysOnXDaysOff
        attrs.expirationInterval.daysOne = 12
        attrs.expirationInterval.daysTwo = 4
        attrs.expirationInterval.xDaysIsOn = true
        attrs.expirationInterval.xDaysPosition = 12
        attrs.timesTakenToday = "12:00:00"
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTimeOne, testTimeTwo])
        let pill = createPill(attrs, now)

        // Now date at time 2
        let expected = DateFactory.createDate(on: now.now, at: testTimeTwo)!

        if let actual = pill.due {
            XCTAssertEqual(expected, actual)
        } else {
            XCTFail("Pill has no due date.")
        }
    }

    func testDue_whenXDaysOnXDaysOffAndIsOnLastOnDayAndTakenTwice_returnsNextStartDateAtTimeOne() {
        let now = MockNow()
        let attrs = PillAttributes()
        let daysOff = 4

        // 01/01
        let startDate = DateFactory.createDate(
            byAddingHours: 12, to: DateFactory.createDefaultDate()
        )!

        // 02/01
        now.now = DateFactory.createDate(byAddingHours: 24*31, to: startDate)!
        let dateLastTaken = DateFactory.createDate(byAddingHours: -1, to: now.now)
        attrs.lastTaken = dateLastTaken

        // 02/06
        let hours = 24 * (daysOff + 1)  // 5 days
        let nextStartDate = DateFactory.createDate(byAddingHours: hours, to: now.now)!

        // 01/31
        attrs.lastTaken = DateFactory.createDate(byAddingHours: 24*30, to: startDate)!

        let testTimeOne = DateFactory.createDate(byAddingMinutes: 5, to: now.now)!
        let testTimeTwo = DateFactory.createDate(byAddingMinutes: 20, to: now.now)!

        attrs.expirationInterval.value = .XDaysOnXDaysOff
        attrs.expirationInterval.daysOne = 12
        attrs.expirationInterval.daysTwo = daysOff
        attrs.expirationInterval.xDaysIsOn = true
        attrs.expirationInterval.xDaysPosition = 12
        attrs.timesTakenToday = "12:00:00,01:10:10"
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTimeOne, testTimeTwo])
        let pill = createPill(attrs, now)

        // Now date at time 2
        let expected = DateFactory.createDate(on: nextStartDate, at: testTimeOne)!

        if let actual = pill.due {
            XCTAssertEqual(expected, actual)
        } else {
            XCTFail("Pill has no due date.")
        }
    }

    func testDue_whenXDaysOnXDaysOffAndIsOnFirstOffDay_returnsNextStartDateAtTimeOne() {
        let now = MockNow()
        let attrs = PillAttributes()
        let daysOff = 4

        // 01/01
        let startDate = DateFactory.createDate(
            byAddingHours: 12, to: DateFactory.createDefaultDate()
        )!

        // 02/01
        now.now = DateFactory.createDate(byAddingHours: 24*31, to: startDate)!
        let dateLastTaken = DateFactory.createDate(byAddingHours: -25, to: now.now)
        attrs.lastTaken = dateLastTaken

        // 02/05
        let hours = 24 * daysOff  // +4 days
        let nextStartDate = DateFactory.createDate(byAddingHours: hours, to: now.now)!

        // 01/31
        attrs.lastTaken = DateFactory.createDate(byAddingHours: 24*30, to: startDate)!

        let testTimeOne = DateFactory.createDate(byAddingMinutes: 5, to: now.now)!
        let testTimeTwo = DateFactory.createDate(byAddingMinutes: 20, to: now.now)!

        attrs.expirationInterval.value = .XDaysOnXDaysOff
        attrs.expirationInterval.daysOne = 12
        attrs.expirationInterval.daysTwo = daysOff
        attrs.expirationInterval.xDaysIsOn = false
        attrs.expirationInterval.xDaysPosition = 1
        attrs.timesTakenToday = ""
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTimeOne, testTimeTwo])
        let pill = createPill(attrs, now)

        // Now date at time 2
        let expected = DateFactory.createDate(on: nextStartDate, at: testTimeOne)!

        if let actual = pill.due {
            XCTAssertEqual(expected, actual)
        } else {
            XCTFail("Pill has no due date.")
        }
    }

    func testDue_whenXDaysOnXDaysOffAndIsOnLastOffDay_returnsTomorrowTimeOne() {
        let now = MockNow()
        let attrs = PillAttributes()
        let daysOff = 4

        // 01/01
        let startDate = DateFactory.createDate(
            byAddingHours: 12, to: DateFactory.createDefaultDate()
        )!

        // 02/01
        now.now = DateFactory.createDate(byAddingHours: 24*31, to: startDate)!

        // 02/02
        let hours = 24  // +1 days
        let nextStartDate = DateFactory.createDate(byAddingHours: hours, to: now.now)!

        attrs.lastTaken = Date()

        let testTimeOne = DateFactory.createDate(byAddingMinutes: 5, to: now.now)!
        let testTimeTwo = DateFactory.createDate(byAddingMinutes: 20, to: now.now)!

        attrs.expirationInterval.value = .XDaysOnXDaysOff
        attrs.expirationInterval.daysOne = 12
        attrs.expirationInterval.daysTwo = daysOff
        attrs.expirationInterval.xDaysIsOn = false
        attrs.expirationInterval.xDaysPosition = 4
        attrs.timesTakenToday = ""
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTimeOne, testTimeTwo])
        let pill = createPill(attrs, now)

        let expected = DateFactory.createDate(on: nextStartDate, at: testTimeOne)!

        if let actual = pill.due {
            XCTAssertEqual(expected, actual)
        } else {
            XCTFail("Pill has no due date.")
        }
    }

    func testDue_whenXDaysOnXDaysWith1DayOn1DayOffAndTakenOnceOfOnce_returnsTwoDaysFromNowAtTimeOne() {
        let now = MockNow()
        let attrs = PillAttributes()
        let daysOff = 1

        // 01/01
        let startDate = DateFactory.createDate(
            byAddingHours: 12, to: DateFactory.createDefaultDate()
        )!

        // 02/01 - was day on
        now.now = DateFactory.createDate(byAddingHours: 24*31, to: startDate)!
        let dateLastTaken = DateFactory.createDate(byAddingHours: -2, to: now.now)
        attrs.lastTaken = dateLastTaken

        // 02/03 - next day on
        let hours = 48  // +2 days
        let nextStartDate = DateFactory.createDate(byAddingHours: hours, to: now.now)!

        // 01/31
        attrs.lastTaken = DateFactory.createDate(byAddingHours: 24*30, to: startDate)!

        let testTimeOne = DateFactory.createDate(byAddingMinutes: 5, to: now.now)!

        attrs.expirationInterval.value = .XDaysOnXDaysOff
        attrs.expirationInterval.daysOne = 1
        attrs.expirationInterval.daysTwo = daysOff
        attrs.expirationInterval.xDaysIsOn = true
        attrs.expirationInterval.xDaysPosition = 1
        attrs.timesTakenToday = "12:00:00"
        attrs.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTimeOne])
        let pill = createPill(attrs, now)

        let expected = DateFactory.createDate(on: nextStartDate, at: testTimeOne)!

        if let actual = pill.due {
            XCTAssertEqual(expected, actual)
        } else {
            XCTFail("Pill has no due date.")
        }
    }

    func testIsDue_whenTimesTakenTodayEqualsTimesday_returnsFalse() {
        let attrs = createPillAttributes(minutesFromNow: -5)
        attrs.lastTaken = Date(timeIntervalSinceNow: -1000)
        attrs.timesTakenToday = "12:00:00,01:10:10"
        attrs.times = "12:00:00,12:00:10"
        let pill = createPill(attrs)
        XCTAssertFalse(pill.isDue)
    }

    func testIsDue_whenPillNotYetTakenAndTimeOneIsPast_returnsTrue() {
        let attrs = createPillAttributes(minutesFromNow: -5)
        let pastDate = Date(timeInterval: -5, since: Date())
        let pastDateString = PDDateFormatter.convertTimesToCommaSeparatedString([pastDate])
        attrs.lastTaken = Date(timeIntervalSinceNow: -1000)
        attrs.expirationInterval.value = .EveryDay
        attrs.timesTakenToday = ""
        attrs.times = pastDateString
        let pill = createPill(attrs)
        XCTAssertTrue(pill.isDue)
    }

    func testIsDue_whenPillTakenTodayAndTimesadayIsOne_returnsFalse() {
        let attrs = createPillAttributes(minutesFromNow: -5)
        attrs.timesTakenToday = "12:00:00"
        attrs.times = "12:00:00"
        let pill = createPill(attrs)
        XCTAssertFalse(pill.isDue)
    }

    func testIsDue_whenPillTakenOnceAndTimesadayIsTwoAndTimesTwoIsNotPast_returnsFalse() {
        let attrs = createPillAttributes(minutesFromNow: 5)
        let pastDate = Date(timeInterval: -5, since: Date())
        let notPastDate = Date(timeInterval: 5, since: Date())
        let timeString = PDDateFormatter.convertTimesToCommaSeparatedString([notPastDate, pastDate])
        attrs.timesTakenToday = "12:00:00"
        attrs.times = timeString
        let pill = createPill(attrs)
        XCTAssertFalse(pill.isDue)
    }

    func testIsDue_whenPillTakenOnceAndTimesadayIsTwoAndTimesTwoIsPast_returnsTrue() {
        let attrs = createPillAttributes(minutesFromNow: -5)
        let pastDateOne = Date(timeInterval: -50, since: Date())
        let pastDateTwo = Date(timeInterval: -5, since: Date())
        let timeString = PDDateFormatter.convertTimesToCommaSeparatedString(
            [pastDateOne, pastDateTwo]
        )
        attrs.expirationInterval.value = .EveryDay
        attrs.lastTaken = Date(timeIntervalSinceNow: -1000)
        attrs.timesTakenToday = "12:00:00"
        attrs.times = timeString
        let pill = createPill(attrs)
        XCTAssert(pill.isDue)
    }

    func testIsDue_whenPillTakenTwiceTodayAndTimesadayIsTwo_returnsFalse() {
        let attrs = createPillAttributes(minutesFromNow: -5)
        attrs.timesTakenToday = "12:00:00,01:10:10"
        attrs.times = "12:00:00,12:00:10"
        let pill = createPill(attrs)
        XCTAssertFalse(pill.isDue)
    }

    func testIsDue_whenNeverTakenByWayOfNil_returnsFalse() {
        let attrs = createPillAttributes(minutesFromNow: -5)
        attrs.lastTaken = nil
        attrs.times = "12:00:00"
        attrs.timesTakenToday = ""
        let pill = createPill(attrs)
        XCTAssertFalse(pill.isDue)
    }

    func testIsDue_whenNeverTakenByWayOfDefault_returnsFalse() {
        let attrs = createPillAttributes(minutesFromNow: -5)
        attrs.lastTaken = DateFactory.createDefaultDate()
        attrs.times = "12:00:00"
        attrs.timesTakenToday = ""
        let pill = createPill(attrs)
        XCTAssertFalse(pill.isDue)
    }

    func testIsNew_whenLastTakenIsNilAndNameIsDefault_returnsTrue() {
        let attrs = PillAttributes()
        attrs.lastTaken = nil
        attrs.name = PillStrings.NewPill
        let pill = createPill(attrs)
        XCTAssertTrue(pill.isNew)
    }

    func testIsNew_whenLastTakenIsNilAndNameIsEmpty_returnsTrue() {
        let attrs = PillAttributes()
        attrs.lastTaken = nil
        attrs.name = ""
        let pill = createPill(attrs)
        XCTAssertTrue(pill.isNew)
    }

    func testIsNew_whenLastTakenIsNilAndIsCreatedTrue_returnsFalse() {
        let attrs = PillAttributes()
        attrs.lastTaken = nil
        attrs.isCreated = true
        let pill = createPill(attrs)
        XCTAssertFalse(pill.isNew)
    }

    func testIsNew_whenLastTakenHasValue_returnsFalse() {
        let attrs = PillAttributes()
        attrs.lastTaken = Date()
        let pill = createPill(attrs)
        XCTAssertFalse(pill.isNew)
    }

    func testIsDone_whenTimesTakenIsLessThanTimesaday_returnsFalse() {
        let attrs = PillAttributes()
        attrs.times = "12:00:00,12:00:10"
        attrs.timesTakenToday = "12:00:00"
        attrs.lastTaken = Date()
        let pill = createPill(attrs)
        XCTAssertFalse(pill.isDone)
    }

    func testIsDone_whenTimesTakenIsEqualToTimesaday_returnsTrue() {
        let attrs = PillAttributes()
        attrs.times = "12:00:00,12:00:10"
        attrs.timesTakenToday = "12:00:00,01:10:10"
        attrs.lastTaken = Date()
        let pill = createPill(attrs)
        XCTAssertTrue(pill.isDone)
    }

    func testIsDone_whenTimesTakenIsGreaterThanTimesaday_returnsTrue() {
        let attrs = PillAttributes()
        attrs.times = "12:00:00,12:00:10"
        attrs.timesTakenToday = "12:00:00,12:00:05,12:00:06"
        attrs.lastTaken = Date()
        let pill = createPill(attrs)
        XCTAssertTrue(pill.isDone)
    }

    func testIsDone_whenLastTakenIsNil_returnsFalse() {
        let attrs = PillAttributes()
        attrs.times = "12:00:00,12:00:10"
        attrs.timesTakenToday = "12:00:00,12:00:05,12:00:06"
        attrs.lastTaken = nil
        let pill = createPill(attrs)
        XCTAssertFalse(pill.isDone)
    }

    func testIsDone_whenXDaysOnXDaysOffAndOnOffMode_returnsTrue() {
        let attrs = PillAttributes()
        attrs.times = "12:00:00,12:00:10"
        attrs.lastTaken = Date()
        attrs.timesTakenToday = ""
        attrs.expirationInterval.value = .XDaysOnXDaysOff
        attrs.expirationInterval.daysOne = 1
        attrs.expirationInterval.daysTwo = 1
        attrs.expirationInterval.xDaysIsOn = false
        attrs.expirationInterval.xDaysPosition = 1
        let pill = createPill(attrs)
        XCTAssertTrue(pill.isDone)
    }

    func testIsDone_whenXDaysOnXDaysOffAndOnOnModeAndStillHasTimesToTake_returnsFalse() {
        let attrs = PillAttributes()
        attrs.times = "12:00:00,12:00:10"
        attrs.timesTakenToday = ""
        attrs.lastTaken = Date()
        attrs.expirationInterval.value = .XDaysOnXDaysOff
        attrs.expirationInterval.daysOne = 1
        attrs.expirationInterval.daysTwo = 1
        attrs.expirationInterval.xDaysIsOn = true
        attrs.expirationInterval.xDaysPosition = 1
        let pill = createPill(attrs)
        XCTAssertFalse(pill.isDone)
    }

    func testSet_setsGivenAttributes() {
        let newName = "New Pill Name"
        let newTime1 = Date()
        let newTime2 = Date()
        let timesString = PDDateFormatter.convertTimesToCommaSeparatedString([newTime1, newTime2])
        let newLastTaken = Date()
        let newExpiration = PillExpirationIntervalSetting.FirstXDays
        let pill = createPill(PillAttributes())
        let newAttrs = PillAttributes()
        let timesTakenToday = "12:00:00"
        newAttrs.name = newName
        newAttrs.times = timesString
        newAttrs.notify = true
        newAttrs.lastTaken = newLastTaken
        newAttrs.expirationInterval.value = newExpiration
        newAttrs.timesTakenToday = timesTakenToday
        newAttrs.expirationInterval.daysOne = 5
        pill.set(attributes: newAttrs)
        XCTAssertEqual(newName, pill.name)
        PDAssertSameTime(newTime1, pill.times[0])
        PDAssertSameTime(newTime2, pill.times[1])
        XCTAssert(pill.notify)
        XCTAssertEqual(newLastTaken, pill.lastTaken)
        XCTAssertEqual(newExpiration, pill.expirationInterval.value)
        XCTAssertEqual(
            DateFactory.createTimesFromCommaSeparatedString(timesTakenToday)[0],
            pill.timesTakenTodayList[0]
        )
        XCTAssertEqual("5", pill.expirationInterval.xDaysValue)
    }

    func testSet_whenGivenNil_doesNotSet() {
        let startAttrs = PillAttributes()
        let testName = "NAME"
        let testDate = Date()
        let testTimeString = "12:00:00"
        let testExpInterval = PillExpirationIntervalSetting.FirstXDays
        let testXDays = "4"
        startAttrs.name = testName
        startAttrs.lastTaken = testDate
        startAttrs.times = testTimeString
        startAttrs.notify = true
        startAttrs.timesTakenToday = "12:00:00,12:10:10"
        startAttrs.expirationInterval.value = testExpInterval
        startAttrs.expirationInterval.daysOne = 4
        let pill = createPill(startAttrs)
        let newAttrs = PillAttributes()
        newAttrs.name = nil
        newAttrs.lastTaken = nil
        newAttrs.times = nil
        newAttrs.notify = nil
        newAttrs.timesTakenToday = nil
        pill.set(attributes: newAttrs)
        XCTAssertEqual(testName, pill.name)
        XCTAssertEqual(testDate, pill.lastTaken)
        XCTAssertEqual(
            testTimeString, PDDateFormatter.convertTimesToCommaSeparatedString(pill.times)
        )
        XCTAssert(pill.notify)
        XCTAssertEqual(2, pill.timesTakenToday)
        XCTAssertEqual(testExpInterval, pill.expirationIntervalSetting)
        XCTAssertEqual(testXDays, pill.expirationInterval.xDaysValue)
    }

    func testSet_whenPillHasZeroTimes_setsToDefault() {
        let attrs = PillAttributes()
        attrs.lastTaken = Date()  // Not setting times
        let pill = createPill(PillAttributes())
        XCTAssertEqual(0, pill.timesaday)  // Just to prove it inits to 0
        pill.set(attributes: attrs)
        let expected = DateFactory.createTimesFromCommaSeparatedString(DefaultPillAttributes.TIME)
        XCTAssertEqual(expected, pill.times)
    }

    func testSet_ifGivenPositionAndNeverTaken_setsLastTakenToArbitraryYesterdayDate() {
        let pillAttrs = PillAttributes()
        pillAttrs.times = "12:00:00"
        pillAttrs.expirationInterval.value = .XDaysOnXDaysOff
        pillAttrs.expirationInterval.daysOne = 5
        pillAttrs.expirationInterval.daysTwo = 4
        let pill = createPill(pillAttrs)

        XCTAssertNil(pill.lastTaken)  // Just to prove it starts out as nil

        let attrsToSet = PillAttributes()
        // Can only update these props all together; the UI will set these to the pill's prior
        // to calling
        attrsToSet.expirationInterval.value = .XDaysOnXDaysOff
        attrsToSet.expirationInterval.daysOne = 5
        attrsToSet.expirationInterval.daysTwo = 4

        // These are the actual ones being updates, since pill does not have them currently.
        attrsToSet.expirationInterval.xDaysPosition = 2
        attrsToSet.expirationInterval.xDaysIsOn = true
        pill.set(attributes: attrsToSet)

        let expected = DateFactory.createDate(byAddingHours: -24, to: Date())!
        if let actual = pill.lastTaken {
            PDAssertSameTime(expected, actual)
        } else {
            XCTFail("Pill did not initalize its lastTaken")
        }
    }

    func testSwallow_whenTimesTakenTodayEqualToTimesaday_doesNotIncreaseTimesTakenToday() {
        let attrs = PillAttributes()
        attrs.times = "12:00:00"
        attrs.timesTakenToday = "12:00:00"
        attrs.lastTaken = Date()
        let pill = createPill(attrs)
        pill.swallow()
        XCTAssertEqual(1, pill.timesTakenToday)
    }

    func testSwallow_whenTimesTakenTodayEqualToTimesaday_doesNotSetLastTaken() {
        let attrs = PillAttributes()
        let originalLastTaken = Date()
        attrs.lastTaken = originalLastTaken
        attrs.times = "12:00:00"
        attrs.timesTakenToday = "12:00:00"
        let pill = createPill(attrs)
        pill.swallow()
        XCTAssertEqual(originalLastTaken, pill.lastTaken)
    }

    func testSwallow_whenTimesTakenTodayIsLessThanTimesaday_increasesTimesTakenToday() {
        let attrs = PillAttributes()
        attrs.times = "12:00:00"
        attrs.timesTakenToday = ""
        attrs.lastTaken = Date()
        let pill = createPill(attrs)
        pill.swallow()
        XCTAssertEqual(1, pill.timesTakenToday)
    }

    func testSwallow_whenTimesTakenTodayIsLessThanTimesaday_stampsLastTaken() {
        let attrs = PillAttributes()
        let originalLastTaken = Date()
        attrs.lastTaken = originalLastTaken
        attrs.times = "12:00:00"
        attrs.timesTakenToday = ""
        let pill = createPill(attrs)
        pill.swallow()
        XCTAssert(originalLastTaken < pill.lastTaken! && pill.lastTaken! < Date())
    }

    func testSwallow_whenLastTakenIsNil_increasesTimesTakenToday() {
        let attrs = PillAttributes()

        // initialize with timesTakenToday=1
        attrs.times = "12:00:00"
        attrs.timesTakenToday = ""
        attrs.lastTaken = nil

        let pill = createPill(attrs)
        pill.swallow()
        XCTAssertEqual(1, pill.timesTakenToday)
    }

    func testSwallow_whenLastTakenIsNil_stampsLastTaken() {
        let attrs = PillAttributes()
        attrs.lastTaken = nil
        attrs.times = "12:00:00"
        attrs.timesTakenToday = "12:00:00"
        let pill = createPill(attrs)
        pill.swallow()
        XCTAssert(Date().timeIntervalSince(pill.lastTaken!) < 0.1)
    }

    func testSwallow_whenLastTakenNilAndUsingXDaysOnXDaysOffAndPosHasNotStarted_startsPosAndIncrements() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .XDaysOnXDaysOff
        attrs.expirationInterval.daysOne = 5
        attrs.expirationInterval.daysTwo = 5
        attrs.expirationInterval.xDaysIsOn = nil
        attrs.expirationInterval.xDaysPosition = nil
        attrs.lastTaken = nil
        attrs.times = "12:00:00"
        attrs.timesTakenToday = ""
        let pill = createPill(attrs)
        pill.swallow()
        let interval = attrs.expirationInterval
        if interval.xDaysPosition == nil || interval.xDaysIsOn == nil {
            XCTFail("XDays positioning did not get initlaized.")
            return
        }

        // Expect 2 because only needs to be taken once today and just taken
        // It's like it starts at 2 since technically the values were assumed to be the
        // beginning even though they are nil.
        let expected = 2
        XCTAssertEqual(expected, attrs.expirationInterval.xDaysPosition!)
        XCTAssert(attrs.expirationInterval.xDaysIsOn!)
    }

    func testSwallow_whenLastTakenIsNilAndUsingXDaysOnXDaysOffAndPositioningHasStarted_doesNotResetXDaysPositioning() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .XDaysOnXDaysOff
        attrs.expirationInterval.daysOne = 5
        attrs.expirationInterval.daysTwo = 5
        attrs.expirationInterval.xDaysIsOn = true
        attrs.expirationInterval.xDaysPosition = 4
        attrs.lastTaken = nil
        attrs.times = "12:00:00,12:10:00"
        attrs.timesTakenToday = ""
        let pill = createPill(attrs)
        pill.swallow()
        let interval = attrs.expirationInterval
        if interval.xDaysPosition == nil || interval.xDaysIsOn == nil {
            XCTFail("XDays positioning did not get initlaized.")
            return
        }
        XCTAssertEqual(4, attrs.expirationInterval.xDaysPosition!)
        XCTAssertEqual(true, attrs.expirationInterval.xDaysIsOn)
    }

    func testSwallow_whenLastTakenIsNilAndNotUsingXDaysOnXDaysOff_doesNotStartXDaysPositioning() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .FirstXDays
        attrs.expirationInterval.daysOne = 5
        attrs.lastTaken = nil
        attrs.times = "12:00:00"
        attrs.timesTakenToday = ""
        let pill = createPill(attrs)
        pill.swallow()
        let interval = attrs.expirationInterval
        XCTAssertNil(interval.xDaysPosition)
        XCTAssertNil(interval.xDaysIsOn)
    }

    func testSwallow_wheHasLastTakenAndUsingXDaysOnXDaysOffAndNotStarted_setsExpectedPositioning() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .FirstXDays
        attrs.expirationInterval.value = .XDaysOnXDaysOff
        attrs.expirationInterval.daysOne = 5
        attrs.expirationInterval.daysTwo = 5
        attrs.lastTaken = Date()
        attrs.times = "12:00:00"
        attrs.timesTakenToday = ""
        let pill = createPill(attrs)
        pill.swallow()
        let interval = attrs.expirationInterval
        XCTAssertEqual(2, interval.xDaysPosition)
        XCTAssertEqual(true, interval.xDaysIsOn)
    }

    func testSwallow_whenXDaysOnXDaysOffAndDoneForTheDayAfterTaking_incrementsDaysPosition() {
        let attrs = PillAttributes()
        attrs.expirationInterval.value = .FirstXDays
        attrs.expirationInterval.value = .XDaysOnXDaysOff
        attrs.expirationInterval.daysOne = 5
        attrs.expirationInterval.daysTwo = 5
        attrs.expirationInterval.xDaysIsOn = false
        attrs.expirationInterval.xDaysPosition = 3
        attrs.lastTaken = Date()
        attrs.times = "12:00:00"
        attrs.timesTakenToday = ""
        let pill = createPill(attrs)
        pill.swallow()
        let interval = pill.attributes.expirationInterval
        XCTAssertEqual(4, interval.xDaysPosition)
        XCTAssertEqual(false, interval.xDaysIsOn)
    }

    func testUnswallow_whenTakenZeroTimesToday_doesNothing() {
        let attrs = PillAttributes()
        attrs.timesTakenToday = ""
        attrs.lastTaken = Date()
        let pill = createPill(attrs)
        pill.unswallow()
        XCTAssertEqual(0, pill.timesTakenToday)
    }

    func testUnswallow_whenNeverTaken_doesNothing() {
        let attrs = PillAttributes()
        attrs.timesTakenToday = "12:00:00"
        attrs.lastTaken = nil
        let pill = createPill(attrs)
        pill.unswallow()
        XCTAssertEqual(1, pill.timesTakenToday)
    }

    func testUnswallow_decrementsTimesTakenToday() {
        let attrs = PillAttributes()
        attrs.timesTakenToday = "12:00:00,01:10:10"
        attrs.lastTaken = Date()
        let pill = createPill(attrs)
        pill.unswallow()
        XCTAssertEqual(1, pill.timesTakenToday)
    }

    func testUnswallow_resetsLastTakenToPenultimateDate() {
        // This test verifies the last taken is popped off and the penultimate last taken
        // gets reset as the last taken during unswallow().
        let attrs = PillAttributes()
        let lastTaken = Date()
        let timeString = "12:00:00,\(PDDateFormatter.formatInternalTime(lastTaken))"
        attrs.timesTakenToday = timeString
        attrs.lastTaken = lastTaken
        let pill = createPill(attrs)

        pill.unswallow()

        guard let actual = pill.lastTaken else {
            XCTFail("pill.lastTaken should not be nil.")
            return
        }

        let expected = DateFactory.createTimesFromCommaSeparatedString(timeString)[0]
        PDAssertEquiv(expected, actual)
    }

    func testUnswallow_whenLastLastTakenNotToday_resetsToDateInToday() {
        let attrs = PillAttributes()
        let lastTaken = Date()
        attrs.timesTakenToday = "12:00:00,01:10:10"
        attrs.lastTaken = lastTaken
        let pill = createPill(attrs)
        pill.unswallow()

        if let actual = pill.lastTaken {
            XCTAssert(actual.isInToday())
        } else {
            XCTFail("pill.lastTaken should not be nil.")
        }
    }

    func testAwaken_whenLastTakenWasToday_doesNotClear() {
        let attrs = PillAttributes()
        let timeString = "12:00:00,01:10:10"
        attrs.timesTakenToday = timeString
        attrs.lastTaken = Date()
        let pill = createPill(attrs)
        pill.awaken()
        let expected = DateFactory.createTimesFromCommaSeparatedString(timeString)
        let expectedCount = 2
        XCTAssertEqual(expectedCount, pill.timesTakenToday)
        XCTAssertEqual(expectedCount, pill.timesTakenTodayList.count)
        XCTAssertEqual(expected[0], pill.timesTakenTodayList[0])
        XCTAssertEqual(expected[1], pill.timesTakenTodayList[1])
    }

    func testAwaken_whenHasNoLastTaken_clears() {
        let attrs = PillAttributes()
        attrs.lastTaken = nil
        let timeString = "12:00:00,01:10:10"
        attrs.timesTakenToday = timeString
        let pill = createPill(attrs)
        pill.awaken()
        XCTAssertEqual(0, pill.timesTakenToday)
        XCTAssertEqual(0, pill.timesTakenTodayList.count)
    }

    func testAwaken_whenTimesTakenTodayIsZero_clears() {
        let attrs = PillAttributes()
        let timeString = ""  // 0 times taken today
        attrs.timesTakenToday = timeString
        attrs.lastTaken = Date()
        let pill = createPill(attrs)
        pill.awaken()
        XCTAssertEqual(0, pill.timesTakenToday)
        XCTAssertEqual(0, pill.timesTakenTodayList.count)
    }

    func testAwaken_whenLastTakenWasYesterday_clears() {
        let attrs = PillAttributes()
        attrs.timesTakenToday = "12:00:00,01:10:10"
        attrs.lastTaken = Date(timeIntervalSinceNow: -86400)
        let pill = createPill(attrs)
        pill.awaken()
        XCTAssertEqual(0, pill.timesTakenToday)
    }

    func testAwaken_whenAlreadyAwokenToday_doesNotAwaken() {
        let attrs = PillAttributes()
        attrs.timesTakenToday = "12:00:00,01:10:10"
        attrs.lastTaken = Date(timeIntervalSinceNow: -86400)
        attrs.lastWakeUp = Date()
        let pill = createPill(attrs)
        pill.awaken()
        XCTAssertEqual(2, pill.timesTakenToday)
    }

    func testAwaken_whenNotYetWokeUpToday_setsWakeUpDate() {
        let attrs = PillAttributes()
        attrs.timesTakenToday = "12:00:00,01:10:10"
        attrs.lastTaken = Date(timeIntervalSinceNow: -86400)
        attrs.lastWakeUp = DateFactory.createDate(daysFromNow: -1)
        let pill = createPill(attrs)
        pill.awaken()
        XCTAssert(pill.attributes.lastWakeUp?.isInToday() ?? false)
    }

    func testAwaken_whenNotYetWokeUpTodayAndUsesXDaysAndIsInOffPosition_incrementsXDaysPosition() {
        let attrs = PillAttributes()
        attrs.timesTakenToday = "12:00:00,01:10:10"
        attrs.lastTaken = Date(timeIntervalSinceNow: -86400)
        attrs.lastWakeUp = DateFactory.createDate(daysFromNow: -1)
        attrs.expirationInterval.value = .XDaysOnXDaysOff
        attrs.expirationInterval.daysOne = 2
        attrs.expirationInterval.daysTwo = 2
        attrs.expirationInterval.xDaysPosition = 1
        attrs.expirationInterval.xDaysIsOn = false
        let pill = createPill(attrs)
        pill.awaken()
        XCTAssertEqual(2, pill.expirationInterval.xDaysPosition)
        XCTAssert(!pill.expirationInterval.xDaysIsOn!)
    }

    func testAwaken_whenNotYetWokeUpTodayAndUsesXDaysAndIsInLastOffPosition_incrementsXDaysPositionAndSetsIsOn() {
        let attrs = PillAttributes()
        attrs.timesTakenToday = "12:00:00,01:10:10"
        attrs.lastTaken = Date(timeIntervalSinceNow: -86400)
        attrs.lastWakeUp = DateFactory.createDate(daysFromNow: -1)
        attrs.expirationInterval.value = .XDaysOnXDaysOff
        attrs.expirationInterval.daysOne = 2
        attrs.expirationInterval.daysTwo = 2
        attrs.expirationInterval.xDaysPosition = 2
        attrs.expirationInterval.xDaysIsOn = false
        let pill = createPill(attrs)
        pill.awaken()
        XCTAssertEqual(1, pill.expirationInterval.xDaysPosition)
        XCTAssert(pill.expirationInterval.xDaysIsOn!)
    }

    func testAwaken_whenNotYetWokeUpTodayAndUsesXDaysAndIsInOnPosition_doesNotincrementsXDaysPosition() {
        let attrs = PillAttributes()
        attrs.timesTakenToday = "12:00:00,01:10:10"
        attrs.lastTaken = Date(timeIntervalSinceNow: -86400)
        attrs.lastWakeUp = DateFactory.createDate(daysFromNow: -1)
        attrs.expirationInterval.value = .XDaysOnXDaysOff
        attrs.expirationInterval.daysOne = 2
        attrs.expirationInterval.daysTwo = 2
        attrs.expirationInterval.xDaysPosition = 1
        attrs.expirationInterval.xDaysIsOn = true
        let pill = createPill(attrs)
        pill.awaken()
        XCTAssertEqual(1, pill.expirationInterval.xDaysPosition)
        XCTAssert(pill.expirationInterval.xDaysIsOn!)
    }
}
