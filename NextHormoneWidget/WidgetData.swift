//
//  WidgetData.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/23/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class WidgetData {

    private lazy var defaults = UserDefaults(suiteName: PDSharedDataGroupName)

    func getDeliveryMethod() -> String? {
        let key = PDSetting.DeliveryMethod.rawValue
        return defaults?.string(forKey: key)
    }

    func getNextHormoneSiteName() -> String? {
        let siteKey = SharedDataKey.NextHormoneSiteName.rawValue
        return defaults?.string(forKey: siteKey)
    }

    func getNextHormoneExpirationDate() -> Date? {
        let dateKey = SharedDataKey.NextHormoneDate.rawValue
        return defaults?.object(forKey: dateKey) as? Date
    }

    func getNextPillName() -> String? {
        let pillKey = SharedDataKey.NextPillToTake.rawValue
        return defaults?.string(forKey: pillKey)
    }

    func getNextPillDate() -> Date? {
        let timeKey = SharedDataKey.NextPillTakeTime.rawValue
        return defaults?.object(forKey: timeKey) as? Date
    }
}
