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
    
    private let pddata: PDDefaults
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
    
    public init(defaults: PDDefaults, estrogenSchedule: EstrogenSchedule,
                pillSchedule: PillSchedule, siteSchedule: SiteSchedule) {
        self.pddata = defaults
        self.estrogenSchedule = estrogenSchedule
        self.pillSchedule = pillSchedule
        self.siteSchedule = siteSchedule
    }

    /// Sets MOEstrogen data for PatchDay Today widget.
    public func setEstrogenDataForToday() {
        let defaults = UserDefaults(suiteName: "group.com.patchday.todaydata")!
        let siteKey = PDStrings.TodayKey.nextEstroSiteName.rawValue
        let dateKey = PDStrings.TodayKey.nextEstroDate.rawValue
        let interval = pddata.getTimeInterval()
        let index = pddata.getSiteIndex()
        if let estro = estrogenSchedule.nextDue() {
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
    public func setDataForTodayApp() {
        setEstrogenDataForToday()
        setPillDataForToday()
    }

    /// Helper function for retrieving correct SiteName data to be saved in PatchDay Today widget.
    private func getSiteNameForToday(using estro: MOEstrogen, current: Index) -> SiteName? {
        let chg = pddata.setSiteIndex
        let sched = siteSchedule
        if pddata.usingPatches() {
            return estro.getSiteName()
        } else if let suggestedSite = sched.suggest(current: current, changeIndex: chg),
            let name = suggestedSite.getName() {
            return name
        }
        return nil
    }
}
