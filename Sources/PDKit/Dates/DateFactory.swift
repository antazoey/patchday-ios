//
//  DateFactory.swift
//  PDKit
//
//  Created by Juliya Smith on 6/20/18.

public class DateFactory: NSObject {

    private static var calendar = Calendar.current

    /// Create a date at midnight of the given the date.
    public static func createMidnight(of date: Date?=nil, now: NowProtocol?=nil) -> Date? {
        createDate(date, now: now)
    }

    /// Creates a date with the given `hour` and the rest of the components the same as the given `date`.
    public static func createDate(
        _ date: Date?=nil, hour: Int=0, minute: Int=0, second: Int=0, now: NowProtocol?=nil
    ) -> Date? {
        let date = date ?? now?.now ?? Date()
        return calendar.date(bySettingHour: hour, minute: minute, second: second, of: date)
    }

    /// Create a date today at the given `time`.
    public static func createTodayDate(at time: Time, now: NowProtocol?=nil) -> Date? {
        createDate(at: time)
    }

    /// Creates a new Date from given Date at the given Time (defaults to now).
    public static func createDate(on date: Date?=nil, at time: Time?=nil, now: NowProtocol?=nil) -> Date? {
        let date = date ?? now?.now ?? Date()
        let time = time ?? date
        let components = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date),
            hour: calendar.component(.hour, from: time),
            minute: calendar.component(.minute, from: time),
            second: calendar.component(.second, from: time)
        )
        return calendar.date(from: components)
    }

    /// Creates a Date at the given time calculated by adding days to the fromDate (defaults to now).
    public static func createDate(
        daysFrom: Int=0, fromDate: Date?=nil, at time: Time?=nil, now: NowProtocol?=nil
    ) -> Date? {
        var component = DateComponents()
        component.day = daysFrom
        let date = createDateFromAdd(daysFrom, component, fromDate, now)
        return createDate(on: date, at: time, now: now)
    }

    /// Creates a Date at the given time calculated by adding hours to the fromDate (defaults to now).
    public static func createDate(
        hoursFrom: Int=0, fromDate: Date?=nil, now: NowProtocol?=nil
    ) -> Date? {
        var component = DateComponents()
        component.hour = hoursFrom
        return createDateFromAdd(hoursFrom, component, fromDate, now)
    }

    /// Creates a Date at the given time calculated by adding minutes to the fromDate (defaults to now).
    public static func createDate(
        minutesFrom: Int=0, fromDate: Date?=nil, now: NowProtocol?=nil
    ) -> Date? {
        var component = DateComponents()
        component.minute = minutesFrom
        return createDateFromAdd(minutesFrom, component, fromDate, now)
    }

    public static func createDate(byAddingMonths months: Int, to date: Date) -> Date? {
        calendar.date(byAdding: .month, value: months, to: date)
    }

    public static func createDate(byAddingHours hours: Int, to date: Date) -> Date? {
        calendar.date(byAdding: .hour, value: hours, to: date)
    }

    public static func createDate(byAddingMinutes minutes: Int, to date: Date) -> Date? {
        calendar.date(byAdding: .minute, value: minutes, to: date)
    }

    public static func createDate(byAddingSeconds seconds: Int, to date: Date) -> Date? {
        calendar.date(byAdding: .second, value: seconds, to: date)
    }

    public static func createExpirationDate(
        expirationInterval: ExpirationIntervalUD, to date: Date
    ) -> Date? {
        createDate(byAddingHours: expirationInterval.hours, to: date)
    }

    public static func createTimesFromCommaSeparatedString(
        _ timeString: String, now: NowProtocol?=nil
    ) -> [Time] {
        let formatter = DateFormatterFactory.createInternalTimeFormatter()

        let dates = timeString.split(separator: ",").map {
            formatter.date(from: String($0))
        }.filter { $0 != nil } as! [Time]

        let now = now?.now ?? Time()

        // Convert all dates to today for sake of soft-converting to Times.
        let timesWithSameDate = dates.map {
            DateFactory.createDate(on: now, at: $0)
        }.filter { $0 != nil } as! [Time]
        return timesWithSameDate.sorted()
    }

    /// Creates a time interval by adding the given hours to the given date.
    public static func createTimeInterval(
        fromAddingHours hours: Int, to date: Date
    ) -> TimeInterval? {
        guard !date.isDefault() else { return nil }
        guard let newDate = createDate(byAddingHours: hours, to: date) else { return nil }

        // Find start and end between date and now (handling negative hours)
        var range = [Date(), newDate]
        range.sort()
        let interval = DateInterval(start: range[0], end: range[1]).duration
        return range[1] == newDate ? interval : -interval
    }

    // TODO: Figure out if this method needs to be like this and can't just be
    // simpler. Also, does this even work???
    public static func createDateBeforeAtEightPM(of date: Date) -> Date? {
        guard let eightPM = createEightPM(of: date) else { return nil }
        return createDayBefore(eightPM)
    }

    /// Create a date that is the Unix start date.
    public static func createDefaultDate() -> Date {
        Date(timeIntervalSince1970: 0)
    }

    private static func createEightPM(of date: Date) -> Date? {
        createDate(date, hour: 20)
    }

    private static func createDayBefore(_ date: Date) -> Date? {
        calendar.date(byAdding: .day, value: -1, to: date)
    }

    private static func createDateFromAdd(
        _ unitsFrom: Int, _ component: DateComponents, _ fromDate: Date?, _ now: NowProtocol?=nil
    ) -> Date? {
        let fromDate = fromDate ?? now?.now ?? Date()
        guard let newDate = calendar.date(byAdding: component, to: fromDate) else { return nil }
        return createDate(on: newDate)
    }
}
