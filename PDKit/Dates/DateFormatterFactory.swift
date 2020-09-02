//
//  DateFormatterFactory.swift
//  PDKit
//
//  Created by Juliya Smith on 9/2/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

class DateFormatterFactory {

    static let timeFormat = "h:mm a"
    static let dayFormat = "EEEE, h:mm a"
    static let dateFormat = "EEEE, MMMM d, h:mm a"
    static let internalTimeFormat = "HH:MM:SS"

    static func createTimeFormatter() -> DateFormatter {
        createFormatter(timeFormat)
    }

    static func createDayFormatter() -> DateFormatter {
        createFormatter(dayFormat)
    }

    static func createDateFormatter() -> DateFormatter {
        createFormatter(dateFormat)
    }

    static func createInternalTimeFormatter() -> DateFormatter {
        createFormatter(internalTimeFormat)
    }

    private static func createFormatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter
    }
}
