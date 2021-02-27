//
//  DateExtension.swift
//  PDKit
//
//  Created by Juliya Smith on 1/4/19.

import Foundation

extension Date {

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
        let nowFactory = now ?? PDNow()
        let nowDate = nowFactory.now
        return Calendar.current.isDate(nowDate, equalTo: self, toGranularity: .day)
    }

    /// Whether this date is tomorrow.
    public func isInTomorrow() -> Bool {
        Calendar.current.isDateInTomorrow(self)
    }

    /// Whether this date is yesterday.
    public func isInYesterday() -> Bool {
        Calendar.current.isDateInYesterday(self)
    }

    /// Whether this date is between the hours of midnight and 6 am.
    public func isOvernight() -> Bool {
        guard let sixAM = Calendar.current.date(
            bySettingHour: 6, minute: 0, second: 0, of: self
        ),
            let midnight = Calendar.current.date(
                bySettingHour: 0, minute: 0, second: 0, of: self
            ) else {
                return false
        }
        return self < sixAM && self > midnight
    }

    public func isDefault() -> Bool {
        self == DateFactory.createDefaultDate()
    }
}
