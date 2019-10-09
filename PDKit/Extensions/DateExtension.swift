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
    
    /// Returns if the given date is behind us.
    public func isInPast() -> Bool {
        return self < Date()
    }
    
    /// Returns whether the date is in today.
    public func isInToday() -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: Date())
    }
    
    /// Returns if the date is between the hours of midnight and 6 am.
    public func isOvernight() -> Bool {
        if let sixAM = Calendar.current.date(bySettingHour: 6,
                                             minute: 0,
                                             second: 0,
                                             of: self),
            let midnight = Calendar.current.date(bySettingHour: 0,
                                                 minute: 0,
                                                 second: 0,
                                                 of: self) {
            return self < sixAM && self > midnight
        }
        return false
    }
    
    public func isDefault() -> Bool {
        return self == Date.createDefaultDate()
    }
    
    public static func createDefaultDate() -> Date {
        return Date(timeIntervalSince1970: 0)
    }
}
