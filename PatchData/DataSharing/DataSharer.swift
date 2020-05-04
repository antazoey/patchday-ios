//
//  DataSharer.swift
//  PatchData
//
//  Created by Juliya Smith on 1/18/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class DataSharer: DataSharing {

	private var sharedDefaults: UserDefaults? {
		UserDefaults(suiteName: PDSharedDataGroupName)
	}

	public func share(_ value: Any?, forKey key: String) {
		sharedDefaults?.set(value, forKey: key)
	}

	public func object(forKey key: String) -> Any? {
		sharedDefaults?.object(forKey: key)
	}
}

public enum TodayKey: String {
	case nextHormoneSiteName = "nextEstroSiteName"
	case nextHormoneDate = "nextEstroDate"
	case nextPillToTake = "nextPillToTake"
	case nextPillTakeTime = "nextPillTakeTime"
}
