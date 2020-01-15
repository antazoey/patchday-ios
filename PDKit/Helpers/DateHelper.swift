//
//  DateHelper.swift
//  PDKit
//
//  Created by Juliya Smith on 6/20/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

public typealias Time = Date

public class DateHelper: NSObject {
    
    private static var calendar = Calendar.current
    
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
    
    public static func createDate(byAddingMinutes minutes: Int, to date: Date) -> Date? {
        calendar.date(byAdding: .minute, value: minutes, to: date)
    }
    
    /// Returns word of date, such as "Tomorrow"
    public static func dateWord(from date: Date) -> String? {
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
    
    /// Creates a new Date from given Date at the given Time.
    public static func getDate(on date: Date, at time: Time) -> Date? {
        let components = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date),
            hour: calendar.component(.hour, from: time),
            minute: calendar.component(.minute, from: time)
        )
        return calendar.date(from: components)
    }
    
    /// Creates a Date calculated by adding days from today.
    public static func getDate(at time: Time, daysFromNow: Int) -> Date? {
        var addComponents = DateComponents()
        addComponents.day = daysFromNow
        if let newDate = calendar.date(byAdding: addComponents, to: Date()) {
            return getDate(on: newDate, at: time)
        }
        return nil
    }

    /// Gives the future date from the given one based on the given interval string.
    public static func calculateExpirationDate(from date: Date, _ hours: Int) -> Date? {
        calendar.date(byAdding: .hour, value: hours, to: date)
    }
    
    /// Returns the TimeInterval until expiration based on given
    public static func calculateExpirationTimeInterval(_ hours: Int, date: Date) -> TimeInterval? {
        if let expDate = calculateExpirationDate(from: date, hours) {
            let now = Date()
            return expDate >= now ?
                DateInterval(start: now, end: expDate).duration
                : -DateInterval(start: expDate, end: now).duration
        }
        return nil
    }
    
    /// Gets 8 pm before an overnight date.
    public static func dateBefore(overNightDate: Date) -> Date? {
        if let eightPM = getEightPM(of: overNightDate) {
            return eightPM.dayBefore()
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
    
    private static func getEightPM(of date: Date) -> Date? {
        calendar.date(bySettingHour: 20, minute: 0, second: 0, of: date)
    }
}
