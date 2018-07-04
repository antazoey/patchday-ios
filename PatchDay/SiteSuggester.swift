//
//  SuggestSiteFunctionality.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/5/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//
import Foundation

typealias SiteName = String

internal class SiteSuggester {
    
    // Description: The "Suggest Patch Site" algorithm is an optional functionality that gives the user a site to place their next patch.  There are three main parts to it:  1.)  An array of general sites.  2.)  An array of current sites in the schedule. 3.) a suggest(scheduleIndex: Int, scheduleSites: [String]) method for returning the correct suggested site.
    
    // MARK: - Primary function
    
    internal static func suggest(currentEstrogenSiteSuggestingFrom estrogenSite: SiteName, currentSites: [SiteName], estrogenQuantity: Int, scheduleSites: [SiteName]) -> Int? {
        
        let suggestedSiteIndex = UserDefaultsController.getSiteIndex()
        
        let indexIsInBounds = suggestedSiteIndex >= 0 && suggestedSiteIndex < scheduleSites.count
        if indexIsInBounds && siteIsAvailable(siteName: scheduleSites[suggestedSiteIndex], scheduleSites: scheduleSites, currentSites: currentSites) {
            return suggestedSiteIndex
        }
        else if let availableSiteIndex = getNextSiteIndexInScheduleThatIsAvailable(afterCurrentSite: estrogenSite, scheduleSites: scheduleSites, currentSites: currentSites) {
            return availableSiteIndex
        }
        
        if let unchangedScheduleIndex = scheduleSites.index(of: estrogenSite) {
            return unchangedScheduleIndex
        }
        
        return nil
        
    }
    
    // MARK: - private

    // Returns the number of times a given site appears in the current sites.
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

    // Picks the next available open general site starting at the index of current site.
    private static func getNextSiteIndexInScheduleThatIsAvailable(afterCurrentSite: String, scheduleSites: [SiteName], currentSites: [SiteName]) -> Int? {
        let availableSites = scheduleSites.filter() {
            siteIsAvailable(siteName: $0, scheduleSites: scheduleSites, currentSites: currentSites)
        }
        if availableSites.count > 0 {
            
            return scheduleSites.index(of: availableSites[0])
        }
        return nil
    }
}
