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

    var januaryFirst: Date {
        getDateFromDefault(hours: 12)
    }

    var januaryTenth: Date {
        TestDateFactory.createTestDate(byAddingHours: 24 * 9, to: januaryFirst)
    }

    var januaryTwelfth: Date {
        TestDateFactory.createTestDate(byAddingHours: 24 * 11, to: januaryFirst)
    }

    var januaryTwentieth: Date {
        TestDateFactory.createTestDate(byAddingHours: 24 * 19, to: januaryFirst)
    }

    var januaryEighth: Date {
        TestDateFactory.createTestDate(byAddingHours: 24 * 7, to: januaryFirst)
    }

    var januaryNineth: Date {
        TestDateFactory.createTestDate(byAddingHours: 24 * 8, to: januaryFirst)
    }

    var januaryNineteenth: Date {
        TestDateFactory.createTestDate(byAddingHours: 24 * 18, to: januaryFirst)
    }

    var januaryThirtyFirst: Date {
        TestDateFactory.createTestDate(byAddingHours: 24 * 30, to: januaryFirst)
    }

    var februaryFirst: Date {
        TestDateFactory.createTestDate(byAddingHours: 24 * 31, to: januaryFirst)
    }

    var februarySecond: Date {
        TestDateFactory.createTestDate(byAddingHours: 24, to: februaryFirst)
    }

    var februaryThird: Date {
        TestDateFactory.createTestDate(byAddingHours: 24 * 2, to: februaryFirst)
    }

    var februaryFifth: Date {
        TestDateFactory.createTestDate(byAddingHours: 24 * 4, to: februaryFirst)
    }

    var februarySixth: Date {
        TestDateFactory.createTestDate(byAddingHours: 24 * 5, to: februaryFirst)
    }

    var februaryNineth: Date {
        TestDateFactory.createTestDate(byAddingHours: 24 * 8, to: februaryFirst)
    }

    var februaryNineteenth: Date {
        TestDateFactory.createTestDate(byAddingHours: 24 * 18, to: februaryFirst)
    }

    func testAttributes_returnsExpectedName() {
        let attributes = PillAttributes()
        attributes.name = "TestName"
        let pill = createPill(attributes)
        XCTAssertEqual("TestName", pill.attributes.name)
    }

    func testAttributes_returnsExpectedInterval() {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = PillExpirationIntervalSetting.FirstXDays
        let pill = createPill(attributes)
        let actual = pill.attributes.expirationInterval.value
        XCTAssertEqual(PillExpirationIntervalSetting.FirstXDays, actual)
    }

    func testAttributes_returnsExpectedTimes() {
        let attributes = PillAttributes()
        attributes.times = "12:00:00,06:40:00"
        let pill = createPill(attributes)
        let actual = pill.attributes.times
        XCTAssertEqual("12:00:00,06:40:00", actual)
    }

    func testExpirationInterval_whenNothingSet_returnsDefault() {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = nil
        let pill = createPill(attributes)
        let actual = pill.expirationIntervalSetting
        let expected = DefaultPillAttributes.EXPIRATION_INTERVAL
        XCTAssertEqual(expected, actual)
    }

    func testExpirationInterval_whenEveryDay_returnsExpectedInterval() {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = .EveryDay
        let pill = createPill(attributes)
        let actual = pill.expirationInterval
        let expected = PillExpirationIntervalSetting.EveryDay
        XCTAssertEqual(expected, actual.value)
    }

    func testExpirationInterval_whenEveryOtherDay_returnsExpectedInterval() {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = .EveryOtherDay
        let pill = createPill(attributes)
        let actual = pill.expirationInterval
        XCTAssertEqual(.EveryOtherDay, actual.value)
    }

    func testExpirationInterval_whenFirstTen_returnsExpectedInterval() {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = .FirstXDays
        attributes.expirationInterval.daysOne = 10
        let pill = createPill(attributes)
        let actual = pill.expirationInterval
        XCTAssertEqual(.FirstXDays, actual.value)
    }

    func testExpirationInterval_whenLastTen_returnsExpectedInterval() {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = .LastXDays
        attributes.expirationInterval.daysOne = 10
        let pill = createPill(attributes)
        let actual = pill.expirationInterval
        XCTAssertEqual(.LastXDays, actual.value)
    }

    func testExpirationInterval_whenFirstTwenty_returnsExpectedInterval() {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = .FirstXDays
        attributes.expirationInterval.daysOne = 20
        let pill = createPill(attributes)
        let actual = pill.expirationInterval
        XCTAssertEqual(.FirstXDays, actual.value)
    }

    func testExpirationInterval_whenLastTwenty_returnsExpectedString() {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = .LastXDays
        attributes.expirationInterval.daysOne = 20
        let pill = createPill(attributes)
        let actual = pill.expirationInterval
        XCTAssertEqual(.LastXDays, actual.value)
    }

    func testTimes_whenNilInAttributes_returnsNil() {
        let attributes = PillAttributes()
        attributes.times = nil
        let pill = createPill(attributes)
        PDAssertEmpty(pill.times)
    }

    func testTimes_returnsTimeFromAttributes() {
        let attributes = PillAttributes()
        attributes.times = PillTestsUtil.testTimeString
        let pill = createPill(attributes)
        let actual = pill.times[0]
        let expected = PillTestsUtil.testTime
        PDAssertSingle(pill.times)
        PDAssertSameTime(expected, actual)
    }

    func testTimes_whenStoredOutOfOrder_reorders() {
        let attributes = PillAttributes()
        let testHour = PillTestsUtil.testHour + 1
        let secondTimeString = PillTestsUtil.createTimeString(hour: testHour, minute: 0, second: 0)
        attributes.times = "\(secondTimeString),\(PillTestsUtil.testTimeString)"
        let pill = createPill(attributes)
        let actualTimes = pill.times
        let expectedTimeOne = PillTestsUtil.testTime
        let expectedTimeTwo = TestDateFactory.createTestDate(hour: testHour)
        XCTAssertEqual(2, actualTimes.count)
        PDAssertSameTime(expectedTimeOne, actualTimes[0])
        PDAssertSameTime(expectedTimeTwo, actualTimes[1])
    }

    func testAppendTime_whenGivenDefaultValue_doesNotSet() {
        let attributes = PillAttributes()
        let testTimesString = "\(PillTestsUtil.testTimeString)"
        attributes.times = testTimesString
        let pill = createPill(attributes)
        pill.appendTime(TestDateFactory.defaultDate)
        // Only has original time
        PDAssertSingle(pill.times)
        PDAssertSameTime(PillTestsUtil.testTime, pill.times[0])
    }

    func testAppendTime_whenTimeSecondAndLessThanFirstTime_maintainsOrder() {
        let attributes = PillAttributes()
        let secondTimeString = PillTestsUtil.createTimeString(
            hour: PillTestsUtil.testHour, minute: PillTestsUtil.testSeconds - 1, second: 0
        )
        let secondTime = DateFactory.createTimesFromCommaSeparatedString(secondTimeString)[0]
        attributes.times = "\(PillTestsUtil.testTimeString)"
        let pill = createPill(attributes)
        pill.appendTime(secondTime)
        let actualTimes = pill.times
        XCTAssertEqual(2, pill.times.count)
        PDAssertSameTime(secondTime, actualTimes[0])
        PDAssertSameTime(PillTestsUtil.testTime, actualTimes[1])
    }

    func testNotify_whenNilInAttributes_returnsDefaultNotify() {
        let attributes = PillAttributes()
        attributes.notify = nil
        let pill = createPill(attributes)
        XCTAssertEqual(DefaultPillAttributes.NOTIFY, pill.notify)
    }

    func testTimesaday_returnsCountOfTimes() {
        let attributes = PillAttributes()
        let t2 = PillTestsUtil.createTimeString(
            hour: PillTestsUtil.testHour, minute: PillTestsUtil.testSeconds - 1, second: 0
        )
        let t3 = PillTestsUtil.createTimeString(
            hour: PillTestsUtil.testHour - 8, minute: PillTestsUtil.testSeconds + 12, second: 0
        )
        attributes.times = "\(PillTestsUtil.testTimeString),\(t2),\(t3)"
        let pill = createPill(attributes)
        XCTAssertEqual(3, pill.timesaday)
    }

    public func testTimesTakenToday_whenNilInAttributes_returnsZero() {
        let attributes = PillAttributes()
        attributes.timesTakenToday = nil
        let pill = createPill(attributes)
        let expected = 0
        let actual = pill.timesTakenToday
        XCTAssertEqual(expected, actual)
    }

    func testTimesTakenToday_whenNotNilInAttributes_returnsCountFromTimesFromAttributes() {
        let attributes = PillAttributes()
        attributes.timesTakenToday = "12:00:00,12:00:01,12:00:02"
        let pill = createPill(attributes)
        let expected = 3
        let actual = pill.timesTakenToday
        XCTAssertEqual(expected, actual)
    }

    func testLastTaken_returnsLastTakenFromAtttributes() {
        let attributes = PillAttributes()
        let testDate = Date()
        attributes.lastTaken = testDate
        let pill = createPill(attributes)
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
        let attributes = PillAttributes()
        let timeString = "12:00:10,13:45:30"
        attributes.timesTakenToday = timeString
        let pill = createPill(attributes)
        let actual = pill.timesTakenTodayList
        let expectedDates = DateFactory.createTimesFromCommaSeparatedString(timeString)
        XCTAssertEqual(2, actual.count)
        PDAssertEquiv(expectedDates[0], actual[0])
        PDAssertEquiv(expectedDates[1], actual[1])
    }

    func testXDays_whenHasSupportedExpirationInterval_returnsDaysOnDaysOffFromAtttributes() {
        let attributes = createXDaysOnXDaysOffAttributes(daysOne: 12, daysTwo: 12)
        let pill = createPill(attributes)
        let actual = pill.expirationInterval.xDaysValue
        XCTAssertEqual("12-12", actual)
    }

    func testXDays_whenHasUnsupportedExpirationInterval_returnsNil() {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = .EveryOtherDay
        attributes.expirationInterval.daysOne = 12
        let pill = createPill(attributes)
        XCTAssertNil(pill.expirationInterval.xDaysValue)
    }

    func testDue_whenEveryDayAndNotYetTaken_returnsTodayAtTimeOne() {
        let attributes = PillAttributes()
        let now = MockNow()
        let testTime = TestDateFactory.createTestDate(byAddingSeconds: 61, to: now.now)
        attributes.expirationInterval.value = .EveryDay
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        attributes.lastTaken = TestDateFactory.createTestDate(byAddingHours: -23, to: now.now)
        attributes.notify = true
        attributes.timesTakenToday = ""
        let pill = createPill(attributes)
        assertDueTodayAtTimeOne(pill: pill, now: now)
    }

    func testDue_whenEveryDayAndNotYetTakenAndIsPastTime_returnsTodayAtTimeOne() {
        let attributes = PillAttributes()
        let now = MockNow()
        let testTime = TestDateFactory.createTestDate(byAddingSeconds: -61, to: now.now)
        attributes.expirationInterval.value = .EveryDay
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        attributes.lastTaken = TestDateFactory.createTestDate(byAddingHours: -23, to: now.now)
        attributes.notify = true
        attributes.timesTakenToday = ""
        let pill = createPill(attributes)
        assertDueTodayAtTimeOne(pill: pill, now: now)
    }

    func testDue_whenOnceEveryDayAndTakenOnceToday_returnsTomorrowAtTimeOne() {
        let attributes = PillAttributes()
        let now = MockNow()
        let mockNowDate = getDateFromDefault(months: 2)
        now.now = mockNowDate
        let testTime = getFiveMinutesAgo(now: now)
        attributes.lastTaken = getOneSecondAgo(now: now)
        attributes.expirationInterval.value = .EveryDay
        attributes.timesTakenToday = "12:00:00"
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attributes, now)
        let expected = createDueTime(testTime, days: 1, now: now) // Tomorrow at time one
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTwiceEveryDayAndTakenOnceToday_returnsTodayAtTimeTwo() {
        let attributes = PillAttributes()
        let now = MockNow()
        now.now = TestDateFactory.createTestDate(hour: 5)
        let testTime = getFiveMinutesAgo(now: now)
        let testTimeTwo = TestDateFactory.createTestDate(byAddingSeconds: 1, to: testTime)
        attributes.lastTaken = getOneSecondAgo(now: now)
        attributes.expirationInterval.value = .EveryDay
        attributes.timesTakenToday = "12:00:00"
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString(
            [testTime, testTimeTwo]
        )
        let pill = createPill(attributes, now)
        let expected = createDueTime(testTimeTwo, days: 0, now: now) // Today at time two
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTwiceEveryDayAndTakenTwiceToday_returnsTomorrowATimeOne() {
        let attributes = PillAttributes()
        let mockNowDate = getDateFromDefault(months: 2)
        let now = MockNow()
        now.now = mockNowDate
        let testTime = getFiveMinutesAgo(now: now)
        let testTimeTwo = TestDateFactory.createTestDate(byAddingSeconds: 1, to: testTime)
        let timesTaken = [testTime, testTimeTwo]
        attributes.lastTaken = getOneMinuteAgo(now: now)
        attributes.expirationInterval.value = .EveryDay
        attributes.timesTakenToday = "12:00:00,01:10:10"
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString(timesTaken)
        let pill = createPill(attributes, now)
        assertDueTomorrowAtTimeOne(pill: pill, now: now)
    }

    func testDue_whenThriceEveryDayAndTakenTwiceToday_returnsTodayATimeThree() {
        let attributes = PillAttributes()
        let now = MockNow()
        now.now = getDateFromDefault(months: 2)
        attributes.lastTaken = getOneSecondAgo(now: now)
        let testTime = getFiveMinutesAgo(now: now)
        let testTimeTwo = TestDateFactory.createTestDate(byAddingSeconds: 1, to: testTime)
        let testTimeThree = TestDateFactory.createTestDate(byAddingSeconds: 100, to: testTime)
        let times = [testTime, testTimeTwo, testTimeThree]
        attributes.expirationInterval.value = .EveryDay
        attributes.timesTakenToday = "12:00:00,01:10:10"
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString(times)
        let pill = createPill(attributes, now)
        assertDueTodayAtTimeThree(pill: pill, now: now)
    }

    func testDue_whenFourTimesEveryDayAndTakenFourTimesToday_returnsTomorrowATimeOne() {
        let attributes = PillAttributes()
        let now = MockNow()
        now.now = getDateFromDefault(months: 2)
        let testTime = getFiveMinutesAgo(now: now)
        let testTimeTwo = TestDateFactory.createTestDate(byAddingSeconds: 1, to: testTime)
        let testTimeThree = TestDateFactory.createTestDate(byAddingSeconds: 100, to: testTime)
        let testTimeFour = TestDateFactory.createTestDate(byAddingSeconds: 250, to: testTime)
        let times = [testTime, testTimeTwo, testTimeThree, testTimeFour]
        attributes.lastTaken = getOneSecondAgo(now: now)
        attributes.expirationInterval.value = .EveryDay
        attributes.timesTakenToday = "12:00:00,01:10:10,02:20:20,03:30:30"
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString(times)
        let pill = createPill(attributes, now)
        assertDueTomorrowAtTimeOne(pill: pill, now: now)
    }

    func testDue_whenEveryOtherDayAndTakenTwoDaysAgo_returnsTodayAtTimeOne() {
        let attributes = PillAttributes()
        let now = MockNow()
        let mockNowDate = getDateFromDefault(months: 2)
        now.now = mockNowDate
        let testTime = getFiveMinutesAgo(now: now)
        let testTimeTwo = TestDateFactory.createTestDate(byAddingSeconds: 1, to: testTime)
        let testTimes = [testTime, testTimeTwo]
        attributes.lastTaken = getOneSecondAgo(now: now)
        attributes.expirationInterval.value = .EveryOtherDay
        attributes.timesTakenToday = ""
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString(testTimes)
        let pill = createPill(attributes, now)
        assertDueTodayAtTimeOne(pill: pill, now: now)
    }

    func testDue_whenEveryOtherDayAndTakenOnceToday_returnsTwoDaysFromNowAtTimeOne() {
        let attributes = PillAttributes()
        let now = MockNow()
        now.now = getDateFromDefault(months: 2)
        let testTime = getFiveMinutesAgo(now: now)
        attributes.lastTaken = TestDateFactory.createTestDate(daysFrom: 0, now: now)
        attributes.expirationInterval.value = .EveryOtherDay
        attributes.timesTakenToday = "12:00:00"
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attributes, now)
        assertDueTwoDaysFromNowAtTimeOne(pill: pill, now: now)
    }

    func testDue_whenTwiceEveryOtherDayAndTakenOnceToday_returnsTodayAtTimeTwo() {
        let attributes = PillAttributes()
        let now = MockNow()
        now.now = getDateFromDefault(months: 2)
        let testTime = getFiveMinutesAgo(now: now)
        let testTimeTwo = TestDateFactory.createTestDate(byAddingSeconds: 1, to: testTime)
        attributes.lastTaken = TestDateFactory.createTestDate(daysFrom: 0, now: now)
        attributes.expirationInterval.value = .EveryOtherDay
        attributes.timesTakenToday = "12:00:00"
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime, testTimeTwo])
        let pill = createPill(attributes, now)
        assertDueTodayAtTimeTwo(pill: pill, now: now)
    }

    func testDue_whenTwiceEveryOtherDayAndTakenTwiceToday_returnsTwoDaysFromNowAtTimeOne() {
        let attributes = PillAttributes()
        let now = MockNow()
        now.now = getDateFromDefault(months: 2)
        let testTime = getFiveMinutesFromNow(now: now)
        let testTimeTwo = TestDateFactory.createTestDate(byAddingSeconds: 1, to: testTime)
        attributes.lastTaken = TestDateFactory.createTestDate(daysFrom: 0, now: now)
        attributes.expirationInterval.value = .EveryOtherDay
        attributes.timesTakenToday = "12:00:00,01:10:10"
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime, testTimeTwo])
        let pill = createPill(attributes, now)
        assertDueTwoDaysFromNowAtTimeOne(pill: pill, now: now)
    }

    func testDue_whenEveryOtherDayAndTakenYesterday_returnsTomorrowAtTimeOne() {
        let attributes = PillAttributes()
        let now = MockNow()
        now.now = getDateFromDefault(months: 2)
        now.isInYesterdayReturnValue = true
        let testTime = getFiveMinutesAgo(now: now)
        attributes.lastTaken = TestDateFactory.createTestDate(daysFrom: -1, now: now)
        attributes.expirationInterval.value = .EveryOtherDay
        attributes.timesTakenToday = ""
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attributes, now)
        assertDueTomorrowAtTimeOne(pill: pill, now: now)
    }

    func testDue_whenTakenFirstTenDaysAndFinishedOnTenthDay_returnsFirstOfNextMonthAtTimeOne() {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = .FirstXDays
        attributes.expirationInterval.daysOne = 10
        attributes.timesTakenToday = "12:00:00"
        let now = MockNow()
        now.now = januaryTenth
        let testTime = TestDateFactory.createTestDate(byAddingHours: -1, to: now.now)
        attributes.lastTaken = januaryTenth
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attributes, now)
        assertDue(pill: pill, timeIndexExpected: 0, date: februaryFirst, now: now)
    }

    func testDue_whenTakenFirstTwelveDaysAndFinishedOnTwelfthDay_returnsFirstOfNextMonthAtTimeOne() {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = .FirstXDays
        attributes.expirationInterval.daysOne = 12
        attributes.timesTakenToday = "12:00:00"
        let now = MockNow()
        now.now = januaryTwelfth
        let testTime = TestDateFactory.createTestDate(byAddingHours: -1, to: now.now)
        attributes.lastTaken = januaryTwelfth
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attributes, now)
        assertDue(pill: pill, timeIndexExpected: 0, date: februaryFirst, now: now)
    }

    func testDue_whenTakenEveryFirstTenDaysAndIsDuringThoseTenDaysAndTakenToday_returnsNextDayAtTimeOne() {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = .FirstXDays
        attributes.expirationInterval.daysOne = 10
        attributes.timesTakenToday = "12:00:00"
        let now = MockNow()
        now.now = januaryNineth
        let testTime = TestDateFactory.createTestDate(byAddingHours: -1, to: now.now)
        attributes.lastTaken = januaryEighth
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attributes, now)
        assertDueTomorrowAtTimeOne(pill: pill, now: now)
    }

    func testDue_whenTakenEveryFirstTwelveDaysAndIsDuringThoseTwelveDaysAndNotYetTakenToday_returnsTodayAtTimeOne() {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = .FirstXDays
        attributes.expirationInterval.daysOne = 12
        attributes.timesTakenToday = ""
        let now = MockNow()
        now.now = januaryNineth
        let testTime = getOneHourAgo(now: now)
        attributes.lastTaken = januaryEighth
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attributes, now)
        assertDueTodayAtTimeOne(pill: pill, now: now)
    }

    func testDue_whenTakenFirstTenDaysAndFinishedOnTwentiethDay_returnsFirstOfNextMonthAtTimeOne() {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = .FirstXDays
        attributes.expirationInterval.daysOne = 10
        attributes.timesTakenToday = ""
        let now = MockNow()
        let lastTaken = januaryTenth
        let lastDay = januaryTwentieth
        now.now = lastDay
        let expectedDay = februaryFirst
        let testTime = TestDateFactory.createTestDate(byAddingHours: -1, to: now.now)
        attributes.lastTaken = lastTaken
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attributes, now)
        let expected = TestDateFactory.createTestDate(on: expectedDay, at: testTime)
        guard let actual = pill.due else {
            XCTFail("actual is nil")
            return
        }
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenFirstTwentyDaysAndFinishedOnTwentiethDay_returnsFirstOfNextMonthAtTimeOne() {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = .FirstXDays
        attributes.expirationInterval.daysTwo = 20
        attributes.timesTakenToday = "12:00:00"
        let now = MockNow()
        let lastDay = januaryTwentieth
        now.now = lastDay
        let expectedDay = februaryFirst
        let testTime = TestDateFactory.createTestDate(byAddingHours: -1, to: now.now)
        attributes.lastTaken = testTime
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attributes, now)
        let expected = TestDateFactory.createTestDate(on: expectedDay, at: testTime)
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenFirstTwentyDaysAndNotYetFinishedOnNineteenthDay_returnsSameDayAtNextTime() {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = .FirstXDays
        attributes.expirationInterval.daysOne = 20
        attributes.timesTakenToday = ""
        let now = MockNow()
        now.now = januaryNineteenth
        let testTime = TestDateFactory.createTestDate(byAddingHours: -24, to: now.now)
        attributes.lastTaken = testTime
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attributes, now)
        assertDueTodayAtTimeOne(pill: pill, now: now)
    }

    func testDue_whenTakenFirstTwentyDaysAndFinishedOnNineteenthDay_returnsNextDayAtTimeOne() {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = .FirstXDays
        attributes.expirationInterval.daysOne = 20
        attributes.timesTakenToday = "12:00:00"
        let now = MockNow()
        let testTime = getFiveMinutesAgo(now: now)
        attributes.lastTaken = testTime
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attributes, now)
        assertDueTomorrowAtTimeOne(pill: pill, now: now)
    }

    func testDue_whenTakenLastTenDaysAndFinishedOnLastDayOfMonth_returnsExpectedDate() {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = .LastXDays
        attributes.expirationInterval.daysOne = 10
        attributes.timesTakenToday = "12:00:00"
        let now = MockNow()
        attributes.lastTaken = januaryThirtyFirst
        now.now = februaryFirst
        let testTime = getFiveMinutesFromNow(now: now)
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attributes, now)
        assertDue(pill: pill, timeIndexExpected: 0, date: februaryNineteenth, now: now)
    }

    func testDue_whenTakenLastTenDaysAndIsFirstOfMonth_returnsExpectedDate() {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = .LastXDays
        attributes.expirationInterval.daysOne = 10
        attributes.timesTakenToday = ""
        let now = MockNow()
        now.now = februaryFirst
        attributes.lastTaken = januaryThirtyFirst
        let testTime = getFiveMinutesFromNow(now: now)
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attributes, now)
        assertDue(pill: pill, timeIndexExpected: 0, date: februaryNineteenth, now: now)
    }

    func testDue_whenLastTakenTwentyDaysAndFinishedOnLastDayOfMonth_returnsFirstOfLastTwentyDaysAtTimeOne() {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = .LastXDays
        attributes.expirationInterval.daysTwo = 20
        attributes.timesTakenToday = ""
        let now = MockNow()
        now.now = januaryThirtyFirst
        attributes.lastTaken = januaryThirtyFirst
        let testTime = getFiveMinutesFromNow(now: now)
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attributes, now)
        assertDue(pill: pill, timeIndexExpected: 0, date: februaryNineth, now: now)
    }

    func testDue_whenTakenLastTwentyDaysAndIsFirstOfMonth_returnsFirstOfLastTwentyDaysAtTimeOne() {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = .LastXDays
        attributes.expirationInterval.daysOne = 20
        attributes.timesTakenToday = ""
        let now = MockNow()
        now.now = februaryFirst
        attributes.lastTaken = januaryThirtyFirst
        let testTime = getFiveMinutesFromNow(now: now)
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attributes, now)
        assertDue(pill: pill, timeIndexExpected: 0, date: februaryNineth, now: now)
    }

    func testDue_whenXDaysOnXDaysOffAndHasNotStarted_returnsNil() {
        let attributes = createXDaysOnXDaysOffAttributes()
        attributes.lastTaken = Date()
        let pill = createPill(attributes)
        XCTAssertNil(pill.due)
    }

    func testDue_whenXDaysOnXDaysOffAndHasJustStarted_returnsTodayAtTimeOne() {
        let now = MockNow()
        let testTime = getFiveMinutesFromNow(now: now)
        let attributes = createXDaysOnXDaysOffAttributes(daysOne: 12, daysTwo: 4)
        attributes.lastTaken = Date()
        attributes.expirationInterval.startPositioning()
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTime])
        let pill = createPill(attributes, now)
        assertDueTodayAtTimeOne(pill: pill, now: now)
    }

    func testDue_whenXDaysOnXDaysOffAndHasTakenOnceOutOfTwiceOnStartDay_returnsTodayAtTimeTwo() {
        let now = MockNow()
        let testTimeOne = getFiveMinutesFromNow(now: now)
        let testTimeTwo = getTwentyMinutesFromNow(now: now)
        let times = [testTimeOne, testTimeTwo]
        let attributes = createXDaysOnXDaysOffAttributes(daysOne: 12, daysTwo: 4)
        attributes.lastTaken = Date()
        attributes.timesTakenToday = "12:00:00"
        attributes.expirationInterval.startPositioning()
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString(times)
        let pill = createPill(attributes, now)
        assertDueTodayAtTimeTwo(pill: pill, now: now)
    }

    func testDue_whenXDaysOnXDaysOffAndHasTakenTwiceOutOfTwiceOnStartDay_returnsTomorrowAtTimeOne() {
        let now = MockNow()
        let times = [getFiveMinutesFromNow(now: now), getTwentyMinutesFromNow(now: now)]
        let attributes = createXDaysOnXDaysOffAttributes(daysOne: 12, daysTwo: 4)
        attributes.lastTaken = Date()
        attributes.timesTakenToday = "12:00:00,01:10:10"
        attributes.expirationInterval.startPositioning()
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString(times)
        let pill = createPill(attributes, now)
        assertDueTomorrowAtTimeOne(pill: pill, now: now)
    }

    func testDue_whenXDaysOnXDaysOffAndIsOnLastOnDayAndTakenOnce_returnsLastDateAtTimeTwo() {
        let now = MockNow()
        now.now = februaryFirst
        let attributes = createXDaysOnXDaysOffAttributes(
            daysOne: 12, daysTwo: 4, isOn: true, daysPosition: 12
        )
        attributes.lastTaken = januaryThirtyFirst
        let times = [getFiveMinutesFromNow(now: now), getTwentyMinutesFromNow(now: now)]
        attributes.timesTakenToday = "12:00:00"
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString(times)
        let pill = createPill(attributes, now)
        assertDueTodayAtTimeTwo(pill: pill, now: now)
        assertDue(pill: pill, timeIndexExpected: 1, date: now.now, now: now)
    }

    func testDue_whenXDaysOnXDaysOffAndIsOnLastOnDayAndTakenTwice_returnsNextStartDateAtTimeOne() {
        let now = MockNow()
        let attributes = createXDaysOnXDaysOffAttributes(
            daysOne: 12, daysTwo: 4, isOn: true, daysPosition: 12
        )
        now.now = februaryFirst
        let dateLastTaken = TestDateFactory.createTestDate(byAddingHours: -1, to: now.now)
        attributes.lastTaken = dateLastTaken
        attributes.lastTaken = januaryThirtyFirst
        let testTimeOne = getFiveMinutesFromNow(now: now)
        let testTimeTwo = getTwentyMinutesFromNow(now: now)
        let testTimes = [testTimeOne, testTimeTwo]
        attributes.timesTakenToday = "12:00:00,01:10:10"
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString(testTimes)
        let pill = createPill(attributes, now)
        assertDue(pill: pill, timeIndexExpected: 0, date: februarySixth, now: now)
    }

    func testDue_whenXDaysOnXDaysOffAndIsOnFirstOffDay_returnsNextStartDateAtTimeOne() {
        let now = MockNow()
        let attributes = createXDaysOnXDaysOffAttributes(
            daysOne: 12, daysTwo: 4, isOn: false, daysPosition: 1
        )
        now.now = februaryFirst
        attributes.lastTaken = TestDateFactory.createTestDate(byAddingHours: -25, to: now.now)
        attributes.lastTaken = januaryThirtyFirst
        let testTimeOne = getFiveMinutesFromNow(now: now)
        let testTimeTwo = getTwentyMinutesFromNow(now: now)
        attributes.timesTakenToday = ""
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTimeOne, testTimeTwo])
        let pill = createPill(attributes, now)
        assertDue(pill: pill, timeIndexExpected: 0, date: februaryFifth, now: now)
    }

    func testDue_whenXDaysOnXDaysOffAndIsOnLastOffDay_returnsTomorrowTimeOne() {
        let now = MockNow()
        let attributes = createXDaysOnXDaysOffAttributes(
            daysOne: 12, daysTwo: 4, isOn: false, daysPosition: 4
        )
        now.now = februaryFirst
        attributes.lastTaken = Date()
        let testTimeOne = getFiveMinutesFromNow(now: now)
        let testTimeTwo = getTwentyMinutesFromNow(now: now)
        let times = [testTimeOne, testTimeTwo]
        attributes.timesTakenToday = ""
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString(times)
        let pill = createPill(attributes, now)
        assertDueTomorrowAtTimeOne(pill: pill, now: now)
    }

    func testDue_whenXDaysOnXDaysWith1DayOn1DayOffAndTakenOnceOfOnce_returnsTwoDaysFromNowAtTimeOne() {
        let now = MockNow()
        let attributes = createXDaysOnXDaysOffAttributes(
            daysOne: 1, daysTwo: 1, isOn: true, daysPosition: 1
        )
        now.now = februaryFirst
        attributes.lastTaken = TestDateFactory.createTestDate(byAddingHours: -2, to: now.now)
        attributes.lastTaken = januaryThirtyFirst
        let testTimeOne = getFiveMinutesFromNow(now: now)
        attributes.timesTakenToday = "12:00:00"
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString([testTimeOne])
        let pill = createPill(attributes, now)
        assertDueTwoDaysFromNowAtTimeOne(pill: pill, now: now)
    }

    func testIsDue_whenTimesTakenTodayEqualsTimesday_returnsFalse() {
        let attributes = createPillAttributes(minutesFromNow: -5)
        attributes.lastTaken = Date(timeIntervalSinceNow: -1000)
        attributes.timesTakenToday = "12:00:00,01:10:10"
        attributes.times = "12:00:00,12:00:10"
        let pill = createPill(attributes)
        XCTAssertFalse(pill.isDue)
    }

    func testIsDue_whenPillNotYetTakenAndTimeOneIsPast_returnsTrue() {
        let attributes = createPillAttributes(minutesFromNow: -5)
        let pastDate = Date(timeInterval: -5, since: Date())
        let pastDateString = PDDateFormatter.convertTimesToCommaSeparatedString([pastDate])
        attributes.lastTaken = Date(timeIntervalSinceNow: -1000)
        attributes.expirationInterval.value = .EveryDay
        attributes.timesTakenToday = ""
        attributes.times = pastDateString
        let pill = createPill(attributes)
        XCTAssertTrue(pill.isDue)
    }

    func testIsDue_whenPillTakenTodayAndTimesadayIsOne_returnsFalse() {
        let attributes = createPillAttributes(minutesFromNow: -5)
        attributes.timesTakenToday = "12:00:00"
        attributes.times = "12:00:00"
        let pill = createPill(attributes)
        XCTAssertFalse(pill.isDue)
    }

    func testIsDue_whenPillTakenOnceAndTimesadayIsTwoAndTimesTwoIsNotPast_returnsFalse() {
        let attributes = createPillAttributes(minutesFromNow: 5)
        let pastDate = Date(timeInterval: -5, since: Date())
        let notPastDate = Date(timeInterval: 5, since: Date())
        let timeString = PDDateFormatter.convertTimesToCommaSeparatedString([notPastDate, pastDate])
        attributes.timesTakenToday = "12:00:00"
        attributes.times = timeString
        let pill = createPill(attributes)
        XCTAssertFalse(pill.isDue)
    }

    func testIsDue_whenPillTakenOnceAndTimesadayIsTwoAndTimesTwoIsPast_returnsTrue() {
        let attributes = createPillAttributes(minutesFromNow: -5)
        let pastDateOne = Date(timeInterval: -50, since: Date())
        let pastDateTwo = Date(timeInterval: -5, since: Date())
        let timeString = PDDateFormatter.convertTimesToCommaSeparatedString(
            [pastDateOne, pastDateTwo]
        )
        attributes.expirationInterval.value = .EveryDay
        attributes.lastTaken = Date(timeIntervalSinceNow: -1000)
        attributes.timesTakenToday = "12:00:00"
        attributes.times = timeString
        let pill = createPill(attributes)
        XCTAssert(pill.isDue)
    }

    func testIsDue_whenPillTakenTwiceTodayAndTimesadayIsTwo_returnsFalse() {
        let attributes = createPillAttributes(minutesFromNow: -5)
        attributes.timesTakenToday = "12:00:00,01:10:10"
        attributes.times = "12:00:00,12:00:10"
        let pill = createPill(attributes)
        XCTAssertFalse(pill.isDue)
    }

    func testIsDue_whenNeverTakenByWayOfNil_returnsFalse() {
        let attributes = createPillAttributes(minutesFromNow: -5)
        attributes.lastTaken = nil
        attributes.times = "12:00:00"
        attributes.timesTakenToday = ""
        let pill = createPill(attributes)
        XCTAssertFalse(pill.isDue)
    }

    func testIsDue_whenNeverTakenByWayOfDefault_returnsFalse() {
        let attributes = createPillAttributes(minutesFromNow: -5)
        attributes.lastTaken = TestDateFactory.defaultDate
        attributes.times = "12:00:00"
        attributes.timesTakenToday = ""
        let pill = createPill(attributes)
        XCTAssertFalse(pill.isDue)
    }

    func testIsNew_whenIsCreatedFalse_returnsTrue() {
        let attributes = PillAttributes()
        attributes.lastTaken = nil
        attributes.isCreated = false
        let pill = createPill(attributes)
        XCTAssertTrue(pill.isNew)
    }

    func testIsNew_whenIsCreatedTrue_returnsFalse() {
        let attributes = PillAttributes()
        attributes.lastTaken = nil
        attributes.isCreated = true
        let pill = createPill(attributes)
        XCTAssertFalse(pill.isNew)
    }

    func testIsDone_whenTimesTakenIsLessThanTimesaday_returnsFalse() {
        let attributes = PillAttributes()
        attributes.times = "12:00:00,12:00:10"
        attributes.timesTakenToday = "12:00:00"
        attributes.lastTaken = Date()
        let pill = createPill(attributes)
        XCTAssertFalse(pill.isDone)
    }

    func testIsDone_whenTimesTakenIsEqualToTimesaday_returnsTrue() {
        let attributes = PillAttributes()
        attributes.times = "12:00:00,12:00:10"
        attributes.timesTakenToday = "12:00:00,01:10:10"
        attributes.lastTaken = Date()
        let pill = createPill(attributes)
        XCTAssertTrue(pill.isDone)
    }

    func testIsDone_whenTimesTakenIsGreaterThanTimesaday_returnsTrue() {
        let attributes = PillAttributes()
        attributes.times = "12:00:00,12:00:10"
        attributes.timesTakenToday = "12:00:00,12:00:05,12:00:06"
        attributes.lastTaken = Date()
        let pill = createPill(attributes)
        XCTAssertTrue(pill.isDone)
    }

    func testIsDone_whenLastTakenIsNil_returnsFalse() {
        let attributes = PillAttributes()
        attributes.times = "12:00:00,12:00:10"
        attributes.timesTakenToday = "12:00:00,12:00:05,12:00:06"
        attributes.lastTaken = nil
        let pill = createPill(attributes)
        XCTAssertFalse(pill.isDone)
    }

    func testIsDone_whenXDaysOnXDaysOffAndOnOffMode_returnsTrue() {
        let attributes = createXDaysOnXDaysOffAttributes(
            daysOne: 1, daysTwo: 1, isOn: false, daysPosition: 1
        )
        attributes.times = "12:00:00,12:00:10"
        attributes.lastTaken = Date()
        attributes.timesTakenToday = ""
        let pill = createPill(attributes)
        XCTAssertTrue(pill.isDone)
    }

    func testIsDone_whenXDaysOnXDaysOffAndOnOnModeAndStillHasTimesToTake_returnsFalse() {
        let attributes = createXDaysOnXDaysOffAttributes(
            daysOne: 1, daysTwo: 1, isOn: true, daysPosition: 1
        )
        attributes.times = "12:00:00,12:00:10"
        attributes.timesTakenToday = ""
        attributes.lastTaken = Date()
        let pill = createPill(attributes)
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
        let newAttributes = PillAttributes()
        let timesTakenToday = "12:00:00"
        newAttributes.name = newName
        newAttributes.times = timesString
        newAttributes.notify = true
        newAttributes.lastTaken = newLastTaken
        newAttributes.expirationInterval.value = newExpiration
        newAttributes.timesTakenToday = timesTakenToday
        newAttributes.expirationInterval.daysOne = 5
        pill.set(attributes: newAttributes)
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

    func testSet_alwaysSetsIsCreatedToTrue() {
        let pill = createPill(PillAttributes())
        let newAttributes = PillAttributes()
        newAttributes.isCreated = false  // To prove it does not matter
        pill.set(attributes: newAttributes)
        XCTAssertTrue(pill.isCreated)
    }

    func testSet_whenGivenNil_doesNotSet() {
        let startAttributes = PillAttributes()
        let testName = "NAME"
        let testDate = Date()
        let testTimeString = "12:00:00"
        let testExpInterval = PillExpirationIntervalSetting.FirstXDays
        let testXDays = "4"
        startAttributes.name = testName
        startAttributes.lastTaken = testDate
        startAttributes.times = testTimeString
        startAttributes.notify = true
        startAttributes.timesTakenToday = "12:00:00,12:10:10"
        startAttributes.expirationInterval.value = testExpInterval
        startAttributes.expirationInterval.daysOne = 4
        let pill = createPill(startAttributes)
        let newAttributes = PillAttributes()
        newAttributes.name = nil
        newAttributes.lastTaken = nil
        newAttributes.times = nil
        newAttributes.notify = nil
        newAttributes.timesTakenToday = nil
        pill.set(attributes: newAttributes)
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
        let attributes = PillAttributes()
        attributes.lastTaken = Date()  // Not setting times
        let pill = createPill(PillAttributes())
        XCTAssertEqual(0, pill.timesaday)  // Just to prove it inits to 0
        pill.set(attributes: attributes)
        let expected = DateFactory.createTimesFromCommaSeparatedString(DefaultPillAttributes.TIME)
        XCTAssertEqual(expected, pill.times)
    }

    func testSet_ifGivenPositionAndNeverTaken_setsLastTakenToArbitraryYesterdayDate() {
        let pillattributes = createXDaysOnXDaysOffAttributes(daysOne: 5, daysTwo: 4)
        pillattributes.times = "12:00:00"
        let pill = createPill(pillattributes)

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

        let expected = TestDateFactory.createTestDate(byAddingHours: -24, to: Date())
        if let actual = pill.lastTaken {
            PDAssertSameTime(expected, actual)
        } else {
            XCTFail("Pill did not initalize its lastTaken")
        }
    }

    func testSwallow_whenTimesTakenTodayEqualToTimesaday_doesNotIncreaseTimesTakenToday() {
        let attributes = PillAttributes()
        attributes.times = "12:00:00"
        attributes.timesTakenToday = "12:00:00"
        attributes.lastTaken = Date()
        let pill = createPill(attributes)
        pill.swallow()
        XCTAssertEqual(1, pill.timesTakenToday)
    }

    func testSwallow_whenTimesTakenTodayEqualToTimesaday_doesNotSetLastTaken() {
        let attributes = PillAttributes()
        let originalLastTaken = Date()
        attributes.lastTaken = originalLastTaken
        attributes.times = "12:00:00"
        attributes.timesTakenToday = "12:00:00"
        let pill = createPill(attributes)
        pill.swallow()
        XCTAssertEqual(originalLastTaken, pill.lastTaken)
    }

    func testSwallow_whenTimesTakenTodayIsLessThanTimesaday_increasesTimesTakenToday() {
        let attributes = PillAttributes()
        attributes.times = "12:00:00"
        attributes.timesTakenToday = ""
        attributes.lastTaken = Date()
        let pill = createPill(attributes)
        pill.swallow()
        XCTAssertEqual(1, pill.timesTakenToday)
    }

    func testSwallow_whenTimesTakenTodayIsLessThanTimesaday_stampsLastTaken() {
        let attributes = PillAttributes()
        let originalLastTaken = Date()
        attributes.lastTaken = originalLastTaken
        attributes.times = "12:00:00"
        attributes.timesTakenToday = ""
        let pill = createPill(attributes)
        pill.swallow()
        XCTAssert(originalLastTaken < pill.lastTaken! && pill.lastTaken! < Date())
    }

    func testSwallow_whenLastTakenIsNil_increasesTimesTakenToday() {
        let attributes = PillAttributes()

        // initialize with timesTakenToday=1
        attributes.times = "12:00:00"
        attributes.timesTakenToday = ""
        attributes.lastTaken = nil

        let pill = createPill(attributes)
        pill.swallow()
        XCTAssertEqual(1, pill.timesTakenToday)
    }

    func testSwallow_whenLastTakenIsNil_stampsLastTaken() {
        let attributes = PillAttributes()
        attributes.lastTaken = nil
        attributes.times = "12:00:00"
        attributes.timesTakenToday = "12:00:00"
        let pill = createPill(attributes)
        pill.swallow()
        XCTAssert(Date().timeIntervalSince(pill.lastTaken!) < 0.1)
    }

    func testSwallow_whenLastTakenNilAndUsingXDaysOnXDaysOffAndPosHasNotStarted_startsPositioning() {
        let attributes = createXDaysOnXDaysOffAttributes(daysOne: 5, daysTwo: 5)
        attributes.lastTaken = nil
        attributes.times = "12:00:00"
        attributes.timesTakenToday = ""
        let pill = createPill(attributes)
        pill.swallow()
        let interval = attributes.expirationInterval
        if interval.xDaysPosition == nil || interval.xDaysIsOn == nil {
            XCTFail("XDays positioning did not get initlaized.")
            return
        }

        let expected = 1
        XCTAssertEqual(expected, attributes.expirationInterval.xDaysPosition!)
        XCTAssert(attributes.expirationInterval.xDaysIsOn!)
    }

    func testSwallow_whenLastTakenIsNilAndUsingXDaysOnXDaysOffAndPositioningHasStarted_doesNotResetXDaysPositioning() {
        let attributes = createXDaysOnXDaysOffAttributes(
            daysOne: 5, daysTwo: 5, isOn: true, daysPosition: 4
        )
        attributes.lastTaken = nil
        attributes.times = "12:00:00,12:10:00"
        attributes.timesTakenToday = ""
        let pill = createPill(attributes)
        pill.swallow()
        let interval = attributes.expirationInterval
        if interval.xDaysPosition == nil || interval.xDaysIsOn == nil {
            XCTFail("XDays positioning did not get initlaized.")
            return
        }
        XCTAssertEqual(4, attributes.expirationInterval.xDaysPosition!)
        XCTAssertEqual(true, attributes.expirationInterval.xDaysIsOn)
    }

    func testSwallow_whenLastTakenIsNilAndNotUsingXDaysOnXDaysOff_doesNotStartXDaysPositioning() {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = .FirstXDays
        attributes.expirationInterval.daysOne = 5
        attributes.lastTaken = nil
        attributes.times = "12:00:00"
        attributes.timesTakenToday = ""
        let pill = createPill(attributes)
        pill.swallow()
        let interval = attributes.expirationInterval
        XCTAssertNil(interval.xDaysPosition)
        XCTAssertNil(interval.xDaysIsOn)
    }

    func testUnswallow_whenTakenZeroTimesToday_doesNothing() {
        let attributes = PillAttributes()
        attributes.timesTakenToday = ""
        attributes.lastTaken = Date()
        let pill = createPill(attributes)
        pill.unswallow()
        XCTAssertEqual(0, pill.timesTakenToday)
    }

    func testUnswallow_whenNeverTaken_doesNothing() {
        let attributes = PillAttributes()
        attributes.timesTakenToday = "12:00:00"
        attributes.lastTaken = nil
        let pill = createPill(attributes)
        pill.unswallow()
        XCTAssertEqual(1, pill.timesTakenToday)
    }

    func testUnswallow_decrementsTimesTakenToday() {
        let attributes = PillAttributes()
        attributes.timesTakenToday = "12:00:00,01:10:10"
        attributes.lastTaken = Date()
        let pill = createPill(attributes)
        pill.unswallow()
        XCTAssertEqual(1, pill.timesTakenToday)
    }

    func testUnswallow_resetsLastTakenToPenultimateDate() {
        // This test verifies the last taken is popped off and the penultimate last taken
        // gets reset as the last taken during unswallow().
        let attributes = PillAttributes()
        let lastTaken = Date()
        let timeString = "12:00:00,\(PDDateFormatter.formatInternalTime(lastTaken))"
        attributes.timesTakenToday = timeString
        attributes.lastTaken = lastTaken
        let pill = createPill(attributes)

        pill.unswallow()

        guard let actual = pill.lastTaken else {
            XCTFail("pill.lastTaken should not be nil.")
            return
        }

        let expected = DateFactory.createTimesFromCommaSeparatedString(timeString)[0]
        PDAssertEquiv(expected, actual)
    }

    func testUnswallow_whenLastLastTakenNotToday_resetsToDateInToday() {
        let attributes = PillAttributes()
        let lastTaken = Date()
        attributes.timesTakenToday = "12:00:00,01:10:10"
        attributes.lastTaken = lastTaken
        let pill = createPill(attributes)
        pill.unswallow()

        if let actual = pill.lastTaken {
            XCTAssert(actual.isInToday())
        } else {
            XCTFail("pill.lastTaken should not be nil.")
        }
    }

    func testUnswallow_whenOffAtPositionGreaterThanOne_doesNothing() {
        let attributes = createXDaysOnXDaysOffAttributes(
            daysOne: 5, daysTwo: 5, isOn: false, daysPosition: 2
        )
        attributes.times = "12:00:00,01:10:10"
        attributes.timesTakenToday = "12:00:00"  // taken 1 time
        attributes.lastTaken = Date()
        let pill = createPill(attributes)
        pill.unswallow()
        XCTAssertEqual(1, pill.timesTakenToday)
    }

    func testUnswallow_whenOffAtPositionEqualToOne_resetToOnAtLastPosition() {
        let attributes = createXDaysOnXDaysOffAttributes(
            daysOne: 6, daysTwo: 5, isOn: false, daysPosition: 1
        )
        attributes.times = "12:00:00,01:10:10"
        attributes.timesTakenToday = "12:00:00"
        attributes.lastTaken = Date()
        let pill = createPill(attributes)
        pill.unswallow()
        XCTAssertTrue(pill.expirationInterval.xDaysIsOn!)
        XCTAssertEqual(6, pill.expirationInterval.xDaysPosition)
    }

    func testUnswallow_whenOffAtPositionEqualToOne_unswallows() {
        let attributes = createXDaysOnXDaysOffAttributes(
            daysOne: 2, daysTwo: 2, isOn: false, daysPosition: 1
        )
        attributes.times = "12:00:00,01:10:10"
        attributes.timesTakenToday = "12:00:00"
        attributes.lastTaken = Date()
        let pill = createPill(attributes)
        pill.unswallow()
        XCTAssertEqual(0, pill.timesTakenToday)
    }

    func testUnswallow_whenXDaysOn_resetsToPositionBefore() {
        let attributes = createXDaysOnXDaysOffAttributes(
            daysOne: 6, daysTwo: 5, isOn: true, daysPosition: 6
        )
        attributes.times = "12:00:00,01:10:10"
        attributes.timesTakenToday = "12:00:00"
        attributes.lastTaken = Date()
        let pill = createPill(attributes)
        pill.unswallow()
        XCTAssertTrue(pill.expirationInterval.xDaysIsOn!)
        XCTAssertEqual(5, pill.expirationInterval.xDaysPosition)
    }

    func testUnswallow_whenXDaysOnAtFirstPosition_resetToOffPositionAtLastPosition() {
        let attributes = createXDaysOnXDaysOffAttributes(
            daysOne: 6, daysTwo: 5, isOn: true, daysPosition: 1
        )
        attributes.times = "12:00:00,01:10:10"
        attributes.timesTakenToday = "12:00:00"
        attributes.lastTaken = Date()
        let pill = createPill(attributes)
        pill.unswallow()
        XCTAssertFalse(pill.expirationInterval.xDaysIsOn ?? true)
        XCTAssertEqual(5, pill.expirationInterval.xDaysPosition)
    }

    func testUnswallow_whenXDaysOn_unswallows() {
        let attributes = createXDaysOnXDaysOffAttributes(
            daysOne: 6, daysTwo: 5, isOn: true, daysPosition: 1
        )
        attributes.times = "12:00:00,01:10:10"
        attributes.timesTakenToday = "12:00:00"
        attributes.lastTaken = Date()
        let pill = createPill(attributes)
        pill.unswallow()
        XCTAssertEqual(0, pill.timesTakenToday)
    }

    func testUnswallow_andMoreTimesToUntakeYetForTheDay_doesNotDecrementPosition() {
        let attributes = createXDaysOnXDaysOffAttributes(
            daysOne: 6, daysTwo: 5, isOn: true, daysPosition: 3
        )
        attributes.times = "12:00:00,01:10:10"
        attributes.timesTakenToday = "12:00:00,01:10:10"
        attributes.lastTaken = Date()
        let pill = createPill(attributes)
        pill.unswallow()
        XCTAssertTrue(pill.expirationInterval.xDaysIsOn ?? false)
        XCTAssertEqual(3, pill.expirationInterval.xDaysPosition)
    }

    func testAwaken_whenLastTakenWasToday_doesNotClear() {
        let attributes = PillAttributes()
        let timeString = "12:00:00,01:10:10"
        attributes.timesTakenToday = timeString
        attributes.lastTaken = Date()
        let pill = createPill(attributes)
        pill.awaken()
        let expected = DateFactory.createTimesFromCommaSeparatedString(timeString)
        let expectedCount = 2
        XCTAssertEqual(expectedCount, pill.timesTakenToday)
        XCTAssertEqual(expectedCount, pill.timesTakenTodayList.count)
        XCTAssertEqual(expected[0], pill.timesTakenTodayList[0])
        XCTAssertEqual(expected[1], pill.timesTakenTodayList[1])
    }

    func testAwaken_whenHasNoLastTaken_clears() {
        let attributes = PillAttributes()
        attributes.lastTaken = nil
        let timeString = "12:00:00,01:10:10"
        attributes.timesTakenToday = timeString
        let pill = createPill(attributes)
        pill.awaken()
        XCTAssertEqual(0, pill.timesTakenToday)
        XCTAssertEqual(0, pill.timesTakenTodayList.count)
    }

    func testAwaken_whenTimesTakenTodayIsZero_clears() {
        let attributes = PillAttributes()
        let timeString = ""  // 0 times taken today
        attributes.timesTakenToday = timeString
        attributes.lastTaken = Date()
        let pill = createPill(attributes)
        pill.awaken()
        XCTAssertEqual(0, pill.timesTakenToday)
        XCTAssertEqual(0, pill.timesTakenTodayList.count)
    }

    func testAwaken_whenLastTakenWasYesterday_clears() {
        let attributes = PillAttributes()
        attributes.timesTakenToday = "12:00:00,01:10:10"
        attributes.lastTaken = Date(timeIntervalSinceNow: -86400)
        let pill = createPill(attributes)
        pill.awaken()
        XCTAssertEqual(0, pill.timesTakenToday)
    }

    func testAwaken_whenAlreadyAwokenToday_doesNotAwaken() {
        let attributes = PillAttributes()
        attributes.timesTakenToday = "12:00:00,01:10:10"
        attributes.lastTaken = Date(timeIntervalSinceNow: -86400)
        attributes.lastWakeUp = Date()
        let pill = createPill(attributes)
        pill.awaken()
        XCTAssertEqual(2, pill.timesTakenToday)
    }

    func testAwaken_whenNotYetWokeUpToday_setsWakeUpDate() {
        let attributes = PillAttributes()
        attributes.timesTakenToday = "12:00:00,01:10:10"
        attributes.lastTaken = Date(timeIntervalSinceNow: -86400)
        attributes.lastWakeUp = TestDateFactory.createTestDate(daysFrom: -1)
        let pill = createPill(attributes)
        pill.awaken()
        XCTAssert(pill.attributes.lastWakeUp?.isInToday() ?? false)
    }

    func testAwaken_whenNotXDays_doesNotIncrementXDays() {
        let now = MockNow()
        now.now = TestDateFactory.createTestDate(hour: 5)
        let attributes = PillAttributes()
        attributes.timesTakenToday = "12:00:00,01:10:10"
        attributes.expirationInterval.value = .FirstXDays
        attributes.lastWakeUp = TestDateFactory.createYesterday()
        attributes.lastTaken = TestDateFactory.createYesterday()
        let pill = createPill(attributes, now)
        pill.awaken()
        XCTAssertNil(pill.expirationInterval.xDaysPosition)
        XCTAssertNil(pill.expirationInterval.xDaysIsOn)
    }

    func testAwaken_whenXDaysAndNotWokeUpOrTakenOnFirstDay_incrementsXDays() {
        let now = MockNow()
        now.now = TestDateFactory.createTestDate(hour: 5)
        let attributes = createPillAttributesForAwakenXDaysTest(
            lastWakeUp: TestDateFactory.createYesterday(),
            lastTaken: TestDateFactory.createYesterday(),
            position: "on-1"
        )
        let pill = createPill(attributes, now)
        pill.awaken()
        // assert the position is on-2
        assertPosition(actual: pill, expectedPosition: 2, expectedOnPosition: true)
    }

    func testAwaken_whenXDaysAndWokeUpAndNotTakenOnFirstDay_doesNotIncrementXDays() {
        let now = MockNow()
        now.now = TestDateFactory.createTestDate(hour: 5)
        let attributes = createPillAttributesForAwakenXDaysTest(
            lastWakeUp: Date(),
            lastTaken: TestDateFactory.createYesterday(),
            position: "on-1"
        )
        let pill = createPill(attributes, now)
        pill.awaken()
        // assert the same position that it was already
        assertPosition(actual: pill, expectedPosition: 1, expectedOnPosition: true)
    }

    func testAwaken_whenXDaysAndNotWokeUpButTakenOnFirstDay_doesNotIncrementXDays() {
        // This is because `.swallow()` wakes-up the pill before swallowing.
        // There is a now way a Pill would need to wake-up again if it was already swallowed.
        let now = MockNow()
        now.now = TestDateFactory.createTestDate(hour: 5)
        let attributes = createPillAttributesForAwakenXDaysTest(
            lastWakeUp: TestDateFactory.createYesterday(),
            lastTaken: Date(),
            position: "on-1"
        )
        let pill = createPill(attributes, now)
        pill.awaken()
        // assert the same position that it was already
        assertPosition(actual: pill, expectedPosition: 1, expectedOnPosition: true)
    }

    func testAwaken_whenXDaysAndNotWokeUpOrTakenOnSecondDay_incrementsXDays() {
        let now = MockNow()
        now.now = TestDateFactory.createTestDate(hour: 5)
        let attributes = createPillAttributesForAwakenXDaysTest(
            lastWakeUp: TestDateFactory.createYesterday(),
            lastTaken: TestDateFactory.createYesterday(),
            position: "on-2"
        )
        let pill = createPill(attributes, now)
        pill.awaken()
        // assert the position is off-1
        assertPosition(actual: pill, expectedPosition: 1, expectedOnPosition: false)
    }

    func testAwaken_whenXDaysAndNotWokeUpOrTakenOffFirstDay_incrementsXDays() {
        let now = MockNow()
        now.now = TestDateFactory.createTestDate(hour: 5)
        let attributes = createPillAttributesForAwakenXDaysTest(
            lastWakeUp: TestDateFactory.createYesterday(),
            lastTaken: TestDateFactory.createYesterday(),
            position: "off-1"
        )
        let pill = createPill(attributes, now)
        pill.awaken()
        // assert the position is off-2
        assertPosition(actual: pill, expectedPosition: 2, expectedOnPosition: false)
    }

    func testAwaken_whenXDaysAndNotWokeUpOrTakenOffSecondDay_incrementsXDays() {
        let now = MockNow()
        now.now = TestDateFactory.createTestDate(hour: 5)
        let attributes = createPillAttributesForAwakenXDaysTest(
            lastWakeUp: TestDateFactory.createYesterday(),
            lastTaken: TestDateFactory.createYesterday(),
            position: "off-2"
        )
        let pill = createPill(attributes, now)
        pill.awaken()
        // assert the position is on-1
        assertPosition(actual: pill, expectedPosition: 1, expectedOnPosition: true)
    }

    private func createPill(_ attributes: PillAttributes, _ now: NowProtocol?=nil) -> Pill {
        Pill(pillData: PillStruct(UUID(), attributes), now: now)
    }

    private func createDueTime(_ time: Date, days: Int, now: NowProtocol) -> Date {
        let hours = days * 24
        let date = TestDateFactory.createTestDate(byAddingHours: hours, to: now.now)
        return TestDateFactory.createTestDate(on: date, at: time, now: now)
    }

    private func createPillAttributes(minutesFromNow: Int) -> PillAttributes {
        let attributes = PillAttributes()
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
        attributes.times = PDDateFormatter.convertTimesToCommaSeparatedString(times)
        return attributes
    }

    private func createPillAttributesForAwakenXDaysTest(
        lastWakeUp: Date?=nil, lastTaken: Date?=nil, position: String="on-1"
    ) -> PillAttributes {
        let attributes = createXDaysOnXDaysOffAttributes(daysOne: 2, daysTwo: 2)
        attributes.timesTakenToday = "12:00:00,01:10:10"

        // Parametized
        attributes.lastWakeUp = lastWakeUp ?? Date()
        attributes.lastTaken = lastTaken ?? Date()
        attributes.expirationInterval.xDaysPosition = extractPosition(position)
        attributes.expirationInterval.xDaysIsOn = position.starts(with: "on")

        return attributes
    }

    private func extractPosition(_ position: String) -> Int {
        let positionFailureMessage = "Failed to use the position argument correctly. See other tests!"
        guard let lastPositionCharacter = position.last else {
            XCTFail(positionFailureMessage)
            return -1
        }
        guard let positionValue = Int(String(lastPositionCharacter)) else {
            XCTFail(positionFailureMessage)
            return -1
        }
        return positionValue
    }

    private func createXDaysOnXDaysOffAttributes(
        daysOne: Int?=nil, daysTwo: Int?=nil, isOn: Bool?=nil, daysPosition: Int?=nil
    ) -> PillAttributes {
        TestPillAttributesFactory.createForXDaysOnXDaysOff(
            daysOne: daysOne, daysTwo: daysTwo, isOn: isOn, daysPosition: daysPosition
        )
    }

    private func getDateFromDefault(months: Int) -> Date {
        TestDateFactory.createTestDate(byAddingMonths: months, to: TestDateFactory.defaultDate)
    }

    private func getDateFromDefault(hours: Int) -> Date {
        TestDateFactory.createTestDate(byAddingHours: hours, to: TestDateFactory.defaultDate)
    }

    private func getDateFromDefault(minutes: Int) -> Date {
        TestDateFactory.createTestDate(byAddingMinutes: minutes, to: TestDateFactory.defaultDate)
    }

    private func getDateFromDefault(seconds: Int) -> Date {
        TestDateFactory.createTestDate(byAddingMinutes: seconds, to: TestDateFactory.defaultDate)
    }

    private func getOneHourAgo(now: NowProtocol?=nil) -> Date {
        let now = now ?? MockNow()
        return TestDateFactory.createTestDate(byAddingHours: -1, to: now.now)
    }

    private func getOneMinuteAgo(now: NowProtocol?=nil) -> Date {
        let now = now ?? MockNow()
        return TestDateFactory.createTestDate(byAddingMinutes: -1, to: now.now)
    }

    private func getFiveMinutesAgo(now: NowProtocol?=nil) -> Date {
        let now = now ?? MockNow()
        return TestDateFactory.createTestDate(byAddingMinutes: -5, to: now.now)
    }

    private func getFiveMinutesFromNow(now: NowProtocol?=nil) -> Date {
        let now = now ?? MockNow()
        return TestDateFactory.createTestDate(byAddingMinutes: 5, to: now.now)
    }

    private func getTwentyMinutesFromNow(now: NowProtocol?=nil) -> Date {
        let now = now ?? MockNow()
        return TestDateFactory.createTestDate(byAddingMinutes: 20, to: now.now)
    }

    private func getOneSecondAgo(now: NowProtocol?=nil) -> Date {
        let now = now ?? MockNow()
        return TestDateFactory.createTestDate(byAddingSeconds: -1, to: now.now)
    }

    private func assertDueTodayAtTimeOne(pill: Pill, now: NowProtocol?=nil) {
        assertDue(pill: pill, timeIndexExpected: 0, days: 0, now: now)
    }

    private func assertDueTodayAtTimeTwo(pill: Pill, now: NowProtocol?=nil) {
        assertDue(pill: pill, timeIndexExpected: 1, days: 0, now: now)
    }

    private func assertDueTodayAtTimeThree(pill: Pill, now: NowProtocol?=nil) {
        assertDue(pill: pill, timeIndexExpected: 2, days: 0, now: now)
    }

    private func assertDueTomorrowAtTimeOne(pill: Pill, now: NowProtocol?=nil) {
        assertDue(pill: pill, timeIndexExpected: 0, days: 1, now: now)
    }

    private func assertDueTomorrowAtTimeTwo(pill: Pill, now: NowProtocol?=nil) {
        assertDue(pill: pill, timeIndexExpected: 1, days: 1, now: now)
    }

    private func assertDueTwoDaysFromNowAtTimeOne(pill: Pill, now: NowProtocol?=nil) {
        assertDue(pill: pill, timeIndexExpected: 0, days: 2, now: now)
    }

    private func assertDue(
        pill: Pill, timeIndexExpected: Index, days: Double=0.0, date: Date?=nil, now: NowProtocol?=nil
    ) {
        // Note: Either use days or date param but not both.
        let now = now ?? MockNow()
        guard timeIndexExpected < pill.timesaday else {
            XCTFail("Was given an expected time index out-of-bounds")
            return
        }
        guard let actual = pill.due else {
            XCTFail("actual is nil")
            return
        }
        let equalTimeIndex = tryGetEqualTime(times: pill.times, actual: actual)
        if equalTimeIndex == -1 {
            XCTFail("Pill due time is not one of the pill's times.")
            return
        }

        let expectedTime = pill.times[timeIndexExpected]

        guard equalTimeIndex == timeIndexExpected else {
            let formattedActualTime = PDDateFormatter.formatTime(actual)
            let actualMessage = "Actual: T@\(equalTimeIndex + 1) (\(formattedActualTime))"
            let formattedExpectedTime = PDDateFormatter.formatTime(expectedTime)
            let expectedMessage = "Expected: T@\(timeIndexExpected + 1) (\(formattedExpectedTime))"
            XCTFail("\(expectedMessage) != \(actualMessage)")
            return
        }

        var expected = Date()
        if let date = date {
            // Use date to set date.
            expected = TestDateFactory.createTestDate(on: date, at: expectedTime)
        } else {
            // Use days to add days to get date.
            expected = createDueTime(expectedTime, days: Int(days), now: now)
        }
        PDAssertEquiv(expected, actual)
    }

    private func tryGetEqualTime(times: [Time], actual: Date) -> Index {
        var index = 0
        for time in times {
            if sameTime(time, actual) {
                return index
            }
            index += 1
        }
        return -1
    }

    private func assertPosition(
        actual: Pill,
        expectedPosition: Int,
        expectedOnPosition: Bool,
        line: UInt = #line
    ) {
        guard let actualPosition = actual.expirationInterval.xDaysPosition else {
            XCTFail("position is nil")
            return
        }
        guard let actualIsOn = actual.expirationInterval.xDaysIsOn else {
            XCTFail("isOn is nil")
            return
        }
        XCTAssertEqual(expectedPosition, actualPosition)
        XCTAssertEqual(expectedOnPosition, actualIsOn)
    }
}
