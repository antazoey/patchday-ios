//
//  Pill.swift
//  PatchData
//
//  Created by Juliya Smith on 9/2/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class Pill: Swallowable {

	private var pillData: PillStruct  // Stored data
	private lazy var log = PDLog<Pill>()

	public init(pillData: PillStruct) {
		self.pillData = pillData
		if pillData.attributes.name == nil {
			self.pillData.attributes.name = PillStrings.NewPill
		}
		if let timesaday = pillData.attributes.timesaday {
			if timesaday <= 0 {
				self.pillData.attributes.timesaday = 1
			}
		} else {
			self.pillData.attributes.timesaday = 1
		}
	}

	public var id: UUID {
		get { pillData.id }
		set { pillData.id = newValue }
	}

	public var attributes: PillAttributes {
		PillAttributes(
            name: name,
            expirationInterval: pillData.attributes.expirationInterval ?? DefaultPillAttributes.expirationInterval.rawValue,
			timesaday: timesaday,
			time1: time1,
			time2: time2,
			notify: notify,
			timesTakenToday: timesTakenToday,
			lastTaken: lastTaken
		)
	}

	public var name: String {
		get { pillData.attributes.name ?? PillStrings.NewPill }
		set { pillData.attributes.name = newValue }
	}

    /// Human readable expiration interval derived from the stored property. Correlates to `PillStrings.Intervals` and `PillExpirationInterval`.
    public var expirationInterval: String {
        get {
            if let storedInterval = pillData.attributes.expirationInterval,
                let interval = PillExpirationInterval(rawValue: storedInterval) {
                return PillStrings.Intervals.getStringFromInterval(interval)
            }
            let interval = DefaultPillAttributes.expirationInterval
            return PillStrings.Intervals.getStringFromInterval(interval)
        }
        set {
            let interval = PillStrings.Intervals.getIntervalFromString(newValue)
                ?? PillExpirationInterval(rawValue: newValue)
            if let interval = interval {
                pillData.attributes.expirationInterval = interval.rawValue
            }
        }
    }

	public var time1: Date {
		get { pillData.attributes.time1 as Date? ?? DateFactory.createDefaultDate() }
		set { pillData.attributes.time1 = newValue }
	}

	public var time2: Date {
		get {
			guard let t2 = pillData.attributes.time2 else {
				return DateFactory.createDefaultDate()
			}
			return t2 as Date
		} set {
			if let time1 = pillData.attributes.time1 as Date? {
				if newValue < time1 {
					pillData.attributes.time2 = time1
					pillData.attributes.time1 = newValue
				} else {
					pillData.attributes.time2 = newValue
				}
			}
		}
	}

	public var notify: Bool {
		get { pillData.attributes.notify ?? false }
		set { pillData.attributes.notify = newValue }
	}

	public var timesaday: Int {
		get {
			if let timesaday = pillData.attributes.timesaday, timesaday > 0 {
				return timesaday
			}
			return DefaultPillAttributes.timesaday
		}
		set {
			if newValue >= 1 {
				pillData.attributes.timesaday = newValue
				if newValue < 2 {
					pillData.attributes.time2 = nil
				}
			}
		}
	}

	public var timesTakenToday: Int {
		pillData.attributes.timesTakenToday ?? 0
	}

	public var lastTaken: Date? {
		get { pillData.attributes.lastTaken }
		set { pillData.attributes.lastTaken = newValue }
	}

    public var due: Date? {
		// Schedule doesn't start until taken at least once.
		guard let lastTaken = lastTaken, !lastTaken.isDefault() else { return nil }
        switch expirationInterval {
			case PillStrings.Intervals.EveryDay: return regularNextDueTime
			case PillStrings.Intervals.EveryOtherDay: return dueDateForEveryOtherDay
			case PillStrings.Intervals.FirstTenDays: return dueDateForFirstTenDays
			case PillStrings.Intervals.LastTenDays: return dueDateForLastTenDays()
			case PillStrings.Intervals.FirstTwentyDays: return dueDateForFirstTwentyDays()
			case PillStrings.Intervals.LastTwentyDays: return dueDateForLastTwentyDays()
			default: return nil
        }
    }

	public var isDue: Bool {
		guard let dueDate = due else { return false }
		return Date() > dueDate
	}

	public var isNew: Bool { pillData.attributes.lastTaken == nil }

	public var isDone: Bool {
		timesTakenToday >= timesaday && lastTaken != nil
	}

	public func set(attributes: PillAttributes) {
		name = attributes.name ?? name
		timesaday = attributes.timesaday ?? timesaday
		time1 = attributes.time1 ?? time1
		time2 = attributes.time2 ?? time2
		notify = attributes.notify ?? notify
		lastTaken = attributes.lastTaken ?? lastTaken
        expirationInterval = attributes.expirationInterval ?? expirationInterval
	}

	public func swallow() {
        guard timesTakenToday < timesaday || lastTaken == nil else { return }
        let currentTimesTaken = pillData.attributes.timesTakenToday ?? 0
        pillData.attributes.timesTakenToday = currentTimesTaken + 1
        lastTaken = Date()
	}

	public func awaken() {
		if timesTakenToday > 0,
			let lastDate = lastTaken as Date?,
			!lastDate.isInToday() {

			pillData.attributes.timesTakenToday = 0
		}
	}

	private var pillDueDateFinderParams: PillDueDateFinderParams {
		PillDueDateFinderParams(timesTakenToday, timesaday, times)
	}

	private var times: [Time] {
		var _times: [Time] = []
		if let t1 = pillData.attributes.time1 {
			_times.append(t1 as Time)
		}
		if let t2 = pillData.attributes.time2 {
			_times.append(t2 as Time)
		}
		return _times
	}

	private func ensureTimeOrdering() {
		if self.time2 < time1 || self.time1 > time2 {
			self.time2 = time1
		}
	}

	private func addMissingTimes() {
		for i in times.count..<timesaday {
			addMissingTime(timeIndex: i)
		}
	}

    private var regularNextDueTime: Date? {
        if timesTakenToday == 0 {
            return DateFactory.createTodayDate(at: time1)
        } else if timesTakenToday == 1 && timesaday == 2 {
            return DateFactory.createTodayDate(at: time2)
        } else {
            return tomorrowAtTimeOne
        }
    }

    private var dueDateForEveryOtherDay: Date? {
        guard let lastTaken = lastTaken else { return regularNextDueTime }
        if lastTaken.isInYesterday() {
            return tomorrowAtTimeOne
        } else if isDone {
            return getTimeOne(daysFromNow: 2)
        }
        return regularNextDueTime
    }

    private var tomorrowAtTimeOne: Date? {
        getTimeOne(daysFromNow: 1)
    }

    private func getTimeOne(daysFromNow: Int) -> Date? {
        DateFactory.createDate(at: time1, daysFromToday: daysFromNow)
    }

    private var dueDateForFirstTenDays: Date? {
        dueDate(begin: 10)
    }

    private func dueDate(begin: Int) -> Date? {
        guard let lastTaken = lastTaken else { return regularNextDueTime }
        let dayNumberInMonth = lastTaken.dayNumberInMonth()
        if dayNumberInMonth < 10 || (dayNumberInMonth == 10 && !isDone) {
            return regularNextDueTime
        }
        return beginningOfNextMonthAtTimeOne(lastTaken: lastTaken)
    }

    private func beginningOfNextMonthAtTimeOne(lastTaken: Date) -> Date? {
        if let nextTime = regularNextDueTime,
            let nextMonth = Calendar.current.date(bySetting: .day, value: 1, of: lastTaken) {
            return DateFactory.createDate(on: nextMonth, at: nextTime)
        }
        return nil
    }

    private func endOfNextMonthAtTimeOne(lastTaken: Date, days: Int) -> Date? {
        guard let daysInMonth = lastTaken.daysInMonth() else { return nil }
        let begin = daysInMonth - days
        if let nextTime = regularNextDueTime,
            let month = Calendar.current.date(bySetting: .day, value: begin, of: lastTaken) {
            return DateFactory.createDate(on: month, at: nextTime)
        }
        return nil
    }

    private func dueDateForLastTenDays() -> Date? {
        dueDate(end: 10)
    }

    private func dueDate(end: Int) -> Date? {
        guard let lastTaken = lastTaken else { return regularNextDueTime }
        guard let daysInMonth = lastTaken.daysInMonth() else { return regularNextDueTime }
        let dayNumber = lastTaken.dayNumberInMonth()
        let limit = daysInMonth - end

        if dayNumber == daysInMonth && isDone || dayNumber <= limit {
            return endOfNextMonthAtTimeOne(lastTaken: lastTaken, days: end)
        }
        return regularNextDueTime
    }

    private func dueDateForFirstTwentyDays() -> Date? {
        dueDate(begin: 10)
    }

    private func dueDateForLastTwentyDays() -> Date? {
        dueDate(end: 20)
    }

	private func addMissingTime(timeIndex: Index) {
		if timeIndex == 0 {
			time1 = Date()
		} else if timeIndex == 1 {
			addMissingTimeTwo()
		}
	}

	private func addMissingTimeTwo() {
		if let time1 = pillData.attributes.time1 {
			pillData.attributes.time2 = Time(timeInterval: 1000, since: time1)
		} else {
			pillData.attributes.time2 = Time()
		}
	}
}
