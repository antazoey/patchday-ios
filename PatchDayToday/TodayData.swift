//
// Created by Juliya Smith on 12/3/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class TodayData: TodayDataDelegate {

    private let defaults = UserDefaults(suiteName: "group.com.patchday.todaydata")

    func getDeliveryMethod() -> String? {
        let key = PDDefault.DeliveryMethod.rawValue
        return  defaults?.string(forKey: key)
    }

    func getNextHormoneSiteName() -> String? {
        let siteKey = PDStrings.TodayKey.nextHormoneSiteName.rawValue
        return defaults?.object(forKey: siteKey) as? String
    }

    func getNextHormoneExpirationDate() -> Date? {
        let dateKey = PDStrings.TodayKey.nextHormoneDate.rawValue
        return defaults?.object(forKey: dateKey) as? Date
    }

    func getNextPillName() -> String? {
        let pillKey = PDStrings.TodayKey.nextPillToTake.rawValue
        return defaults?.object(forKey: pillKey) as? String
    }

    func getNextPillDate() -> Date? {
        let timeKey = PDStrings.TodayKey.nextPillTakeTime.rawValue
        return defaults?.object(forKey: timeKey) as? Date
    }
}
