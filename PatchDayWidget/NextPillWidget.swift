//
//  NextPillWidget.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/24/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class NextPillLoader {
    private static var defaults = UserDefaults(suiteName: PDSharedDataGroupName)
    private static func getNextPillName() -> String? {
        let pillKey = SharedDataKey.NextPillToTake.rawValue
        return defaults?.string(forKey: pillKey)
    }

    private static func getNextPillDate() -> Date? {
        let timeKey = SharedDataKey.NextPillTakeTime.rawValue
        return defaults?.object(forKey: timeKey) as? Date
    }
}
