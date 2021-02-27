//
//  Pill.swift
//  PatchData
//
//  Created by Juliya Smith on 9/2/19.

import Foundation
import PDKit

public class Pill: Swallowable {

    private var pillData: PillStruct  // Stored data
    private lazy var log = PDLog<Pill>()
    public var _now: NowProtocol

    private var now: Date { self._now.now }

    public init(pillData: PillStruct, now: NowProtocol?=nil) {
        self.pillData = pillData
        self._now = now ?? PDNow()
        if pillData.attributes.name == nil {
            self.pillData.attributes.name = PillStrings.NewPill
        }
    }

    public var id: UUID {
        get { pillData.id }
        set { pillData.id = newValue }
    }

    public var attributes: PillAttributes {
        let defaultInterval = DefaultPillAttributes.expirationInterval
        let interval = pillData.attributes.expirationInterval.value ?? defaultInterval
        return PillAttributes(
            name: name,
            expirationIntervalSetting: interval,
            xDays: expirationInterval.xDaysValue,
            times: PDDateFormatter.convertTimesToCommaSeparatedString(times),
            notify: notify,
            timesTakenToday: timesTakenToday,
            lastTaken: lastTaken
        )
    }

    public var name: String {
        pillData.attributes.name ?? PillStrings.NewPill
    }

    public var expirationInterval: PillExpirationInterval {
        pillData.attributes.expirationInterval
    }

    public var expirationIntervalSetting: PillExpirationIntervalSetting {
        expirationInterval.value ?? DefaultPillAttributes.expirationInterval
    }

    public var times: [Time] {
        guard let timeString = pillData.attributes.times else { return [] }
        return DateFactory.createTimesFromCommaSeparatedString(timeString)
    }

    public func appendTime(_ time: Time) {
        var newTimes = times
        newTimes.append(time)
        newTimes = newTimes.filter { $0 != DateFactory.createDefaultDate() }
        let timeString = PDDateFormatter.convertTimesToCommaSeparatedString(newTimes)
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
        guard let val = expirationInterval.value else { return nil }
        switch val {
            case .EveryDay: return nextDueTimeForEveryDaySchedule
            case .EveryOtherDay: return dueDateForEveryOtherDay
            case .FirstXDays: return dueDateForFirstXDays
            case .LastXDays: return dueDateForLastXDays
            case .XDaysOnXDaysOff: return dueDateForXDaysOnXDaysOff
        }
    }

    public var isDue: Bool {
        guard timesTakenToday < timesaday else { return false }
        guard let dueDate = due else { return false }
        return now > dueDate
    }

    public var isNew: Bool {
        pillData.attributes.lastTaken == nil && !hasName
    }

    public var hasName: Bool {
        pillData.attributes.name != PillStrings.NewPill && pillData.attributes.name != ""
    }

    public var isDone: Bool {
        var xDaysIsOff = false
        if let isOnVal = expirationInterval.xDaysIsOn {
            xDaysIsOff = !isOnVal
        }
        return (timesTakenToday >= timesaday && lastTaken != nil) || xDaysIsOff
    }

    public func set(attributes: PillAttributes) {
        pillData.attributes.update(attributes)

        // Prevent pills with 0 set times
        if timesaday == 0 {
            let timeString = DefaultPillAttributes.time
            let defaultTime = DateFactory.createTimesFromCommaSeparatedString(timeString, now: _now)
            self.appendTime(defaultTime[0])
        }

        let interval = attributes.expirationInterval
        let wasGivenPosition = interval.xDaysPosition != nil || interval.xDaysIsOn != nil
        if wasGivenPosition && lastTaken == nil {
            // Set to arbitrary date in the past so it appears the schedule is in-progress.
            lastTaken = DateFactory.createDate(byAddingHours: -24, to: now)
        }
    }

    public func swallow() {
        guard timesTakenToday < timesaday || lastTaken == nil else { return }
        if lastTaken == nil
            && expirationInterval.value == .XDaysOnXDaysOff
            && pillData.attributes.expirationInterval.xDaysIsOn == nil {
            pillData.attributes.expirationInterval.startPositioning()
        }
        let currentTimesTaken = pillData.attributes.timesTakenToday ?? 0
        pillData.attributes.timesTakenToday = currentTimesTaken + 1
        lastTaken = now

        // Increment XDays position if done for the day
        if expirationInterval.value == .XDaysOnXDaysOff && isDone {
            expirationInterval.incrementXDays()
        }
    }

    public func awaken() {
        if timesTakenToday > 0,
            let lastDate = lastTaken as Date?,
            !lastDate.isInToday(now: _now) {

            pillData.attributes.timesTakenToday = 0
        }
    }

