//
//  SuggestedPatchLocation.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/5/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation

internal class SuggestedPatchLocation {
    
    // The "Suggest Patch Location" algorithm is an optional functionality that gives the user a location to place their next patch.  There are three main parts to it:  1.)  An array of general locations.  2.)  An array of current locations in the patch schedule. 3.) a suggest(patchIndex: Int, generalLocations: [String]) method for returning the correct suggested location.
    
    // MARK: - Public
    
    internal static var generalLocations = PDStrings.patchLocationNames
    
    internal static var currentLocations: [String] = []
    
    internal static func suggest(patchIndex: Int, generalLocations: [String]) -> String {
        
        currentLocations = generalLocations
        
        if patchIndex >= SettingsDefaultsController.getNumberOfPatchesInt() || patchIndex < 0 {
            return ""
        }
        
        setCurrentLocations(with: PatchDataController.patchSchedule().makeArrayOfLocations())
        
        let currentLocation = getCurrentLocation(patchIndex: patchIndex)
        
        var suggestedLocation = ""
        
        // I. FOUR PATCHES:
        if currentLocations.count == 4 {
            
            // a.) case: existing custom locations
            if doesExistCustomIn(locations: currentLocations) {
                suggestedLocation = getNextLocationInGeneralThatIsAvailable(afterCurrentLocation: currentLocation)
            }
                
            // b.) case: no existing custom locations
            else {
                // i.) all general spaces are occupied. ->  (suggestedLocation = currentLocation)
                if allGeneralLocationsOccupied(currentLocations: currentLocations) {
                    suggestedLocation = PatchDataController.getPatch(index: patchIndex)!.getLocation()
                }
                // ii.) some patches are in the same space. -> arbitrary available generalLocation (since there are likely not be but 1 or 2, and having 4 patches all together in spot is not a likely situation. if it were, this algthm would slowly dispense them out.
                else {
                    suggestedLocation = getNextLocationInGeneralThatIsAvailable(afterCurrentLocation: currentLocation)
                }
            }
        }
        
        // II.) THREE PATCHES:
            
        else if currentLocations.count == 3 {
            // if 3 patches all in the general locations, pick the one general location that is free
            let nonCustomCurrentLocations = makeArrayOfNonCustomLocations(fromCurrentLocations: currentLocations)
            suggestedLocation = getArbitraryLocationInGeneral(notInCurrent: nonCustomCurrentLocations)
        }
        // ALL OTHER PATCH COUNTS:
        else {
            suggestedLocation = getNextLocationInGeneralThatIsAvailable(afterCurrentLocation: currentLocation)
        }
        return suggestedLocation
    }
    
    // keeps the currentLocations current
    internal static func setCurrentLocations(with: [String]) {
        currentLocations = with
    }
    
    internal static func getCurrentLocationsCount() -> Int {
        return PatchDataController.patchSchedule().makeArrayOfLocations().count
    }
    
    // returns 1 + an index value (modularly) in the list of general locations
    internal static func getNextGeneralIndex(fromIndex: Int, totalNumberOfGeneralLocationOptions: Int) -> Int {
        let capIndex = totalNumberOfGeneralLocationOptions-1
        if fromIndex < capIndex {
            return fromIndex + 1
        }
        else {
            return fromIndex%capIndex
        }
    }
    
    // returns the current location from the PatchDataController with the given patchIndex
    internal static func getCurrentLocation(patchIndex: Int) -> String {
        if let patch = PatchDataController.getPatch(index: patchIndex) {
            return patch.getLocation()
        }
        return PDStrings.unplaced_string
    }
    
    private static func getNextIndexOfOrder() {
        _ = currentLocations.count
    }
    
    // returns the index of the patchLocation in the general list. if the location isn't general, it returns -1
    public static func getCurrentIndexInGeneral(patchLocation: String) -> Int {
        if let index = generalLocations.index(of: patchLocation) {
            return index
        }
        else {
            return -1
        }
    }
    
    // MARK: - private
    
    // called by suggest()
    // true if there exists a custom location currently
    private static func doesExistCustomIn(locations: [String]) -> Bool {
        for location in locations {
            if !generalLocations.contains(location) {
                return true
            }
        }
        return false
    }
    
    // called by suggest()
    // returns an array of all the non-custom locations
    private static func makeArrayOfNonCustomLocations(fromCurrentLocations: [String]) -> [String] {
        var nonCustomLocations: [String] = []
        for currentLocation in fromCurrentLocations {
            if generalLocations.contains(currentLocation) {
                nonCustomLocations.append(currentLocation)
            }
        }
        return nonCustomLocations
    }
    
    // called by getLocationInGeneral(notInCurrent: [String])
    // return all locations in general that are not in current
    private static func compareGeneralNonCustomLocations(withCurrentNonCustomLocations: [String]) -> [String] {
        var locsInGeneralThatAreNotInCurrent: [String] = []
        for generalLoc in generalLocations {
            if !withCurrentNonCustomLocations.contains(generalLoc) {
                locsInGeneralThatAreNotInCurrent.append(generalLoc)
            }
        }
        return locsInGeneralThatAreNotInCurrent
    }
    
    // called by suggest()
    // get's an arbitrary general location that is not currently occupied
    private static func getArbitraryLocationInGeneral(notInCurrent: [String]) -> String {
        let choices = compareGeneralNonCustomLocations(withCurrentNonCustomLocations: notInCurrent)
        return choices[0]
    }
    
    // called by suggest()
    private static func allGeneralLocationsOccupied(currentLocations: [String]) -> Bool {
        // return if there are no locations in ["Right Stom..", "Left Stom..", "Right Butt..", "Left Butt"] that are in the [current locations]
        if compareGeneralNonCustomLocations(withCurrentNonCustomLocations: currentLocations).count == 0 {
            return true
        }
        return false
    }
    
    private static func existsRepeatingGeneralLocationsInCurrentLocations(currentLocations: [String]) -> Bool {
        for i in 0...(currentLocations.count-1) {
            let testLoc = currentLocations[i]
            for j in i...(currentLocations.count-1) {
                let nextLoc = currentLocations[j]
                if nextLoc == testLoc {
                    return true
                }
            }
        }
        return false
    }
    
    // returns the number of times a given location appears in the current location
    private static func howManyTimesLocationAppearsInCurrentLocations(generalLocation: String) -> Int {
        var count = 0
        for i in 0...(currentLocations.count-1) {
            if currentLocations[i] == generalLocation {
                count += 1
            }
        }
        return count
    }
    
    // returns if the given location is repeated
    private static func isRepeatedInGeneralLocations(thisLocation: String) -> Bool {
        return howManyTimesLocationAppearsInCurrentLocations(generalLocation: thisLocation) >= 2
    }
    
    // picks the next available open general location starting at the index of current location.
    private static func getNextLocationInGeneralThatIsAvailable(afterCurrentLocation: String) -> String {
        let patchIndexAsInGeneral = getCurrentIndexInGeneral(patchLocation: afterCurrentLocation)
        var testIndex = getNextGeneralIndex(fromIndex: patchIndexAsInGeneral, totalNumberOfGeneralLocationOptions: generalLocations.count)
        var testLocation = generalLocations[testIndex]
        while currentLocations.contains(testLocation) {
            testIndex = getNextGeneralIndex(fromIndex: testIndex, totalNumberOfGeneralLocationOptions: generalLocations.count)
            testLocation = generalLocations[testIndex]
        }
        return testLocation
    }
    
}
