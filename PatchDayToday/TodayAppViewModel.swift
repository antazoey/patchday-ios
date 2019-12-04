//
//  EstrogenSchedule.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/19/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import PDKit

struct HormoneStruct {
    var siteName: String?
    var date: Date?
}

struct PillStruct {
    var name: String?
    var nextTakeDate: Date?
}

class TodayAppViewModel: NSObject {

    private static let data: TodayAppDataDelegate

    init(dataDelegate: TodayAppDataDelegate)
    
    // MARK: - Public

    static var usingPatches: Bool {
        let key = PDDefault.DeliveryMethod.rawValue
        if let method = defaults?.string(forKey: key) {
            return method == NSLocalizedString("Patches", comment: "duplicate")
        }
        return false
    }
    
    static func getNextHormone() -> HormoneStruct {
        var mone = HormoneStruct()
        let siteKey = PDStrings.TodayKey.nextEstroSiteName.rawValue
        if let name = defaults?.object(forKey: siteKey) as? String {
            mone.siteName = name
        }
        let dateKey = PDStrings.TodayKey.nextEstroDate.rawValue
        if let date = defaults?.object(forKey: dateKey) as? Date {
            mone.date = date
        }
        return mone
    }
    
    static func getNextPill() -> PillStruct {
        var pill = PillStruct()
        let pillKey = PDStrings.TodayKey.nextPillToTake.rawValue
        if let name = defaults?.object(forKey: pillKey) as? String {
            pill.name = name
        }
        let timeKey = PDStrings.TodayKey.nextPillTakeTime.rawValue
        if let t = defaults?.object(forKey: timeKey) as? Date {
            pill.nextTakeDate = t
        }
        return pill
    }
}