    private var pillDueDateFinderParams: PillDueDateFinderParams {
        PillDueDateFinderParams(timesTakenToday, timesaday, times)
    }

    private var dueDateForEveryOtherDay: Date? {
        guard let lastTaken = lastTaken else { return nextDueTimeForEveryDaySchedule }
        if _now.isInYesterday(lastTaken) {
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
        return DateFactory.createDate(at: times[0], daysFromToday: daysFromNow, now: _now)
    }

    private func beginningOfDueMonthAtTimeOne(lastTaken: Date) -> Date? {
        if let nextTime = nextDueTimeForEveryDaySchedule,
            let nextMonth = Calendar.current.date(bySetting: .day, value: 1, of: lastTaken) {
            return DateFactory.createDate(on: nextMonth, at: nextTime)
        }
        return nil
    }

    private func endOfDueMonthAtTimeOne(lastTaken: Date, days: Int) -> Date? {
        var startDay: Int
        guard let daysThisMonth = now.daysInMonth() else { return nil }
        if now.dayValue() == daysThisMonth {
            let daysNextMonth = DateFactory.createDate(byAddingHours: 48, to: now)?.daysInMonth()
            if let daysNextMonth = daysNextMonth {
                startDay = daysNextMonth - days
            } else {
                return nil
            }
        } else {
            startDay = daysThisMonth - days
        }

        if let nextTime = nextDueTimeForEveryDaySchedule,
            let month = Calendar.current.date(bySetting: .day, value: startDay, of: lastTaken) {
            return DateFactory.createDate(on: month, at: nextTime)
        }
        return nil
    }

    private var dueDateForFirstXDays: Date? {
        guard let days = expirationInterval.daysOne else { return nil }
        return dueDateBegin(days)
    }

    private var dueDateForLastXDays: Date? {
        guard let days = expirationInterval.daysOne else { return nil }
        return dueDateEnd(days - 1)
    }

    private func dueDateBegin(_ begin: Int) -> Date? {
        guard let lastTaken = lastTaken else { return nextDueTimeForEveryDaySchedule }
        let currentDay = now.dayValue()
        if currentDay < begin || (currentDay == begin && !isDone) {
            return nextDueTimeForEveryDaySchedule
        }
        return beginningOfDueMonthAtTimeOne(lastTaken: lastTaken)
    }

    private func dueDateEnd(_ end: Int) -> Date? {
        guard let lastTaken = lastTaken else { return nextDueTimeForEveryDaySchedule }
        guard let daysInMonth = lastTaken.daysInMonth() else {
            return nextDueTimeForEveryDaySchedule
        }
        let dayNumber = lastTaken.dayNumberInMonth()
        // Last "5" of 30 days = 26, 27, 28, 29, 30, len=5, 30-4=26.
        if dayNumber == daysInMonth && isDone || dayNumber <= end || lastTaken < Date() {
            return endOfDueMonthAtTimeOne(lastTaken: lastTaken, days: end)
        }
        return nextDueTimeForEveryDaySchedule
    }

    private var nextDueTimeForEveryDaySchedule: Date? {
        guard timesaday <= times.count else { return nil }
        if timesTakenToday < timesaday {
            let time = times[timesTakenToday]
            return DateFactory.createTodayDate(at: time, now: _now)
        }
        return tomorrowAtTimeOne
    }

    private var dueDateForXDaysOnXDaysOff: Date? {
        /*
        X X X X X O O O O O O O O O X X X X X O O O O O O O O O
        _ _ _ _ _ _ P _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

        # Constants

        On = X, Off = O
        Span = len(O[]) = 9

        # Variables

        Pos = P = 2     // Change position to calculate next due date

        # Evaluation

        Next = SPAN + 1         // The next start of "on" from "off" position 1
        Next = 10               // Eval
        Diff = Next - Pos       // The amount we are away from Next
        Diff = 10 - 2           // Eval
        Diff = 8                // Eval

        # Conclusion

        We are 8 days away from the next due date.
        */
        guard let isOn = expirationInterval.xDaysIsOn else { return nil }
        guard let pos = expirationInterval.xDaysPosition else { return nil }
        guard let onSpan = expirationInterval.daysOne else { return nil }
        guard let offSpan = expirationInterval.daysTwo else { return nil }

        if isOn {
            // If still needs taking in this on-cycle
            if pos < onSpan || (pos == onSpan && !isDone) {
                return nextDueTimeForEveryDaySchedule
            }

            // Has completed the current on-cycle
            return getTimeOne(daysFromNow: offSpan + 1)
        }

        // Is during off-cycle
        return getTimeOne(daysFromNow: (offSpan + 1) - pos)
    }
}
