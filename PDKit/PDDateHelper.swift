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
    
    /// Returns date calculated by adding days.
    public static func getDate(at: Time, daysToAdd: Int) -> Date? {
        let calendar = Calendar.current
        var addComponents = DateComponents()
        addComponents.day = daysToAdd
        if let tom = calendar.date(byAdding: addComponents, to: Date()) {
            let year = calendar.component(.year, from: tom)
            let month = calendar.component(.month, from: tom)
            let day = calendar.component(.day, from: tom)
            let hour = calendar.component(.hour, from: at)
            let min = calendar.component(.minute, from: at)
            let components = DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: year, month: month, day: day, hour: hour, minute: min)
            if let d = calendar.date(from: components) {
                return d
            }
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
    
    /// Returns today's date with the given time.
    public static func getTodayDate(at: Time) -> Date? {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        let hour = calendar.component(.hour, from: at)
        let min = calendar.component(.minute, from: at)
        let components = DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: year, month: month, day: day, hour: hour, minute: min)
        if let d = calendar.date(from: components) {
            return d
        }
        print("Error: Undetermined time.")
        return nil
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
