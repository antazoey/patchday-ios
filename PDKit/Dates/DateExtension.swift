//
//  DateExtension.swift
//  PDKit
//
//  Created by Juliya Smith on 1/4/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

extension Date {

    public func isWithin(minutes: Int, of date: Date) -> Bool {
		let earlier = min(self, date)
		let later = max(self, date)
		let interval = abs(later.timeIntervalSince(earlier))
		return interval < Double(minutes * 60) || interval == 0
	}

	public func isInPast() -> Bool {
		self < Date()
	}

	/// Whether this date happened on the same day as today.
	public func isInToday() -> Bool {
		Calendar.current.isDateInToday(self)
	}

	/// Whether this date is between the hours of midnight and 6 am.
	public func isOvernight() -> Bool {
		guard let sixAM = Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: self),
			let midnight = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self) else {
				return false
		}
		return self < sixAM && self > midnight
	}

	public func isDefault() -> Bool {
		self == DateFactory.createDefaultDate()
	}
}
