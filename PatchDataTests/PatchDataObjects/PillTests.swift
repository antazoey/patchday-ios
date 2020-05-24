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

	let testId = UUID()

	func createPill(_ attributes: PillAttributes) -> Pill {
		Pill(pillData: PillStruct(UUID(), attributes))
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
			minute: calendar.component(.minute, from: time)
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
		attrs.time1 = calendar.date(from: components)
		attrs.time2 = calendar.date(from: components)
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

	func testTimeOne_whenNilInAttributes_returnsDefaultDate() {
		var attrs = PillAttributes()
		attrs.time1 = nil
		let pill = createPill(attrs)
		let expected = Date(timeIntervalSince1970: 0)
		let actual = pill.time1
		XCTAssertEqual(expected, actual)
	}

	func testTimeOne_returnsTimeFromAttributes() {
		var attrs = PillAttributes()
		attrs.time1 = Date()
		let pill = createPill(attrs)
		let expected = attrs.time1
		let actual = pill.time1
		XCTAssertEqual(expected, actual)
	}

	func testTimeTwo_whenNilInAttributes_returnsDefaultDate() {
		var attrs = PillAttributes()
		attrs.time1 = Date()
		attrs.time2 = nil
		let pill = createPill(attrs)
		let expected = Date(timeIntervalSince1970: 0)
		let actual = pill.time2
		XCTAssertEqual(expected, actual)
	}

	public func testTimeTwo_returnsTimeFromAttributes() {
		var attrs = PillAttributes()
		attrs.time1 = Date()
		attrs.time2 = Date()
		let pill = createPill(attrs)
		let expected = attrs.time2
		let actual = pill.time2
		XCTAssertEqual(expected, actual)
	}

	func testSetTimeTwoSet_whenGivenDefaultValue_doesNotSet() {
		var attrs = PillAttributes()
		attrs.time1 = Date()
		attrs.time2 = Date()
		attrs.timesaday = 2
		let pill = createPill(attrs)
		pill.time2 = DateFactory.createDefaultDate()
		let expected = attrs.time2
		let actual = pill.time2
		XCTAssertEqual(expected, actual)
	}

	func testSetTimeTwo_whenTimesadayIsOne_doesNotSet() {
		var attrs = PillAttributes()
		attrs.timesaday = 1
		attrs.time1 = Date(timeInterval: 1000, since: Date())
		attrs.time2 = Date()
		let pill = createPill(attrs)
		pill.time2 = Date()
		let expected = attrs.time2
		let actual = pill.time2
		XCTAssertEqual(expected, actual)
	}

	func testSetTimeTwo_whenTimeOneIsDefault_doesNotSetAndReturnsDefaultDate() {
		var attrs = PillAttributes()
		attrs.timesaday = 2
		attrs.time1 = DateFactory.createDefaultDate()
		attrs.time2 = Date()
		let pill = createPill(attrs)
		pill.time2 = Date()
		XCTAssertEqual(DateFactory.createDefaultDate(), pill.time2)
	}

	func testSetTimeTwo_whenTimeOneIsNil_doesNotSetAndReturnsDefaultDate() {
		var attrs = PillAttributes()
		attrs.timesaday = 2
		attrs.time1 = nil
		attrs.time2 = Date()
		let pill = createPill(attrs)
		pill.time2 = Date()
		XCTAssertEqual(DateFactory.createDefaultDate(), pill.time2)
	}

	func testSetTimeTwo_whenTimeOneIsGreater_setsPillOneToNewTime() {
		var attrs = PillAttributes()
		attrs.timesaday = 2
		attrs.time1 = Date(timeInterval: 1000, since: Date())
		let pill = createPill(attrs)
		let expected = Date()
		pill.time2 = expected
		XCTAssertEqual(expected, pill.time1)
	}

	func testSetTimeTwo_whenTimeOneIsGreater_setsTimeTwoToPillTimeOne() {
		var attrs = PillAttributes()
		attrs.timesaday = 2
		let expected = Date(timeInterval: 1000, since: Date())
		attrs.time1 = expected
		let pill = createPill(attrs)
		pill.time2 = Date()
		XCTAssertEqual(expected, pill.time2)
	}

	func testNotify_whenNilInAttributes_returnsFalse() {
		var attrs = PillAttributes()
		attrs.notify = nil
		let pill = createPill(attrs)
		XCTAssertFalse(pill.notify)
	}

	func testTimesaday_whenNilInAttributes_returnsDefaultTimesaday() {
		var attrs = PillAttributes()
		attrs.notify = nil
		let pill = createPill(attrs)
		let expected = DefaultPillAttributes.timesaday
		let actual = pill.timesaday
		XCTAssertEqual(expected, actual)
	}

	func testSetTimesaday_whenNewValueLessThanOne_doesNotSet() {
		var attrs = PillAttributes()
		attrs.timesaday = 3
		let pill = createPill(attrs)
		pill.timesaday = 0
		let expected = 3
		let actual = pill.timesaday
		XCTAssertEqual(expected, actual)
	}

	public func testSetTimesaday_whenNewValuePositive_sets() {
		let pill = createPill(PillAttributes())
		pill.timesaday = 16
		let expected = 16
		let actual = pill.timesaday
		XCTAssertEqual(expected, actual)
	}

	func testSetTimesaday_whenNewValueEqualToOne_clearsTimeTwo() {
		var attrs = PillAttributes()
		attrs.time2 = Date()
		let pill = createPill(attrs)
		pill.timesaday = 1
		let expected = Date(timeIntervalSince1970: 0)
		let actual = pill.time2
		XCTAssertEqual(expected, actual)
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
		attrs.expirationInterval = PillExpirationInterval.EveryDay.rawValue
		attrs.time1 = DateFactory.createDate(byAddingSeconds: 61, to: now)!
		attrs.time2 = nil
		attrs.lastTaken = DateFactory.createDate(byAddingHours: -23, to: now)!
		attrs.notify = true
		attrs.timesaday = 1
		attrs.timesTakenToday = 0
		let pill = createPill(attrs)
		let expected = createDueTime(pill.time1, days: 0)
		let actual = pill.due
		XCTAssertEqual(expected, actual)
	}

	func testDue_whenOnceEveryDayAndTakenOnceToday_returnsTomorrowAtTimeOne() {
		var attrs = PillAttributes()
		attrs.lastTaken = Date(timeIntervalSinceNow: -1000)
        attrs.expirationInterval = PillExpirationInterval.EveryDay.rawValue
		attrs.timesTakenToday = 1
		attrs.timesaday = 1
		attrs.time1 = Date(timeIntervalSinceNow: -234233234352)
		let pill = createPill(attrs)
		let expected = createDueTime(pill.time1, days: 1) // Tomorrow at time one
		let actual = pill.due
		XCTAssertEqual(expected, actual)
	}

	func testDue_whenTwiceEveryDayAndTakenOnceToday_returnsTodayAtTimeTwo() {
		var attrs = PillAttributes()
		attrs.lastTaken = Date(timeIntervalSinceNow: -1000)
        attrs.expirationInterval = PillExpirationInterval.EveryDay.rawValue
		attrs.timesTakenToday = 1
		attrs.timesaday = 2
		attrs.time2 = Date(timeIntervalSinceNow: -234233234352)
		let pill = createPill(attrs)
		let expected = createDueTime(pill.time2, days: 0) // Today at time two
		let actual = pill.due
		XCTAssertEqual(expected, actual)
	}

	func testDue_whenTwiceEveryDayAndTakenTwiceToday_returnsTomorrowATimeOne() {
		var attrs = PillAttributes()
		attrs.lastTaken = Date(timeIntervalSinceNow: -1000)
        attrs.expirationInterval = PillExpirationInterval.EveryDay.rawValue
		attrs.timesTakenToday = 2
		attrs.timesaday = 2
		attrs.time2 = Date(timeIntervalSinceNow: -234233234352)
		let pill = createPill(attrs)
		let expected = createDueTime(pill.time1, days: 1) // Tomorrow at time one
		let actual = pill.due
		XCTAssertEqual(expected, actual)
	}

    func testDue_whenEveryOtherDayAndTakenTwoDaysAgo_returnsTodayAtTimeOne() {
        var attrs = PillAttributes()
        attrs.lastTaken = DateFactory.createDate(daysFromNow: -2)
        attrs.expirationInterval = PillExpirationInterval.EveryOtherDay.rawValue
        attrs.timesTakenToday = 0
        attrs.time1 = Date(timeIntervalSinceNow: -234233234352) // Making it an old date makes the test better
        let pill = createPill(attrs)
        let expected = createDueTime(pill.time1, days: 0)
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenOnceEveryOtherDayAndTakenOnceToday_returnsTwoDaysFromNowAtTimeOne() {
        var attrs = PillAttributes()
        attrs.lastTaken = DateFactory.createDate(daysFromNow: 0)
        attrs.expirationInterval = PillExpirationInterval.EveryOtherDay.rawValue
        attrs.timesTakenToday = 1
        attrs.timesaday = 1
        attrs.time1 = Date(timeIntervalSinceNow: -234233234352)
        let pill = createPill(attrs)
        let expected = createDueTime(pill.time1, days: 2)
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTwiceEveryOtherDayAndTakenOnceToday_returnsTodayAtTimeTwo() {
        var attrs = PillAttributes()
        attrs.lastTaken = DateFactory.createDate(daysFromNow: 0)
        attrs.expirationInterval = PillExpirationInterval.EveryOtherDay.rawValue
        attrs.timesTakenToday = 1
        attrs.timesaday = 2
        attrs.time2 = Date(timeIntervalSinceNow: -234233234352)
        let pill = createPill(attrs)
        let expected = createDueTime(pill.time2, days: 0) // Today at time two
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTwiceEveryOtherDayAndTakenTwiceToday_returnsTwosDaysFromNowAtTimeOne() {
        var attrs = PillAttributes()
        attrs.lastTaken = DateFactory.createDate(daysFromNow: 0)
        attrs.expirationInterval = PillExpirationInterval.EveryOtherDay.rawValue
        attrs.timesTakenToday = 2
        attrs.timesaday = 2
        attrs.time2 = Date(timeIntervalSinceNow: -234233234352)
        let pill = createPill(attrs)
        let expected = createDueTime(pill.time1, days: 2)
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenEveryOtherDayAndTakenYesterday_returnsTomorrowAtTimeOne() {
        var attrs = PillAttributes()
        attrs.lastTaken = DateFactory.createDate(daysFromNow: -1)
        attrs.expirationInterval = PillExpirationInterval.EveryOtherDay.rawValue
        attrs.timesTakenToday = 0
        attrs.timesaday = 1
        attrs.time1 = Date(timeIntervalSinceNow: -234233234352)
        let pill = createPill(attrs)
        let expected = createDueTime(pill.time1, days: 1)
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenFirstTenDaysAndFinishedOnTenthDay_returnsFirstOfNextMonthAtTimeOne() {
        var attrs = PillAttributes()
        let cal = Calendar.current
        attrs.lastTaken = cal.date(bySetting: .day, value: 10, of: Date())
        attrs.expirationInterval = PillExpirationInterval.FirstTenDays.rawValue
        attrs.timesTakenToday = 1
        attrs.timesaday = 1
        attrs.time1 = Date()
        let pill = createPill(attrs)
        let date = cal.date(bySetting: .day, value: 1, of: attrs.lastTaken!)!
        let expected = DateFactory.createDate(on: date, at: attrs.time1!)!
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenEveryFirstTenDaysAndIsDuringThoseTenDays_returnsExpectedDate() {
        var attrs = PillAttributes()
        attrs.timesaday = 1
        attrs.timesTakenToday = 0
        attrs.lastTaken = DateFactory.createDate(daysFromNow: -1)
        attrs.time1 = Date()
        let pill = createPill(attrs)
        let actual = pill.due
        let expected = DateFactory.createDate(on: Date(), at: attrs.time1!)
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenFirstTenDaysAndFinishedOnTwenthiethDay_returnsFirstOfNextMonthAtTimeOne() {
        var attrs = PillAttributes()
        let cal = Calendar.current
        attrs.lastTaken = cal.date(bySetting: .day, value: 20, of: Date())
        attrs.expirationInterval = PillExpirationInterval.FirstTwentyDays.rawValue
        attrs.timesTakenToday = 1
        attrs.timesaday = 1
        attrs.time1 = Date()
        let pill = createPill(attrs)
        let date = cal.date(bySetting: .day, value: 1, of: attrs.lastTaken!)!
        let expected = DateFactory.createDate(on: date, at: attrs.time1!)!
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenTakenLastTenDaysAndFinishedOnLastDayOfMonth_returnsExpectedDate() {
        var attrs = PillAttributes()
        let cal = Calendar.current
        let last = Date().daysInMonth()!
        attrs.lastTaken = cal.date(bySetting: .day, value: last, of: Date())
        attrs.expirationInterval = PillExpirationInterval.LastTenDays.rawValue
        attrs.timesTakenToday = 1
        attrs.timesaday = 1
        attrs.time1 = Date()
        let day = attrs.lastTaken!.daysInMonth()! - 10
        let pill = createPill(attrs)
        let date = cal.date(bySetting: .day, value: day, of: attrs.lastTaken!)!
        let expected = DateFactory.createDate(on: date, at: attrs.time1!)!
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

    func testDue_whenLastTakenTwentyDaysAndFinishedOnLastDayOfMonth_returnsExpectedDate() {
        var attrs = PillAttributes()
        let cal = Calendar.current
        let last = Date().daysInMonth()!
        attrs.lastTaken = cal.date(bySetting: .day, value: last, of: Date())
        attrs.expirationInterval = PillExpirationInterval.LastTwentyDays.rawValue
        attrs.timesTakenToday = 1
        attrs.timesaday = 1
        attrs.time1 = Date()
        let day = attrs.lastTaken!.daysInMonth()! - 20
        let pill = createPill(attrs)
        let date = cal.date(bySetting: .day, value: day, of: attrs.lastTaken!)!
        let expected = DateFactory.createDate(on: date, at: attrs.time1!)!
        let actual = pill.due
        XCTAssertEqual(expected, actual)
    }

	func testIsDue_whenTimesTakenTodayEqualsTimesday_returnsFalse() {
		var attrs = createPillAttributes(minutesFromNow: -5)
		attrs.lastTaken = Date(timeIntervalSinceNow: -1000)
		attrs.timesTakenToday = 2
		attrs.timesaday = 2
		let pill = createPill(attrs)
		XCTAssertFalse(pill.isDue)
	}

	func testIsDue_whenPillNotYetTakenAndTimeOneIsPast_returnsTrue() {
		var attrs = createPillAttributes(minutesFromNow: -5)
		attrs.lastTaken = Date(timeIntervalSinceNow: -1000)
		attrs.timesTakenToday = 0
		attrs.timesaday = 2
		let pill = createPill(attrs)
		XCTAssertTrue(pill.isDue)
	}

	func testIsDue_whenPillTakenTodayAndTimesadayIsOne_returnsFalse() {
		var attrs = createPillAttributes(minutesFromNow: -5)
		attrs.timesTakenToday = 1
		attrs.timesaday = 1
		let pill = createPill(attrs)
		XCTAssertFalse(pill.isDue)
	}

	func testIsDue_whenPillTakenOnceAndTimesadayIsTwoAndTimesTwoIsNotPast_returnsFalse() {
		var attrs = createPillAttributes(minutesFromNow: 5)
		attrs.timesTakenToday = 1
		attrs.timesaday = 2
		let pill = createPill(attrs)
		XCTAssertFalse(pill.isDue)
	}

	func testIsDue_whenPillTakenOnceAndTimesadayIsTwoAndTimesTwoIsPast_returnsTrue() {
		var attrs = createPillAttributes(minutesFromNow: -5)
		attrs.lastTaken = Date(timeIntervalSinceNow: -1000)
		attrs.timesTakenToday = 1
		attrs.timesaday = 2
		let pill = createPill(attrs)
		XCTAssert(pill.isDue)
	}

	func testIsDue_whenPillTakenTwiceTodayAndTimesadayIsTwo_returnsFalse() {
		var attrs = createPillAttributes(minutesFromNow: -5)
		attrs.timesTakenToday = 2
		attrs.timesaday = 2
		let pill = createPill(attrs)
		XCTAssertFalse(pill.isDue)
	}

	func testIsDue_whenNeverTakenByWayOfNil_returnsFalse() {
		var attrs = createPillAttributes(minutesFromNow: -5)
		attrs.lastTaken = nil
		attrs.time1 = Date()
		attrs.timesaday = 1
		attrs.timesTakenToday = 0
		let pill = createPill(attrs)
		XCTAssertFalse(pill.isDue)
	}

	func testIsDue_whenNeverTakenByWayOfDefault_returnsFalse() {
		var attrs = createPillAttributes(minutesFromNow: -5)
		attrs.lastTaken = DateFactory.createDefaultDate()
		attrs.time1 = Date()
		attrs.timesaday = 1
		attrs.timesTakenToday = 0
		let pill = createPill(attrs)
		XCTAssertFalse(pill.isDue)
	}

	func testIsNew_whenLastTakenIsNil_returnsTrue() {
		let attrs = PillAttributes()
		let pill = createPill(attrs)
		XCTAssertTrue(pill.isNew)
	}

	func testIsNew_whenLastTakenHasValue_returnsFalse() {
		var attrs = PillAttributes()
		attrs.lastTaken = Date()
		let pill = createPill(attrs)
		XCTAssertFalse(pill.isNew)
	}

	func testIsDone_whenTimesTakenIsLessThanTimesaday_returnsFalse() {
		var attrs = PillAttributes()
		attrs.timesaday = 2
		attrs.timesTakenToday = 1
		attrs.lastTaken = Date()
		let pill = createPill(attrs)
		XCTAssertFalse(pill.isDone)
	}

	func testIsDone_whenTimesTakenIsEqualToTimesaday_returnsTrue() {
		var attrs = PillAttributes()
		attrs.timesaday = 2
		attrs.timesTakenToday = 2
		attrs.lastTaken = Date()
		let pill = createPill(attrs)
		XCTAssertTrue(pill.isDone)
	}

	func testIsDone_whenTimesTakenIsGreaterThanTimesaday_returnsTrue() {
		var attrs = PillAttributes()
		attrs.timesaday = 2
		attrs.timesTakenToday = 3
		attrs.lastTaken = Date()
		let pill = createPill(attrs)
		XCTAssertTrue(pill.isDone)
	}

	func testIsDone_whenLastTakenIsNil_returnsFalse() {
		var attrs = PillAttributes()
		attrs.timesaday = 2
		attrs.timesTakenToday = 3
		attrs.lastTaken = nil
		let pill = createPill(attrs)
		XCTAssertFalse(pill.isDone)
	}

	func testSet_setsGivenAttributes() {
		let newName = "New Pill Name"
		let newTime1 = Date()
		let newTime2 = Date()
		let newTimesaday = 6
		let newNotify = true
		let newLastTaken = Date()
        let newExpiration = PillStrings.Intervals.FirstTenDays
		let pill = createPill(PillAttributes())
		var newAttrs = PillAttributes()
		newAttrs.name = newName
		newAttrs.time1 = newTime1
		newAttrs.time2 = newTime2
		newAttrs.timesaday = newTimesaday
		newAttrs.notify = newNotify
		newAttrs.lastTaken = newLastTaken
        newAttrs.expirationInterval = newExpiration
		pill.set(attributes: newAttrs)
		XCTAssert(pill.name == newName
				&& pill.time1 == newTime1
				&& pill.time2 == newTime2
				&& pill.timesaday == newTimesaday
				&& pill.notify == newNotify
				&& pill.lastTaken == newLastTaken
                && pill.expirationInterval == PillStrings.Intervals.FirstTenDays
		)
	}

	func testSwallow_whenTimesTakenTodayEqualToTimesaday_doesNotIncreaseTimesTakenToday() {
		var attrs = PillAttributes()
		attrs.timesaday = 1
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
		attrs.timesaday = 1
		attrs.timesTakenToday = 1
		let pill = createPill(attrs)
		pill.swallow()
		XCTAssertEqual(originalLastTaken, pill.lastTaken)
	}

	func testSwallow_whenTimesTakenTodayIsLessThanTimesaday_increasesTimesTakenToday() {
		var attrs = PillAttributes()
		attrs.timesaday = 1
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
		attrs.timesaday = 1
		attrs.timesTakenToday = 0
		let pill = createPill(attrs)
		pill.swallow()
		XCTAssert(originalLastTaken < pill.lastTaken! && pill.lastTaken! < Date())
	}

	func testSwallow_whenLastTakenIsNil_increasesTimesTakenToday() {
		var attrs = PillAttributes()
		attrs.timesaday = 1
		attrs.timesTakenToday = 1
		attrs.lastTaken = nil
		let pill = createPill(attrs)
		pill.swallow()
		XCTAssertEqual(2, pill.timesTakenToday)
	}

	func testSwallow_whenLastTakenIsNil_stampsLastTaken() {
		var attrs = PillAttributes()
		attrs.lastTaken = nil
		attrs.timesaday = 1
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
