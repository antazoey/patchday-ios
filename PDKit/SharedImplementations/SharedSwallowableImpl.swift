//
// Created by Juliya Smith on 12/19/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation


public extension Swallowable {

	var times: [Time] { [time1, time2] }

	func initialize() {
		self.initialize(name: PDStrings.PlaceholderStrings.newPill)
	}

	func initialize(name: String) {
		name = name
		timesaday = 1
		time1 = NSDate()
		time2 = NSDate()
		notify = true
		timesTakenToday = 0
		id = UUID()
	}

	func getDueDate(getDueDateWhenNotEnoughTimes: () -> Date) -> Date {
		do {
			return try PillHelper.nextDueDate(nextDuePillFinderParams) ?? Date()
		} catch PillHelper.NextDueDateError.notEnoughTimes {
			return getDueDateWhenNotEnoughTimes()
		} catch {
			return Date()
		}
	}

	mutating func swallow() {
		if timesTakenToday < timesaday {
			timesTakenToday += 1
			lastTaken = Date()
		}
	}

	var due: Date { getDueDate(getDueDateWhenNotEnoughTimes: handleNotEnoughTimesError) }

	private var nextDuePillFinderParams: NextDuePillFinderParams {
		NextDuePillFinderParams(timesTakenToday: timesTakenToday, timesaday: timesaday, times: times)
	}

	private func ensureTimeOrdering() {
		if self.time2 < time1 || self.time1 > time2 {
			self.time2 = time1
		}
	}

	private func addMissingTime(timeIndex: Index) {
		if timeIndex == 0 {
			time1 = NSDate()
		} else if timeIndex == 1 {
			addMissingTimeTwo()
		}
	}

	private func addMissingTimeTwo() {
		if let time1 = moPill.time1 as Date? {
			time2 = Time(timeInterval: 1000, since: time1) as NSDate
		} else {
			time2 = Time() as NSDate
		}
	}

	private func handleNotEnoughTimesError() -> Date {
		if times.count < timesaday {
			addMissingTimes()
			return due
		}
		return Date()
	}

	private func addMissingTimes() {
		for i in times.count..<timesaday {
			addMissingTime(at: i)
		}
	}

	private func addMissingTime(at timeIndex: Index) {
		if timeIndex == 0 {
			time1 = NSDate()
		} else if timeIndex == 1 {
			addMissingTimeTwo()
		}
	}

	private func addMissingTimeTwo() {
		if let time1 = moPill.time1 as Date? {
			time2 = Time(timeInterval: 1000, since: time1) as NSDate
		} else {
			time2 = Time() as NSDate
		}
	}
}
