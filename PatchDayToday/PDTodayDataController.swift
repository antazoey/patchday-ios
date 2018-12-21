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

public class PDTodayDataController: NSObject {
    
    private static var defaults = UserDefaults(suiteName: "group.com.patchday.todaydata")
    
    // MARK: - Public
    
    public static func usingPatches() -> Bool {
        if let delivMethod = defaults?.object(forKey: PDStrings.SettingsKey.deliv.rawValue) as? String {
            return delivMethod == PDStrings.DeliveryMethods.patches
        }
        return false
    }
    
    public static func getNextEstrogen() -> EstrogenStruct {
        var estro = EstrogenStruct()
        if let name = defaults?.object(forKey: PDStrings.TodayKey.nextEstroSiteName.rawValue) as? String {
            estro.siteName = name
        }
        if let date = defaults?.object(forKey: PDStrings.TodayKey.nextEstroDate.rawValue) as? Date {
            estro.date = date
        }
        return estro
    }
    
    public static func getNextPill() -> PillStruct {
        var pill = PillStruct()
        if let name = defaults?.object(forKey: PDStrings.TodayKey.nextPillToTake.rawValue) as? String {
            pill.name = name
        }
        if let t = defaults?.object(forKey: PDStrings.TodayKey.nextPillTakeTime.rawValue) as? Date {
            pill.nextTakeDate = t
        }
        return pill
    }
    
}
