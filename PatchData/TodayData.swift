//
//  TodayData.swift
//  PatchData
//
//  Created by Juliya Smith on 12/21/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class TodayData: NSObject {

    /// Sets MOEstrogen data for PatchDay Today widget.
    public static func setEstrogenDataForToday() {
        let defaults = UserDefaults(suiteName: "group.com.patchday.todaydata")!
        let siteKey = PDStrings.TodayKey.nextEstroSiteName.rawValue
        let dateKey = PDStrings.TodayKey.nextEstroDate.rawValue
        let interval = UserDefaultsController.getTimeIntervalString()
        let index = UserDefaultsController.getSiteIndex()
        if let estro = PDSchedule.getEstrogenForToday() {
            if let siteName = getSiteNameForToday(using: estro, current: index) {
                defaults.set(siteName, forKey: siteKey)
            } else {
                defaults.set(nil, forKey: siteKey)
            }
            if let date = estro.expirationDate(interval: interval) {
                defaults.set(date, forKey: dateKey)
            } else {
                defaults.set(nil, forKey: dateKey)
            }
        }
    }
    
    /// Sets MOPill data for PatchDay Today widget.
    public static func setPillDataForToday() {
        let defaults = UserDefaults(suiteName: "group.com.patchday.todaydata")!
        let pillNameKey = PDStrings.TodayKey.nextPillToTake.rawValue
        let pillDateKey = PDStrings.TodayKey.nextPillTakeTime.rawValue
        if let nextPill = PDSchedule.pillSchedule.nextPillDue() {
            if let pillName = nextPill.getName() {
                defaults.set(pillName, forKey: pillNameKey)
            } else {
                defaults.set(nil, forKey: pillNameKey)
            }
            if let pillDate = nextPill.getDueDate() {
                defaults.set(pillDate, forKey: pillDateKey)
            } else {
                defaults.set(nil, forKey: pillDateKey)
            }
        }
    }
    
    /// Sets data to be displayed in PatchDay Today widget.
    public static func setDataForTodayApp() {
        setEstrogenDataForToday()
        setPillDataForToday()
    }

    /// Helper function for retrieving correct SiteName data to be saved in PatchDay Today widget.
    private static func getSiteNameForToday(using estro: MOEstrogen, current: Index) -> SiteName? {
        if UserDefaultsController.usingPatches() {
            return estro.getSiteName()
        } else if let suggestedSite = PDSchedule.suggest(current: current),
            let name = suggestedSite.getName() {
            return name
        }
        return nil
    }
}
