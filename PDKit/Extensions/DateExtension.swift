//
//  DateExtension.swift
//  PDKit
//
//  Created by Juliya Smith on 1/4/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

extension Date {

    public func isWithin(minutes: Int, of date: Date) -> Bool {
        let earlier = min(self, date)
        let later = max(self, date)
        let t = abs(later.timeIntervalSince(earlier))
        return t < Double(minutes * 60)
    }

    public func isInPast() -> Bool {
        self < Date()
    }
    
    /// Whether this date happened on the same day as today.
    public func isInToday() -> Bool {
        Calendar.current.isDate(self, inSameDayAs: Date())
    }
    
    /// Whether this date is between the hours of midnight and 6 am.
    public func isOvernight() -> Bool {
        if let sixAM = Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: self),
            let midnight = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self) {

            return self < sixAM && self > midnight
        }
        return false
    }
    
    public func isDefault() -> Bool {
        self == Date.createDefaultDate()
    }
    
    public static func createDefaultDate() -> Date {
        Date(timeIntervalSince1970: 0)
    }
    
    public func dayBefore() -> Date? {
        Calendar.current.date(byAdding: .day, value: -1, to: self)
    }
}
