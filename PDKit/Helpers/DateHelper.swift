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
    
    public static func getDate(at time: Time) -> Date? {
        getDate(on: Date(), at: time)
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
    
    /// Create a Date by adding days from right now.
    public static func getDate(daysFromNow: Int) -> Date? {
        getDate(at: Date(), daysFromToday: daysFromNow)
    }
    
    /// Creates a Date at the given time calculated by adding days from today.
    public static func getDate(at time: Time, daysFromToday: Int) -> Date? {
        var addComponents = DateComponents()
        addComponents.day = daysFromToday
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
    
    public static func createDate(byAddingMinutes minutes: Int, to date: Date) -> Date? {
        calendar.date(byAdding: .minute, value: minutes, to: date)
    }
    
    private static func getEightPM(of date: Date) -> Date? {
        calendar.date(bySettingHour: 20, minute: 0, second: 0, of: date)
    }
}
