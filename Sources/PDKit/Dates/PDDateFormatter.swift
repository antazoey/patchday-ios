//
//  PDDateFormatter.swift
//  PDKit
//
//  Created by Juliya Smith on 2/2/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

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

    /// Gives String for the given Date.
    public static func formatDate(_ date: Date) -> String {
        if let word = dateWord(from: date) {
            return getWordedDateString(from: date, word: word)
        }
        let formatter = DateFormatterFactory.createDateFormatter()
        return formatter.string(from: date)
    }

    public static func formatDay(_ day: Date) -> String {
        if let word = dateWord(from: day) {
            return getWordedDateString(from: day, word: word)
        }
        let formatter = DateFormatterFactory.createDayFormatter()
        return formatter.string(from: day)
    }

    /// For migrating Pill times
    public static func convertTimesToCommaSeparatedString(_ times: [Date?]) -> String {
        let formatter = DateFormatterFactory.createInternalTimeFormatter()
        let dateStrings = times.map({ d in formatter.string(for: d) }).filter {
            s in s != nil
        } as! [String]
        return dateStrings.joined(separator: ",")
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
}
