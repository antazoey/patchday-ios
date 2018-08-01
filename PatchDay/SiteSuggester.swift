//
//  SuggestSiteFunctionality.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/5/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//
import Foundation
import PDKit



internal class SiteSuggester {
    
    // MARK: - Primary function
    
    internal static func getSuggestedSite() -> MOSite? {
        let sites = ScheduleController.siteController.siteArray
        if let i = ScheduleController.siteController.getNextSiteIndex() {
            return sites[i]
        }
        return nil
    }

}
