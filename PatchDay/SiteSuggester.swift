//
//  SuggestSiteFunctionality.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/5/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//
import Foundation

internal class SiteSuggester {
    
    // Description: The "Suggest Patch Site" algorithm is an optional functionality that gives the user a site to place their next patch.  There are three main parts to it:  1.)  An array of general sites.  2.)  An array of current sites in the schedule. 3.) a suggest(scheduleIndex: Int, scheduleSites: [String]) method for returning the correct suggested site.
    
    // MARK: - Public
    internal static var scheduleSites: [String] = []
    internal static var currentSites: [String] = []
    
    // MARK: - Primary function
    
    internal static func suggest(estrogenScheduleIndex: Int, currentSites: [String]) -> Int {
        
        if estrogenScheduleIndex >= UserDefaultsController.getQuantityInt() || estrogenScheduleIndex < 0 {
            return 0
        }
        
        self.currentSites = currentSites
        self.scheduleSites = ScheduleController.siteSchedule().siteNamesArray
        let currentSite = getCurrentSiteName(estrogenScheduleIndex)
        let suggestedSiteIndex = UserDefaultsController.getSiteIndex()
        
        if siteIsAvailable(siteName: self.scheduleSites[suggestedSiteIndex]) {
            return suggestedSiteIndex
        }
        else if let suggestedSiteIndex = getNextSiteIndexInScheduleThatIsAvailable(afterCurrentSite: currentSite) {
            return suggestedSiteIndex
        }
        return 0
    }
    
    // MARK: - Helper functions
    
    // Returns the schedule site from the CoreDataController with the given scheduleIndex
    internal static func getCurrentSiteName(_ index: Int) -> String {
        if let estro = ScheduleController.coreDataController.getEstrogenDeliveryMO(forIndex: index) {
            return estro.getLocation()
        }
        return PDStrings.placeholderStrings.unplaced
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
    
    private static func siteIsAvailable(siteName: String) -> Bool {
        let timesSiteAppearsInSchedule = howManyTimesSiteAppears(siteName: siteName, siteList: self.scheduleSites)
        let timesSiteAppearsInCurrent = howManyTimesSiteAppears(siteName: siteName, siteList: self.currentSites)
        
        return timesSiteAppearsInCurrent < timesSiteAppearsInSchedule
    }

    // Picks the next available open general site starting at the index of current site.
    private static func getNextSiteIndexInScheduleThatIsAvailable(afterCurrentSite: String) -> Int? {
        let availableSites = scheduleSites.filter() {
            siteIsAvailable(siteName: $0)
        }
        if availableSites.count > 0 {
            return scheduleSites.index(of: availableSites[0])
        }
        return nil
    }
}
