//
//  SuggestedPatchLocation.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/5/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation

class SuggestedPatchLocation {
    
    static func suggest(patchIndex: Int) -> String {
        
        let currentLocations: [String] = makeArrayOfLocations()
        var suggestedLocation = ""
        // four patches:
        if currentLocations.count == 4 {
            // consider custom locations
            if doesExistCustomIn(locations: currentLocations) {
                let nonCustomCurrentLocations = makeArrayOfNonCustomLocations(fromCurrentLocations: currentLocations)
                suggestedLocation = getLocationInGeneral(notInCurrent: nonCustomCurrentLocations)
            }
            // no custom locations
            else {
                // consider all general spaces are occupied
                // if true, return the current location of the patch
                if allSpacesOccupied(currentLocations: currentLocations) {
                    suggestedLocation = PatchDataController.getPatch(forIndex: patchIndex)!.getLocation()
                }
                // some patches are in the same space, and some or one general location is available
                else {
                    suggestedLocation = getLocationInGeneral(notInCurrent: currentLocations)
                }
            }
        }
        else {
            suggestedLocation = getLocationInGeneral(notInCurrent: currentLocations)
        }
        return suggestedLocation
    }
    
    // called by suggest()
    // just gets an array of all the current locations
    private static func makeArrayOfLocations() -> [String] {
        var locationArray: [String] = []
        for i in 0...(PatchDataController.getPatches().count-1) {
            locationArray.append(PatchDataController.getPatches()[i].getLocation())
        }
        return locationArray
    }
    
    // called by suggest()
    // true if there exists a custom location currently
    private static func doesExistCustomIn(locations: [String]) -> Bool {
        for location in locations {
            if !PatchDayStrings.patchLocationNames.contains(location) {
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
            if PatchDayStrings.patchLocationNames.contains(currentLocation) {
                nonCustomLocations.append(currentLocation)
            }
        }
        return nonCustomLocations
    }
    
    // called by getLocationInGeneral(notInCurrent: [String])
    // return all locations in general that are not in current
    private static func compareGeneralNonCustomLocations(withCurrentNonCustomLocations: [String]) -> [String] {
        var locsInGeneralThatAreNotInCurrent: [String] = []
        let generalNonCustomLocations = PatchDayStrings.patchLocationNames
        for generalLoc in generalNonCustomLocations {
            if !withCurrentNonCustomLocations.contains(generalLoc) {
                locsInGeneralThatAreNotInCurrent.append(generalLoc)
            }
        }
        return locsInGeneralThatAreNotInCurrent
    }
    
    // called by suggest()
    // get's an arbitrary general location that is not currently occupied
    private static func getLocationInGeneral(notInCurrent: [String]) -> String {
        let choices = compareGeneralNonCustomLocations(withCurrentNonCustomLocations: notInCurrent)
        return choices[0]
    }
    
    // called by suggest()
    private static func allSpacesOccupied(currentLocations: [String]) -> Bool {
        if compareGeneralNonCustomLocations(withCurrentNonCustomLocations: currentLocations).count == 0 {
            return true
        }
        return false
    }
    
}
