//
//  EstrogenSchedule.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/19/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import PDKit

public struct EstrogenStruct {
    var siteName: String?
    var date: Date?
}

public struct PillStruct {
    var name: String?
    var nextTakeDate: Date?
}

public class PDSharedDataController: NSObject {

    private static var defaults = UserDefaults(suiteName: "group.com.patchday.todaydata")
    
    // MARK: - Public

    public static func usingPatches() -> Bool {
        let key = "delivMethod"
        if let delivMethod = defaults?.string(forKey: key) {
            return delivMethod == PDStrings.PickerData.deliveryMethods[0]
        }
        return false
    }
    
    public static func getNextEstrogen() -> EstrogenStruct {
        var estro = EstrogenStruct()
        let siteKey = PDStrings.TodayKey.nextEstroSiteName.rawValue
        if let name = defaults?.object(forKey: siteKey) as? String {
            estro.siteName = name
        }
        let dateKey = PDStrings.TodayKey.nextEstroDate.rawValue
        if let date = defaults?.object(forKey: dateKey) as? Date {
            estro.date = date
        }
        return estro
    }
    
    public static func getNextPill() -> PillStruct {
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
