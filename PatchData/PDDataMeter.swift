//
//  PDSharedData.swift
//  PatchData
//
//  Created by Juliya Smith on 12/21/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class PDDataMeter: PDDataMeting {
    
    public var defaults: UserDefaults? {
        get { return UserDefaults(suiteName: "group.com.patchday.todaydata") }
    }

    /// Sets hormone data for other apps, such as the PatchDay Today widget.
    public func broadcastRelevantHormoneData(oldestHormone: Hormonal,
                                              nextSuggestedSite: SiteName,
                                              interval: ExpirationIntervalUD,
                                              deliveryMethod: DeliveryMethodUD) {
        var siteName: SiteName
        switch deliveryMethod.value {
        case .Patches:
            siteName = oldestHormone.siteName
        case .Injections:
            siteName = nextSuggestedSite
        }
        if let defs = defaults {
            defs.set(siteName, forKey: PDStrings.TodayKey.nextEstroSiteName.rawValue)
            defs.set(oldestHormone.date, forKey: PDStrings.TodayKey.nextEstroDate.rawValue)
        }
    }

    /// Sets MOPill data for PatchDay Today widget.
    public func broadcastRelevantPillData(nextPill: Swallowable) {
        if let defs = defaults {
            defs.set(nextPill.name, forKey: PDStrings.TodayKey.nextPillToTake.rawValue)
            defs.set(nextPill.due, forKey: PDStrings.TodayKey.nextPillTakeTime.rawValue)
        }
    }
}
