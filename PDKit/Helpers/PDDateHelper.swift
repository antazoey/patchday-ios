//
//  PDDateHelper.swift
//  PDKit
//
//  Created by Juliya Smith on 6/20/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

public typealias Time = Date

public class PDDateHelper: NSObject {
    
    override public var description: String {
        return "Class for doing calculations on Dates."
    }
    
    /// Returns the day of the week, such as "Tuesday"
    public class func dayOfWeekString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        if let word = dateWord(from: date) {
            dateFormatter.dateFormat = "h:mm a"
            return word + ", " + dateFormatter.string(from: date)
        }
        dateFormatter.dateFormat = "EEEE, h:mm a"
        return dateFormatter.string(from: date)
    }
    
    /// Returns word of date, such as "Tomorrow"
    public static func dateWord(from date: Date) -> String? {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return PDStrings.DayStrings.today
        } else if let yesterday = getDate(at: Date(), daysFromNow: -1),
            calendar.isDate(date, inSameDayAs: yesterday) {
            return PDStrings.DayStrings.yesterday
        } else if let tomorrow = getDate(at: Date(), daysFromNow: 1),
            calendar.isDate(date, inSameDayAs: tomorrow) {
            return PDStrings.DayStrings.tomorrow
        }
        return nil
    }
    
    /// Returns new date from date argument at the given time arguement.
    public static func getDate(on date: Date, at time: Time) -> Date? {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: time)
        let min = calendar.component(.minute, from: time)
        let components = DateComponents(calendar: calendar,
                                        timeZone: calendar.timeZone,
                                        year: year,
                                        month: month,
                                        day: day,
                                        hour: hour,
                                        minute: min)
        if let d = calendar.date(from: components) {
            return d
        }
        return nil
    }
    
    /// Returns date calculated by adding days from today.
    public static func getDate(at time: Time, daysFromNow: Int) -> Date? {
        let calendar = Calendar.current
        let now = Date()
        var addComponents = DateComponents()
        addComponents.day = daysFromNow
        if let newDate = calendar.date(byAdding: addComponents, to: now) {
            return getDate(on: newDate, at: time)
        }
        print("Error: Undetermined time.")
        return nil
    }
    
    /// Converts an interval string into the number of hours, defaults to 3.5 days.
    public static func calculateHours(of interval: String) -> Int {
        var numberOfHours: Int
        switch interval {
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
    public static func expirationDate(from date: Date,
                                      _ interval: String) -> Date? {
        let hours: Int = calculateHours(of: interval)
        let calendar = Calendar.current
        guard let expDate = calendar.date(byAdding: .hour,
                                          value: hours,
                                          to: date) else {
            return nil
        }
        return expDate
    }
    
    /// Returns the TimeInterval until expiration based on given
    public static func expirationInterval(_ interval: String,
                                          date: Date) -> TimeInterval? {
        if let expDate = expirationDate(from: date, interval) {
            // Return the interval to the expiration date.
            let now = Date()
            let expInterval = expDate >= now ?
                DateInterval(start: now, end: expDate).duration :
                -DateInterval(start: expDate, end: now).duration
            return expInterval
        }
        return nil
    }
    
    /// Gets 8 pm before an overnight date.
    public static func dateBefore(overNightDate: Date) -> Date? {
        if let eightPM_of = Calendar.current.date(bySettingHour: 20,
                                                  minute: 0,
                                                  second: 0,
                                                  of: overNightDate),
            let eightPM_before = Calendar.current.date(byAdding: .day,
                                                       value: -1,
                                                       to: eightPM_of) {
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
    
    /// Gives String for the given Date.
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
