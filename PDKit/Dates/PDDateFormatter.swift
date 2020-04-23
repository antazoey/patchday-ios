//
//  DateFormatter.swift
//  PDKit
//
//  Created by Juliya Smith on 2/2/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation


public class PDDateFormatter {

	private static let timeFormatter: DateFormatter = { createFormatter("h:mm a") }()
	private static let dateFormatter: DateFormatter = { createFormatter("EEEE, h:mm a") }()
	private static var calendar = { Calendar.current }()

	/// Gives String for the given Time.
	public static func formatTime(_ time: Time) -> String {
		timeFormatter.string(from: time)
	}

	/// Gives String for the given Date.
	public static func formatDate(_ date: Date) -> String {
		if let word = dateWord(from: date) {
			let time = timeFormatter.string(from: date)
			return word + ", " + time
		}
		return dateFormatter.string(from: date)
	}

	private static func dateWord(from date: Date) -> String? {
		if calendar.isDateInToday(date) {
			return DayStrings.today
		} else if let yesterdayAtThisTime = DateFactory.createDate(daysFromNow: -1),
			calendar.isDate(date, inSameDayAs: yesterdayAtThisTime) {
			return DayStrings.yesterday
		} else if let tomorrowAtThisTime = DateFactory.createDate(daysFromNow: 1),
			calendar.isDate(date, inSameDayAs: tomorrowAtThisTime) {
			return DayStrings.tomorrow
		}
		return nil
	}

	private static func createFormatter(_ format: String) -> DateFormatter {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		return formatter
	}
}
