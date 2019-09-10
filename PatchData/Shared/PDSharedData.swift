//
//  PDSharedData.swift
//  PatchData
//
//  Created by Juliya Smith on 12/21/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class PDSharedData: NSObject, PDDataSharing {
    
    public let defaults = UserDefaults(suiteName: "group.com.patchday.todaydata")
    
    override public var description: String {
        return """
               PDSharedData is a class of getters and setters
               for data that is accessible to other apps,
               namely: the PatchDay Today Widget."
               """
    }
    
    public override init() {
        if defaults == nil {
            print("Unable to load shared defaults.")
        }
    }

    /// Sets MOEstrogen data for PatchDay Today widget.
    public func setEstrogenDataForToday(latestExpiredEstrogen: Hormonal,
                                        nextSuggestedSite: SiteName,
                                        interval: ExpirationIntervalUD,
                                        deliveryMethod: DeliveryMethodUD,
                                        index: Index,
                                        setSiteIndex: @escaping (Int) -> ()) {
        var siteName: SiteName
        switch deliveryMethod.value {
        case .Patches:
            siteName = latestExpiredEstrogen.siteName
        case .Injections:
            siteName = nextSuggestedSite
        }
        defaults?.set(siteName, forKey: PDStrings.TodayKey.nextEstroSiteName.rawValue)
        defaults?.set(latestExpiredEstrogen.date, forKey: PDStrings.TodayKey.nextEstroDate.rawValue)
    }

    /// Sets MOPill data for PatchDay Today widget.
    public func setPillDataForToday(nextPill: Swallowable) {
        if let defs = defaults {
            defs.set(nextPill.name, forKey: PDStrings.TodayKey.nextPillToTake.rawValue)
            defs.set(nextPill.due, forKey: PDStrings.TodayKey.nextPillTakeTime.rawValue)
        }
    }
}
