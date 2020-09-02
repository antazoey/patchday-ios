//
//  PDDateFormatters.swift
//  PDKit
//
//  Created by Juliya Smith on 9/2/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation


class DateFormatterFactory {

	static func createTimeFormatter() -> DateFormatter {
		createFormatter("h:mm a")
	}

	static func createDayFormatter() -> DateFormatter {
		createFormatter("EEEE, h:mm a")
	}

	static func createDateFormatter() -> DateFormatter {
		createFormatter("EEEE, MMMM d, h:mm a")
	}

	static func createInternalTimeFormatter() -> DateFormatter {
		createFormatter("HH:MM:SS")
	}

	private static func createFormatter(_ format: String) -> DateFormatter {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		return formatter
	}
}
