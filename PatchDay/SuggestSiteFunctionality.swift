//
//  SuggestSiteFunctionality.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/5/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation

internal class SLF {
    
    // Description: The "Suggest Patch Site" algorithm is an optional functionality that gives the user a site to place their next patch.  There are three main parts to it:  1.)  An array of general sites.  2.)  An array of current sites in the schedule. 3.) a suggest(scheduleIndex: Int, generalSites: [String]) method for returning the correct suggested site.
    
    // MARK: - Public

    internal static var generalSites: [String] = []
 
    internal static var currentSites: [String] = []
    
    internal static func suggest(scheduleIndex: Int, generalSites: [String]) -> String {
        
        currentSites = generalSites
        self.generalSites = (UserDefaultsController.usingPatches()) ? PDStrings.siteNames.patchSiteNames : PDStrings.siteNames.injectionSiteNames
        
        if scheduleIndex >= UserDefaultsController.getQuantityInt() || scheduleIndex < 0 {
            return ""
        }
        
        setCurrentSites(with: CoreDataController.schedule().makeArrayOfSites())
        let currentSite = getCurrentSite(scheduleIndex: scheduleIndex)
        var suggestedSite = ""
        
        // I. FOUR PATCHES:
        if currentSites.count == 4 {
            
            // a.) case: existing custom sites
            if doesExistCustomIn(sites: currentSites) {
                suggestedSite = getNextSiteInGeneralThatIsAvailable(afterCurrentSite: currentSite)
            }
                
            // b.) case: no existing custom sites
            else {
                // i.) all general spaces are occupied. ->  (suggestedSite = currentSite)
                if allGeneralSitesOccupied(currentSites: currentSites) {
                    suggestedSite = CoreDataController.coreData.getEstrogenDeliveryMO(forIndex: scheduleIndex)!.getLocation()
                }
                // ii.) some patches are in the same space. -> arbitrary available generalSite (since there are likely not be but 1 or 2, and having 4 patches all together in spot is not a likely situation. if it were, this algthm would slowly dispense them out.
                else {
                    suggestedSite = getNextSiteInGeneralThatIsAvailable(afterCurrentSite: currentSite)
                }
            }
        }
        
        // II.) THREE PATCHES:
            
        else if currentSites.count == 3 {
            // if 3 patches all in the general sites, pick the one general site that is free
            let nonCustomCurrentSites = makeArrayOfNonCustomSites(fromCurrentSites: currentSites)
            suggestedSite = getArbitrarySiteInGeneral(notInCurrent: nonCustomCurrentSites)
        }
        // ALL OTHER PATCH COUNTS:
        else {
            suggestedSite = getNextSiteInGeneralThatIsAvailable(afterCurrentSite: currentSite)
        }
        return suggestedSite
    }
    
    // keeps the currentSites current
    internal static func setCurrentSites(with: [String]) {
        currentSites = with
    }
    
    internal static func getCurrentSitesCount() -> Int {
        return CoreDataController.schedule().makeArrayOfSites().count
    }
    
    // returns 1 + an index value in the list of general sites
    internal static func getNextGeneralIndex(fromIndex: Int, totalNumberOfGeneralSiteOptions: Int) -> Int {
        let capIndex = totalNumberOfGeneralSiteOptions-1
        if fromIndex < capIndex {
            return fromIndex + 1
        }
        else {
            return fromIndex%capIndex
        }
    }
    
    // returns the current site from the CoreDataController with the given scheduleIndex
    internal static func getCurrentSite(scheduleIndex: Int) -> String {
        if let estro = CoreDataController.coreData.getEstrogenDeliveryMO(forIndex: scheduleIndex) {
            return estro.getLocation()
        }
        return PDStrings.placeholderStrings.unplaced
    }
    
    private static func getNextIndexOfOrder() {
        _ = currentSites.count
    }
    
    // returns the index of the patchSite in the general list. if the site isn't general, it returns -1
    public static func getCurrentIndexInGeneral(estroSite: String) -> Int {
        if let index = generalSites.index(of: estroSite) {
            return index
        }
        else {
            return -1
        }
    }
    
    // MARK: - private
    
    // called by suggest()
    // true if there exists a custom site currently
    private static func doesExistCustomIn(sites: [String]) -> Bool {
        for site in sites {
            if !generalSites.contains(site) {
                return true
            }
        }
        return false
    }
    
    // called by suggest()
    // returns an array of all the non-custom sites
    private static func makeArrayOfNonCustomSites(fromCurrentSites: [String]) -> [String] {
        var nonCustomSites: [String] = []
        for currentSite in fromCurrentSites {
            if generalSites.contains(currentSite) {
                nonCustomSites.append(currentSite)
            }
        }
        return nonCustomSites
    }
    
    // called by getSiteInGeneral(notInCurrent: [String])
    // return all sites in general that are not in current
    private static func compareGeneralNonCustomSites(withCurrentNonCustomSites: [String]) -> [String] {
        var locsInGeneralThatAreNotInCurrent: [String] = []
        for generalLoc in generalSites {
            if !withCurrentNonCustomSites.contains(generalLoc) {
                locsInGeneralThatAreNotInCurrent.append(generalLoc)
            }
        }
        return locsInGeneralThatAreNotInCurrent
    }
    
    // called by suggest()
    // get's an arbitrary general site that is not currently occupied
    private static func getArbitrarySiteInGeneral(notInCurrent: [String]) -> String {
        let choices = compareGeneralNonCustomSites(withCurrentNonCustomSites: notInCurrent)
        return choices[0]
    }
    
    // called by suggest()
    private static func allGeneralSitesOccupied(currentSites: [String]) -> Bool {
        // return if there are no sites in ["Right Stom..", "Left Stom..", "Right Butt..", "Left Butt"] that are in the [current sites]
        if compareGeneralNonCustomSites(withCurrentNonCustomSites: currentSites).count == 0 {
            return true
        }
        return false
    }
    
    private static func existsRepeatingGeneralSitesInCurrentSites(currentSites: [String]) -> Bool {
        for i in 0...(currentSites.count-1) {
            let testLoc = currentSites[i]
            for j in i...(currentSites.count-1) {
                let nextLoc = currentSites[j]
                if nextLoc == testLoc {
                    return true
                }
            }
        }
        return false
    }
    
    // returns the number of times a given site appears in the current site
    private static func howManyTimesSiteAppearsInCurrentSites(generalSite: String) -> Int {
        var count = 0
        for i in 0...(currentSites.count-1) {
            if currentSites[i] == generalSite {
                count += 1
            }
        }
        return count
    }
    
    // returns if the given site is repeated
    private static func isRepeatedInGeneralSites(thisSite: String) -> Bool {
        return howManyTimesSiteAppearsInCurrentSites(generalSite: thisSite) >= 2
    }
    
    // picks the next available open general site starting at the index of current site.
    private static func getNextSiteInGeneralThatIsAvailable(afterCurrentSite: String) -> String {
        let scheduleIndexAsInGeneral = getCurrentIndexInGeneral(estroSite: afterCurrentSite)
        var testIndex = getNextGeneralIndex(fromIndex: scheduleIndexAsInGeneral, totalNumberOfGeneralSiteOptions: generalSites.count)
        var testSite = generalSites[testIndex]
        while currentSites.contains(testSite) {
            testIndex = getNextGeneralIndex(fromIndex: testIndex, totalNumberOfGeneralSiteOptions: generalSites.count)
            testSite = generalSites[testIndex]
        }
        return testSite
    }
    
}
