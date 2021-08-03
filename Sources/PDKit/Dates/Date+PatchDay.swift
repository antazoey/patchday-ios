//
//  DateExtension.swift
//  PDKit
//
//  Created by Juliya Smith on 1/4/19.

import Foundation

extension Date {

    public func daysSince(_ otherDate: Date?=nil, now: NowProtocol?=nil) -> Int {
        let otherDate = otherDate ?? now?.now ?? Date()
        guard let midnight = DateFactory.createMidnight(of: self, now: now) else {
            return 0  // Shouldn't happen
        }
        guard let midnightOfOtherDate = DateFactory.createMidnight(of: otherDate, now: now) else {
            return 0  // Shouldn't happen
        }
        let difference = midnight.timeIntervalSince(midnightOfOtherDate)
        let secondsInDay = 60.0 * 60.0 * 24.0
        return Int(difference / secondsInDay)
    }

    public func isWithin(minutes: Int, of date: Date) -> Bool {
        let earlier = min(self, date)
        let later = max(self, date)
        let interval = abs(later.timeIntervalSince(earlier))
        return interval < Double(minutes * 60) || interval == 0
    }

    public func dayValue() -> Int {
        Calendar.current.component(.day, from: self)
    }

    public func isInPast() -> Bool {
        self < Date()
    }

    public func dayNumberInMonth() -> Int {
        Calendar.current.component(.day, from: self)
    }

    public func daysInMonth() -> Int? {
        let cal = Calendar.current
        let range = cal.range(of: .day, in: .month, for: self)
        return range?.count
    }

    /// Whether this date is today.
    public func isInToday(now: NowProtocol?=nil) -> Bool {
        let today = now?.now ?? Date()
        return Calendar.current.isDate(today, equalTo: self, toGranularity: .day)
    }

    /// Whether this date is tomorrow.
    public func isInTomorrow(now: NowProtocol?=nil) -> Bool {
        guard let tomorrow = DateFactory.createDate(daysFrom: 1, now: now) else {
            return false
        }
        return Calendar.current.isDate(tomorrow, equalTo: self, toGranularity: .day)
    }

    /// Whether this date is yesterday.
    public func isInYesterday(now: NowProtocol?=nil) -> Bool {
        guard let yesterday = DateFactory.createDate(daysFrom: -1, now: now) else {
            return false
        }
        return Calendar.current.isDate(yesterday, equalTo: self, toGranularity: .day)
    }

    /// Whether this date is between the hours of midnight and 6 am.
    public func isOvernight() -> Bool {
        guard let sixAM = DateFactory.createDate(self, hour: 6) else { return false }
        guard let midnight = DateFactory.createMidnight(of: self) else { return false }
        return self < sixAM && self > midnight
    }

    public func isDefault() -> Bool {
        self == DateFactory.createDefaultDate()
    }
}
