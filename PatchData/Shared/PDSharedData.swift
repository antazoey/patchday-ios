//
//  PDSharedData.swift
//  PatchData
//
//  Created by Juliya Smith on 12/21/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class PDSharedData: NSObject {
    
    public static let defaults = UserDefaults(suiteName: "group.com.patchday.todaydata")
    private let estrogenSchedule: EstrogenSchedule
    private let pillSchedule: PillSchedule
    private let siteSchedule: SiteSchedule
    
    override public var description: String {
        return """
               PDSharedData is a class of getters and setters
               for data that is accessible to other apps,
               namely: the PatchDay Today Widget."
               """
    }
    
    public init(estrogenSchedule: EstrogenSchedule,
                pillSchedule: PillSchedule, siteSchedule: SiteSchedule) {
        self.estrogenSchedule = estrogenSchedule
        self.pillSchedule = pillSchedule
        self.siteSchedule = siteSchedule
    }

    /// Sets MOEstrogen data for PatchDay Today widget.
    public func setEstrogenDataForToday(interval: String, usingPatches: Bool, index: Index, setSiteIndex: @escaping (Int) -> ()) {
        let siteKey = PDStrings.TodayKey.nextEstroSiteName.rawValue
        let dateKey = PDStrings.TodayKey.nextEstroDate.rawValue
        if let estro = estrogenSchedule.nextDue() {
            if let siteName = getSiteNameForToday(using: estro,
                                                  usingPatches: usingPatches,
                                                  current: index,
                                                  setSiteIndex: setSiteIndex) {
                PDSharedData.defaults?.set(siteName, forKey: siteKey)
            } else {
                PDSharedData.defaults?.set(nil, forKey: siteKey)
            }
            if let date = estro.expirationDate(interval: interval) {
                PDSharedData.defaults?.set(date, forKey: dateKey)
            } else {
                PDSharedData.defaults?.set(nil, forKey: dateKey)
            }
        }
    }
    
    /// Sets MOPill data for PatchDay Today widget.
    public func setPillDataForToday() {
        let defaults = UserDefaults(suiteName: "group.com.patchday.todaydata")!
        let pillNameKey = PDStrings.TodayKey.nextPillToTake.rawValue
        let pillDateKey = PDStrings.TodayKey.nextPillTakeTime.rawValue
        if let nextPill = pillSchedule.nextPillDue() {
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
    public func setDataForTodayApp(interval: String, index: Int,
                                   usingPatches: Bool,
                                   setSiteIndex: @escaping (Int) -> ()) {
        setEstrogenDataForToday(interval: interval,
                                usingPatches: usingPatches,
                                index: index,
                                setSiteIndex: setSiteIndex)
        setPillDataForToday()
    }

    /// Helper function for retrieving correct SiteName data to be saved in PatchDay Today widget.
    private func getSiteNameForToday(using estro: MOEstrogen, usingPatches: Bool, current: Index, setSiteIndex: @escaping (Int) -> ()) -> SiteName? {
        let chg = setSiteIndex
        let sched = siteSchedule
        if usingPatches {
            return estro.getSiteName()
        } else if let suggestedSite = sched.suggest(current: current,
                                                    changeIndex: chg),
            let name = suggestedSite.getName() {
            return name
        }
        return nil
    }
}
