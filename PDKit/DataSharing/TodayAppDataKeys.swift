//
//  TodayAppDataKeys.swift
//  PDKit
//
//  Created by Juliya Smith on 5/4/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

public enum TodayKey: String {
	case NextHormoneSiteName = "nextEstroSiteName"
	case NextHormoneDate = "nextEstroDate"
	case NextPillToTake = "nextPillToTake"
	case NextPillTakeTime = "nextPillTakeTime"
}

public let PDSharedDataGroupName: String = "group.com.patchday.todaydata"
