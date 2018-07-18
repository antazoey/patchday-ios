//
//  SuggestSiteFunctionality.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/5/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//
import Foundation
import PDKit

public struct SuggestedSiteStruct {
    var index = -1
    var site: MOSite?
}

internal class SiteSuggester {
    
    // MARK: - Primary function
    
    internal static func getSuggestedSiteStruct() -> SuggestedSiteStruct? {
        let sites = ScheduleController.siteController.siteArray
        if let i = suggest(), i >= 0 && i < sites.count {
            var suggestStruct = SuggestedSiteStruct()
            suggestStruct.index = i
            suggestStruct.site = sites[i]
            return suggestStruct
        }
        return nil
    }
    
    internal static func getSuggestedSite() -> MOSite? {
        let sites = ScheduleController.siteController.siteArray
        if let i = suggest(), i >= 0 && i < sites.count {
            return sites[i]
        }
        return nil
    }
    
    internal static func suggest() -> Index? {
        if let suggestedSiteIndex = ScheduleController.siteController.getNextSiteIndex() {
            return suggestedSiteIndex
        }
        return nil
    }
}
