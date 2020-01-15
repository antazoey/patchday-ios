//
//  PDSharedData.swift
//  PatchData
//
//  Created by Juliya Smith on 12/21/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class DataSharer: DataSharing {
    
    public var defaults: UserDefaults? {
        UserDefaults(suiteName: "group.com.patchday.todaydata")
    }

    public func shareRelevantHormoneData(
        oldestHormone: Hormonal,
        displayedSiteName: SiteName,
        interval: ExpirationIntervalUD,
        deliveryMethod: DeliveryMethodUD
    ) {
        if let defs = defaults {
            defs.set(displayedSiteName, forKey: PDStrings.TodayKey.nextHormoneSiteName.rawValue)
            defs.set(oldestHormone.date, forKey: PDStrings.TodayKey.nextHormoneDate.rawValue)
        }
    }

    /// Sets MOPill data for PatchDay Today widget.
    public func shareRelevantPillData(nextPill: Swallowable) {
        if let defs = defaults {
            defs.set(nextPill.name, forKey: PDStrings.TodayKey.nextPillToTake.rawValue)
            defs.set(nextPill.due, forKey: PDStrings.TodayKey.nextPillTakeTime.rawValue)
        }
    }
}
