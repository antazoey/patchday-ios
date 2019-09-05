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
    
    public let defaults = UserDefaults(suiteName: "group.com.patchday.todaydata")
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
                pillSchedule: PillSchedule,
                siteSchedule: SiteSchedule) {
        if defaults == nil {
            print("Unable to load shared defaults.")
        }
        self.estrogenSchedule = estrogenSchedule
        self.pillSchedule = pillSchedule
        self.siteSchedule = siteSchedule
    }

    /// Sets MOEstrogen data for PatchDay Today widget.
    public func setEstrogenDataForToday(interval: ExpirationIntervalUD,
                                        deliveryMethod: DeliveryMethodUD,
                                        index: Index,
                                        setSiteIndex: @escaping (Int) -> ()) {
        let siteKey = PDStrings.TodayKey.nextEstroSiteName.rawValue
        let dateKey = PDStrings.TodayKey.nextEstroDate.rawValue
        if let estro = estrogenSchedule.next {
            if let siteName = getSiteNameForToday(using: estro,
                                                  deliveryMethod: deliveryMethod.value,
                                                  current: index,
                                                  setSiteIndex: setSiteIndex) {
                defaults?.set(siteName, forKey: siteKey)
            } else {
                defaults?.set(nil, forKey: siteKey)
            }
            if let date = estro.expiration {
                defaults?.set(date, forKey: dateKey)
            } else {
                defaults?.set(nil, forKey: dateKey)
            }
        }
    }

    /// Sets MOPill data for PatchDay Today widget.
    public func setPillDataForToday() {
        let pillNameKey = PDStrings.TodayKey.nextPillToTake.rawValue
        let pillDateKey = PDStrings.TodayKey.nextPillTakeTime.rawValue
        if let nextPill = pillSchedule.nextDue() {
            if let pillName = nextPill.name {
                defaults?.set(pillName, forKey: pillNameKey)
            } else {
                defaults?.set(nil, forKey: pillNameKey)
            }
            if let pillDate = nextPill.due {
                defaults?.set(pillDate, forKey: pillDateKey)
            } else {
                defaults?.set(nil, forKey: pillDateKey)
            }
        }
    }
    
    /// Sets data to be displayed in PatchDay Today widget.
    public func setDataForTodayApp(interval: ExpirationIntervalUD, index: Index,
                                   deliveryMethod: DeliveryMethodUD,
                                   setSiteIndex: @escaping (Int) -> ()) {
        setEstrogenDataForToday(interval: interval,
                                deliveryMethod: deliveryMethod,
                                index: index,
                                setSiteIndex: setSiteIndex)
        setPillDataForToday()
    }

    /// Helper function for retrieving correct SiteName data to be saved in PatchDay Today widget.
    private func getSiteNameForToday(using estro: MOEstrogen,
                                     deliveryMethod: DeliveryMethod,
                                     current: Index,
                                     setSiteIndex: @escaping (Int) -> ()) -> SiteName? {
        let setSI = setSiteIndex
        switch deliveryMethod {
        case .Patches:
            return estro.getSiteName()
        case .Injections:
            if let suggestedSite = siteSchedule.suggest(changeIndex: setSI) {
                return suggestedSite.name
            }
            fallthrough
        default:
            return nil
        }
    }
}
