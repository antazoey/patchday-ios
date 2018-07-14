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
    
    // Description: The "Suggest Patch Site" algorithm is an optional functionality that gives the user a site to place their next patch.  There are three main parts to it:  1.)  An array of default sites.  2.)  An array of current sites in the schedule. 3.) a suggest(...) method for returning the correct suggested site.
    
    // MARK: - Primary function
    
    internal static func getSuggestedSiteStruct() -> SuggestedSiteStruct? {
        let sites = ScheduleController.siteController.siteArray
        if let i = suggest(currentSites: ScheduleController.getCurrentSiteNamesInEstrogenSchedule(), estrogenQuantity: UserDefaultsController.getQuantityInt(), scheduleSites: ScheduleController.siteController.getScheduleSiteNames()), i >= 0 && i < sites.count {
            var suggestStruct = SuggestedSiteStruct()
            suggestStruct.index = i
            suggestStruct.site = sites[i]
            return suggestStruct
        }
        return nil
    }
    
    internal static func getSuggestedSite() -> MOSite? {
        let sites = ScheduleController.siteController.siteArray
        if let i = suggest(currentSites: ScheduleController.getCurrentSiteNamesInEstrogenSchedule(), estrogenQuantity: UserDefaultsController.getQuantityInt(), scheduleSites: ScheduleController.siteController.getScheduleSiteNames()), i >= 0 && i < sites.count {
            return sites[i]
        }
        return nil
    }
    
    internal static func suggest(currentSites: [SiteName], estrogenQuantity: Int, scheduleSites: [SiteName]) -> Index? {
        
        let suggestedSiteIndex = UserDefaultsController.getSiteIndex()
        
        let indexIsInBounds = suggestedSiteIndex >= 0 && suggestedSiteIndex < scheduleSites.count
        if indexIsInBounds && siteIsAvailable(siteName: scheduleSites[suggestedSiteIndex], scheduleSites: scheduleSites, currentSites: currentSites) {
            
            return suggestedSiteIndex
        }
            
        else if let availableSiteIndex = getNextSiteIndexInScheduleThatIsAvailable(scheduleSites: scheduleSites, currentSites: currentSites) {
            return availableSiteIndex
        }
        
        return nil
        
    }
    
    // MARK: - private

    /// Returns the number of times a given site appears in the current sites.
    private static func howManyTimesSiteAppears(siteName: String, siteList: [String]) -> Int {
        return siteList.reduce(0, {
            count, word in
            let toAdd = (word == siteName) ? 1 : 0
            return count + toAdd
        })
    }
    
    private static func siteIsAvailable(siteName: String, scheduleSites: [SiteName], currentSites: [SiteName]) -> Bool {
        let timesSiteAppearsInSchedule = howManyTimesSiteAppears(siteName: siteName, siteList: scheduleSites)
        let timesSiteAppearsInCurrent = howManyTimesSiteAppears(siteName: siteName, siteList: currentSites)
        
        return timesSiteAppearsInCurrent < timesSiteAppearsInSchedule
    }

    /// Picks the next available open default site starting at the index of current site.
    private static func getNextSiteIndexInScheduleThatIsAvailable(scheduleSites: [SiteName], currentSites: [SiteName]) -> Int? {
        let availableSites = scheduleSites.filter() {
            siteIsAvailable(siteName: $0, scheduleSites: scheduleSites, currentSites: currentSites)
        }
        if availableSites.count > 0 {
            
            return scheduleSites.index(of: availableSites[0])
        }
        return nil
    }
    
}
