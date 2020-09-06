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
    private let now: NowProtocol

    public init(pillData: PillStruct, now: NowProtocol?=nil) {
        self.pillData = pillData
        self.now = now ?? PDNow()
        if pillData.attributes.name == nil {
            self.pillData.attributes.name = PillStrings.NewPill
        }
    }

    public var id: UUID {
        get { pillData.id }
        set { pillData.id = newValue }
    }

    public var attributes: PillAttributes {
        let defaultInterval = DefaultPillAttributes.expirationInterval.rawValue
        return PillAttributes(
            name: name,
            expirationInterval: pillData.attributes.expirationInterval ?? defaultInterval,
            times: PDDateFormatter.convertDatesToCommaSeparatedString(times),
            notify: notify,
            timesTakenToday: timesTakenToday,
            lastTaken: lastTaken
        )
    }

    public var name: String {
        get { pillData.attributes.name ?? PillStrings.NewPill }
        set { pillData.attributes.name = newValue }
    }

    /// Human readable expiration interval derived from the stored property.
    /// Correlates to `PillStrings.Intervals` and `PillExpirationInterval`.
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

    public var times: [Time] {
        guard let timeString = pillData.attributes.times else { return [] }
        return DateFactory.createTimesFromCommaSeparatedString(timeString)
    }

    public func appendTime(_ time: Time) {
        var newTimes = times
        newTimes.append(time)
        newTimes = newTimes.filter { $0 != DateFactory.createDefaultDate() }
        let timeString = PDDateFormatter.convertDatesToCommaSeparatedString(newTimes)
        pillData.attributes.times = timeString
    }

    public var notify: Bool {
        get { pillData.attributes.notify ?? DefaultPillAttributes.notify }
        set { pillData.attributes.notify = newValue }
    }

    public var timesaday: Int { times.count }

    public var timesTakenToday: Int {
        pillData.attributes.timesTakenToday ?? DefaultPillAttributes.timesTakenToday
    }

    public var lastTaken: Date? {
        get { pillData.attributes.lastTaken }
        set { pillData.attributes.lastTaken = newValue }
    }

    public var due: Date? {
        // Schedule doesn't start until taken at least once.
        guard let lastTaken = lastTaken, !lastTaken.isDefault() else { return nil }
        switch expirationInterval {
            case PillStrings.Intervals.EveryDay: return nextDueTimeForEveryDaySchedule
            case PillStrings.Intervals.EveryOtherDay: return dueDateForEveryOtherDay
            case PillStrings.Intervals.FirstTenDays: return dueDateForFirstTenDays
            case PillStrings.Intervals.LastTenDays: return dueDateForLastTenDays
            case PillStrings.Intervals.FirstTwentyDays: return dueDateForFirstTwentyDays
            case PillStrings.Intervals.LastTwentyDays: return dueDateForLastTwentyDays
            default: return nil
        }
    }

    public var isDue: Bool {
        guard timesTakenToday < timesaday else { return false }
        guard let dueDate = due else { return false }
        return now.now > dueDate
    }

    public var isNew: Bool {
        pillData.attributes.lastTaken == nil && !hasName
    }

    public var hasName: Bool {
        pillData.attributes.name != PillStrings.NewPill && pillData.attributes.name != ""
    }

    public var isDone: Bool {
        timesTakenToday >= timesaday && lastTaken != nil
    }

    public func set(attributes: PillAttributes) {
        name = attributes.name ?? name
        notify = attributes.notify ?? notify
        lastTaken = attributes.lastTaken ?? lastTaken
        expirationInterval = attributes.expirationInterval ?? expirationInterval
        pillData.attributes.times = attributes.times ?? pillData.attributes.times
    }

    public func swallow() {
        guard timesTakenToday < timesaday || lastTaken == nil else { return }
        let currentTimesTaken = pillData.attributes.timesTakenToday ?? 0
        pillData.attributes.timesTakenToday = currentTimesTaken + 1
        lastTaken = now.now
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

    private var dueDateForEveryOtherDay: Date? {
        guard let lastTaken = lastTaken else { return nextDueTimeForEveryDaySchedule }
        if lastTaken.isInYesterday() {
            return tomorrowAtTimeOne
        } else if isDone {
            return getTimeOne(daysFromNow: 2)
        }
        return nextDueTimeForEveryDaySchedule
    }

    private var tomorrowAtTimeOne: Date? {
        getTimeOne(daysFromNow: 1)
    }

    private func getTimeOne(daysFromNow: Int) -> Date? {
        guard times.count >= 1 else { return nil }
        return DateFactory.createDate(at: times[0], daysFromToday: daysFromNow, now: now)
    }

    private func beginningOfNextMonthAtTimeOne(lastTaken: Date) -> Date? {
        if let nextTime = nextDueTimeForEveryDaySchedule,
            let nextMonth = Calendar.current.date(bySetting: .day, value: 1, of: lastTaken) {
            return DateFactory.createDate(on: nextMonth, at: nextTime)
        }
        return nil
    }

    private func endOfNextMonthAtTimeOne(lastTaken: Date, days: Int) -> Date? {
        guard let daysInMonth = lastTaken.daysInMonth() else { return nil }
        let begin = daysInMonth - days
        if let nextTime = nextDueTimeForEveryDaySchedule,
            let month = Calendar.current.date(bySetting: .day, value: begin, of: lastTaken) {
            return DateFactory.createDate(on: month, at: nextTime)
        }
        return nil
    }

    private var dueDateForFirstTenDays: Date? {
        dueDateBegin(10)
    }

    private var dueDateForFirstTwentyDays: Date? {
        dueDateBegin(20)
    }

    private func dueDateBegin(_ begin: Int) -> Date? {
        guard let lastTaken = lastTaken else { return nextDueTimeForEveryDaySchedule }
        let dayNumberInMonth = lastTaken.dayNumberInMonth()
        if dayNumberInMonth < begin || (dayNumberInMonth == begin && !isDone) {
            return nextDueTimeForEveryDaySchedule
        }
        return beginningOfNextMonthAtTimeOne(lastTaken: lastTaken)
    }

    private var dueDateForLastTenDays: Date? {
        dueDateEnd(10)
    }

    private var dueDateForLastTwentyDays: Date? {
        dueDateEnd(20)
    }

    private func dueDateEnd(_ end: Int) -> Date? {
        guard let lastTaken = lastTaken else { return nextDueTimeForEveryDaySchedule }
        guard let daysInMonth = lastTaken.daysInMonth() else {
            return nextDueTimeForEveryDaySchedule
        }
        let dayNumber = lastTaken.dayNumberInMonth()
        let limit = daysInMonth - end

        if dayNumber == daysInMonth && isDone || dayNumber <= limit {
            return endOfNextMonthAtTimeOne(lastTaken: lastTaken, days: end)
        }
        return nextDueTimeForEveryDaySchedule
    }

    private var nextDueTimeForEveryDaySchedule: Date? {
        guard timesaday <= times.count else { return nil }
        if timesTakenToday < timesaday {
            let time = times[timesTakenToday]
            return DateFactory.createTodayDate(at: time, now: self.now)
        }
        return tomorrowAtTimeOne
    }
}
