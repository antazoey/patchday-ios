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

	func createDueTime(_ time: Date, isToday: Bool) -> Date {
		let date = isToday ? Date() : Date(timeIntervalSinceNow: 86400)
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
		attrs.time2 = nil
		let pill = createPill(attrs)
		let expected = Date(timeIntervalSince1970: 0)
		let actual = pill.time2
		XCTAssertEqual(expected, actual)
	}

	public func testTimeTwo_returnsTimeFromAttributes() {
		var attrs = PillAttributes()
		attrs.time2 = Date()
		let pill = createPill(attrs)
		let expected = attrs.time2
		let actual = pill.time2
		XCTAssertEqual(expected, actual)
	}

	func testSetTimeTwo_whenTimeOneIsGreater_setsPillOneToNewTime() {
		var attrs = PillAttributes()
		attrs.time1 = Date(timeInterval: 1000, since: Date())
		let pill = createPill(attrs)
		let expected = Date()
		pill.time2 = expected
		XCTAssertEqual(expected, pill.time1)
	}

	func testSetTimeTwo_whenTimeOneIsGreater_setsTimeTwoToPillTimeOne() {
		var attrs = PillAttributes()
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

	func testDue_whenTimesTakenTodayEqualToZero_returnsTodayAtTimeOne() {
		var attrs = PillAttributes()
		attrs.timesTakenToday = 0
		attrs.time1 = Date(timeIntervalSinceNow: -234233234352) // Making it an old date makes the test better
		let pill = createPill(attrs)
		let expected = createDueTime(pill.time1, isToday: true)
		let actual = pill.due
		XCTAssertEqual(expected, actual)
	}

	func testDue_whenTimesTakenTodayIsOneAndTimesADayIsOne_returnsTomorrowAtTimeOne() {
		var attrs = PillAttributes()
		attrs.timesTakenToday = 1
		attrs.timesaday = 1
		attrs.time1 = Date(timeIntervalSinceNow: -234233234352)
		let pill = createPill(attrs)
		let expected = createDueTime(pill.time1, isToday: false) // Tomorrow at time one
		let actual = pill.due
		XCTAssertEqual(expected, actual)
	}

	func testDue_whenTimesTakenTodayIsOneAndTimesADayIsTwo_returnsTodayAtTimeTwo() {
		var attrs = PillAttributes()
		attrs.timesTakenToday = 1
		attrs.timesaday = 2
		attrs.time2 = Date(timeIntervalSinceNow: -234233234352)
		let pill = createPill(attrs)
		let expected = createDueTime(pill.time2, isToday: true) // Today at time two
		let actual = pill.due
		XCTAssertEqual(expected, actual)
	}

	func testDue_whenTimesTakenTodayIsTwoAndTimesADayIsTwo_returnsTomorrowATimeOne() {
		var attrs = PillAttributes()
		attrs.timesTakenToday = 2
		attrs.timesaday = 2
		attrs.time2 = Date(timeIntervalSinceNow: -234233234352)
		let pill = createPill(attrs)
		let expected = createDueTime(pill.time1, isToday: false) // Tomorrow at time one
		let actual = pill.due
		XCTAssertEqual(expected, actual)
	}

	func testIsDue_whenPillNotYetTakenAndTimeOneIsPast_returnsTrue() {
		var attrs = createPillAttributes(minutesFromNow: -5)
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
		let attrs = PillAttributes()
		let pill = createPill(attrs)
		var newAttrs = PillAttributes()
		newAttrs.name = newName
		newAttrs.time1 = newTime1
		newAttrs.time2 = newTime2
		newAttrs.timesaday = newTimesaday
		newAttrs.notify = newNotify
		newAttrs.lastTaken = newLastTaken
		pill.set(attributes: newAttrs)
		XCTAssert(pill.name == newName
				&& pill.time1 == newTime1
				&& pill.time2 == newTime2
				&& pill.timesaday == newTimesaday
				&& pill.notify == newNotify
				&& pill.lastTaken == newLastTaken
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
