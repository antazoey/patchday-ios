//
//  PDDateFormatter.swift
//  PDKit
//
//  Created by Juliya Smith on 2/2/20.

import Foundation

public class PDDateFormatter {

    private static let localizationComment = "The word 'today' displayed on a button."
    public static var todayString: String = NSLocalizedString("Today", comment: localizationComment)
    public static var yesterdayString = NSLocalizedString("Yesterday", comment: localizationComment)
    public static var tomorrowString = NSLocalizedString("Tomorrow", comment: localizationComment)
    private static var calendar = Calendar.current

    /// Gives String for the given Time.
    public static func formatTime(_ time: Time) -> String {
        let formatter = DateFormatterFactory.createTimeFormatter()
        return formatter.string(from: time)
    }

    public static func formatInternalTime(_ time: Time) -> String {
        let formatter = DateFormatterFactory.createInternalTimeFormatter()
        return formatter.string(from: time)
    }

    /// Gives String for the given Date.
    public static func formatDate(_ date: Date, useWords: Bool=true) -> String {
        if useWords, let word = dateWord(from: date) {
            return getWordedDateString(from: date, word: word)
        }
        let formatter = DateFormatterFactory.createDateFormatter()
        return formatter.string(from: date)
    }

    /// Format a date to be user-friendly and include the day of the week.
    public static func formatDay(_ day: Date) -> String {
        if let word = dateWord(from: day) {
            return getWordedDateString(from: day, word: word)
        }
        let formatter = DateFormatterFactory.createDayFormatter()
        return formatter.string(from: day)
    }

    /// Convert a list of times to a comma-separated string.
    public static func convertTimesToCommaSeparatedString(_ times: [Time?]) -> String {
        convertDatesToString(times, formatter: DateFormatterFactory.createInternalTimeFormatter())
    }

    private static func getWordedDateString(from date: Date, word: String) -> String {
        let formatter = DateFormatterFactory.createTimeFormatter()
        let dateString = formatter.string(from: date)
        return "\(word), \(dateString)"
    }

    private static func dateWord(from date: Date) -> String? {
        if calendar.isDateInToday(date) {
            return todayString
        } else if let yesterdayAtThisTime = DateFactory.createDate(daysFromNow: -1),
            calendar.isDate(date, inSameDayAs: yesterdayAtThisTime) {
            return yesterdayString
        } else if let tomorrowAtThisTime = DateFactory.createDate(daysFromNow: 1),
            calendar.isDate(date, inSameDayAs: tomorrowAtThisTime) {
            return tomorrowString
        }
        return nil
    }

    private static func convertDatesToString(_ times: [Time?], formatter: Formatter) -> String {
        ((times
            .map({d in formatter.string(for: d)})
            .filter {s in s != nil}) as! [String])
            .joined(separator: ",")
    }
}
