//
//  PDDateHelper.swift
//  PDKit
//
//  Created by Juliya Smith on 6/20/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

public typealias Time = Date

public class PDDateHelper: NSObject {
    
    /// Returns the day of the week, such as "Tuesday"
    public static func dayOfWeekString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        if let word = dateWord(from: date) {
            dateFormatter.dateFormat = "h:mm a"
            return word + ", " + dateFormatter.string(from: date)
        }
        dateFormatter.dateFormat = "EEEE, h:mm a"
        return dateFormatter.string(from: date)
    }
    
    /// Returns word of date, such as "Tomorrow"
    public static func dateWord(from: Date) -> String? {
        let calendar = Calendar.current
        if calendar.isDateInToday(from) {
            return PDStrings.DayStrings.today
        }
        else if let yesterday = getDate(at: Date(), daysToAdd: -1), calendar.isDate(from, inSameDayAs: yesterday) {
            return PDStrings.DayStrings.yesterday
        }
        else if let tomorrow = getDate(at: Date(), daysToAdd: 1), calendar.isDate(from, inSameDayAs: tomorrow) {
            return PDStrings.DayStrings.tomorrow
        }
        return nil
    }
    
    public static func getDate(on date: Date, at time: Time) -> Date? {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: time)
        let min = calendar.component(.minute, from: time)
        let components = DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: year, month: month, day: day, hour: hour, minute: min)
        if let d = calendar.date(from: components) {
            return d
        }
        return nil
    }
    
    /// Returns date calculated by adding days.
    public static func getDate(at time: Time, daysToAdd: Int) -> Date? {
        let calendar = Calendar.current
        var addComponents = DateComponents()
        addComponents.day = daysToAdd
        if let futureDate = calendar.date(byAdding: addComponents, to: Date()) {
            return getDate(on: futureDate, at: time)
        }
        print("Error: Undetermined time.")
        return nil
    }
    
    /// Returns if the given date is behind us.
    public static func isInPast(this: Date) -> Bool {
        return this < Date()
    }
    
    /// Returns whether the date is in today.
    public static func dateIsInToday(_ date: Date) -> Bool {
        return Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    /// Converts an interval string into the number of hours, defaults to 3.5 days.
    public static func calculateHours(of intervalStr: String) -> Int {
        var numberOfHours: Int
        switch intervalStr {
        case PDStrings.PickerData.expirationIntervals[1]:
            numberOfHours = 168
        case PDStrings.PickerData.expirationIntervals[2]:
            numberOfHours = 336
        default:
            numberOfHours = 84
        }
        return numberOfHours
    }
    
    /// Gives the future date from the given one based on the given interval string.
    public static func expirationDate(from date: Date, _ intervalStr: String) -> Date? {
        let hours: Int = calculateHours(of: intervalStr)
        let calendar = Calendar.current
        guard let expDate = calendar.date(byAdding: .hour, value: hours, to: date) else {
            return nil
        }
        return expDate
    }
    
    /// Returns the TimeInterval until expiration based on given
    public static func expirationInterval(_ intervalStr: String, date: Date) -> TimeInterval? {
        if let expDate = expirationDate(from: date, intervalStr) {
            let now = Date()
            // +
            if expDate >= now {
                return DateInterval(start: now, end: expDate).duration
            }
            // -
            else {
                return -DateInterval(start: expDate, end: now).duration
            }
        }
        return nil
    }
    
    public static func isOvernight(_ date: Date) -> Bool {
        if let sixAM = Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: date),
            let midnight = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: date) {
            return date < sixAM && date > midnight
        }
        return false
    }
    
    public static func dateBeforeOvernight(overnightDate: Date) -> Date? {
        if let eightPM_of = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: overnightDate), let eightPM_before = Calendar.current.date(byAdding: .day, value: -1, to: eightPM_of) {
            return eightPM_before
        }
        return nil
    }
    
    /// Gives String for the given Time.
    public static func format(time: Time) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: time)
    }
    
    // Gives String for the given Date.
    public static func format(date: Date, useWords: Bool) -> String {
        let dateFormatter = DateFormatter()
        if useWords, let word = dateWord(from: date) {
            dateFormatter.dateFormat = "h:mm a"
            return word + ", " + dateFormatter.string(from: date)
        }
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: date)
    }
    
}
