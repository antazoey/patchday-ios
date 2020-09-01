//
//  DateFormatter.swift
//  PDKit
//
//  Created by Juliya Smith on 2/2/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

public class PDDateFormatter {

	private static let strComment = "The word 'today' displayed on a button."
	public static var todayStr: String { NSLocalizedString("Today", comment: strComment) }
	public static var yesterdayStr: String { NSLocalizedString("Yesterday", comment: strComment) }
	public static var tomorrowStr: String { NSLocalizedString("Tomorrow", comment: strComment) }

	private static let timeFormatter: DateFormatter = { createFormatter("h:mm a") }()
	private static let dayFormatter: DateFormatter = { createFormatter("EEEE, h:mm a") }()
    private static let dateFormatter: DateFormatter = { createFormatter("EEEE, MMMM d, h:mm a") }()
	private static var calendar = { Calendar.current }()

	/// Gives String for the given Time.
	public static func formatTime(_ time: Time) -> String { timeFormatter.string(from: time) }

	/// Gives String for the given Date.
	public static func formatDate(_ date: Date) -> String {
		if let word = dateWord(from: date) {
            return getWordedDateString(from: date, word: word)
		}
		return dateFormatter.string(from: date)
	}

    public static func formatDay(_ day: Date) -> String {
        if let word = dateWord(from: day) {
            return getWordedDateString(from: day, word: word)
        }
        return dayFormatter.string(from: day)
    }

	/// For migrating Pill times
	public static func convertNSDatesToCommaSeparatedString(_ times: [NSDate?]) -> String {
		let formatter = DateFormatter()
		let format = "HH:MM:SS"
		formatter.dateFormat = format
		let dateStrings = times.map({ d in formatter.string(for: d) }).filter {
			s in s != nil
		} as! [String]
		return dateStrings.joined(separator: ",")
	}

    private static func getWordedDateString(from date: Date, word: String) -> String {
        word + ", " + timeFormatter.string(from: date)
    }

	private static func dateWord(from date: Date) -> String? {
		if calendar.isDateInToday(date) {
			return todayStr
		} else if let yesterdayAtThisTime = DateFactory.createDate(daysFromNow: -1),
			calendar.isDate(date, inSameDayAs: yesterdayAtThisTime) {
			return yesterdayStr
		} else if let tomorrowAtThisTime = DateFactory.createDate(daysFromNow: 1),
			calendar.isDate(date, inSameDayAs: tomorrowAtThisTime) {
			return tomorrowStr
		}
		return nil
	}

	private static func createFormatter(_ format: String) -> DateFormatter {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		return formatter
	}
}
