//
// Created by Juliya Smith on 12/3/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class TodayData: TodayDataDelegate {

	private let defaults = UserDefaults(suiteName: "group.com.patchday.todaydata")

	func getDeliveryMethod() -> String? {
		let key = PDSetting.DeliveryMethod.rawValue
		return defaults?.string(forKey: key)
	}

	func getNextHormoneSiteName() -> String? {
		let siteKey = TodayKey.nextHormoneSiteName.rawValue
		return defaults?.object(forKey: siteKey) as? String
	}

	func getNextHormoneExpirationDate() -> Date? {
		let dateKey = TodayKey.nextHormoneDate.rawValue
		return defaults?.object(forKey: dateKey) as? Date
	}

	func getNextPillName() -> String? {
		let pillKey = TodayKey.nextPillToTake.rawValue
		return defaults?.object(forKey: pillKey) as? String
	}

	func getNextPillDate() -> Date? {
		let timeKey = TodayKey.nextPillTakeTime.rawValue
		return defaults?.object(forKey: timeKey) as? Date
	}
}
