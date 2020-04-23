//
//  DateFactory.swift
//  PDKit
//
//  Created by Juliya Smith on 6/20/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

public class DateFactory: NSObject {

	private static var calendar = Calendar.current

	public static func createTodayDate(at time: Time) -> Date? {
		createDate(on: Date(), at: time)
	}

	/// Creates a new Date from given Date at the given Time.
	public static func createDate(on date: Date, at time: Time) -> Date? {
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
	public static func createDate(daysFromNow: Int) -> Date? {
		createDate(at: Date(), daysFromToday: daysFromNow)
	}

	/// Creates a Date at the given time calculated by adding days from today.
	public static func createDate(at time: Time, daysFromToday: Int) -> Date? {
		var componentsToAdd = DateComponents()
		componentsToAdd.day = daysFromToday
		if let newDate = calendar.date(byAdding: componentsToAdd, to: Date()) {
			return createDate(on: newDate, at: time)
		}
		return nil
	}

	/// Gives the future date from the given one based on the given interval string.
	public static func createDate(byAddingHours hours: Int, to date: Date) -> Date? {
		calendar.date(byAdding: .hour, value: hours, to: date)
	}

	public static func createDate(byAddingMinutes minutes: Int, to date: Date) -> Date? {
		calendar.date(byAdding: .minute, value: minutes, to: date)
	}

	public static func createTimeInterval(fromAddingHours hours: Int, to date: Date) -> TimeInterval? {
		guard !date.isDefault(), let dateWithAddedHours = createDate(byAddingHours: hours, to: date) else {
			return nil
		}
		var range = [Date(), dateWithAddedHours]
		range.sort()
		let interval = DateInterval(start: range[0], end: range[1]).duration
		return range[1] == dateWithAddedHours ? interval : -interval
	}

	/// Creates date
	public static func createDateBeforeAtEightPM(of date: Date) -> Date? {
		if let eightPM = createEightPM(of: date) {
			return createDayBefore(eightPM)
		}
		return nil
	}

	public static func createDefaultDate() -> Date {
		Date(timeIntervalSince1970: 0)
	}

	private static func createEightPM(of date: Date) -> Date? {
		calendar.date(bySettingHour: 20, minute: 0, second: 0, of: date)
	}

	private static func createDayBefore(_ date: Date) -> Date? {
		calendar.date(byAdding: .day, value: -1, to: date)
	}
}
