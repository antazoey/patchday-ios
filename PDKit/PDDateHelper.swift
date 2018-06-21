//
//  PDDateHelper.swift
//  PDKit
//
//  Created by Juliya Smith on 6/20/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

public class PDDateHelper: NSObject {
    
    // Returns the day of the week, such as "Tuesday"
    public static func dayOfWeekString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        if let word = dateWord(from: date) {
            dateFormatter.dateFormat = "h:mm a"
            return word + ", " + dateFormatter.string(from: date)
        }
        dateFormatter.dateFormat = "EEEE, h:mm a"
        return dateFormatter.string(from: date)
    }
    
    // Returns word of date, such as "Tomorrow"
    public static func dateWord(from: Date) -> String? {
        let calendar = Calendar.current
        if calendar.isDateInToday(from) {
            return PDStrings.dayStrings.today
        }
        else if let yesterday = getDate(at: Date(), daysToAdd: -1), calendar.isDate(from, inSameDayAs: yesterday) {
            return PDStrings.dayStrings.yesterday
        }
        else if let tomorrow = getDate(at: Date(), daysToAdd: 1), calendar.isDate(from, inSameDayAs: tomorrow) {
            return PDStrings.dayStrings.tomorrow
        }
        return nil
    }
    
    // Returns date calculated by adding days.
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
    
    // Returns if the given date is behind us.
    public static func isInPast(this: Date) -> Bool {
        return this < Date()
    }
    
    // Returns today's date with the given time.
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
    
    // Input time, output time string
    public static func format(time: Time) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: time)
    }
    
    // Input time, output date string
    public static func format(date: Date) -> String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            dateFormatter.dateFormat = "h:mm a"
            return PDStrings.dayStrings.today + ", " + dateFormatter.string(from: date)
        }
        else if let yesterday: Date = getDate(at: Date(), daysToAdd: -1), calendar.isDate(date, inSameDayAs: yesterday) {
            dateFormatter.dateFormat = "h:mm a"
            return PDStrings.dayStrings.yesterday + ", " + dateFormatter.string(from: date)
        }
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: date)
    }
    
    
}
