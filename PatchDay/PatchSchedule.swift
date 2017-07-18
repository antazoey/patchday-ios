//
//  PatchSchedule.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/13/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation

public class PatchSchedule {
    
    // PatchSchedule is a class for querying the user's managed object array ([Patch]).  All of the patches in the user's current schedule form the PatchSchedule.  The PatchSchedule is used to suggest a location, as part of the "Suggest Location Functionality" mentioned on the SettingsViewController.  It also finds the oldest patch in the schedule, which is important when changing a patch in the PatchDataController.
    
    private var patches: [Patch]
    
    init(patches: [Patch]) {
        self.patches = patches
    }
    
    // MARK: - Suggest Patch Location
    
    // how to access the Suggest Patch Location Algorithm
    internal func suggestLocation(patchIndex: Int) -> String {
        return SuggestedPatchLocation.suggest(patchIndex: patchIndex, generalLocations: makeArrayOfLocations())
    }
    
    internal func makeArrayOfLocations() -> [String] {
        var locationArray: [String] = []
        for i in 0...(SettingsDefaultsController.getNumberOfPatchesInt() - 1) {
            if i < patches.count {
                let patch = patches[i]
                locationArray.append(patch.getLocation())
            }
        }
        return locationArray
    }
    
    // MARK: - Oldest Patch Related Methods
    
    public func getOldestPatch() -> Patch? {
        if patches.count > 0 {
            var oldestPatch: Patch = patches[0]
            if patches.count > 1 {
                for i in 1...(patches.count - 1) {
                    let patch = patches[i]
                    if let datePlaced = patch.getDatePlaced(), let oldDate = oldestPatch.getDatePlaced() {
                        if datePlaced < oldDate {
                            oldestPatch = patches[i]
                        }
                    }
                }
            }
            return oldestPatch
        }
        else {
            return nil
        }
    }
    
    public func getOldestPatchDate() -> Date? {
        if let oldestPatch = getOldestPatch(), let oldestPatchDate = oldestPatch.getDatePlaced() {
            return oldestPatchDate
        }
        return nil
    }
    
    public func getOldestPatchDateAsString() -> String? {
        if let oldestPatch = getOldestPatch() {
            return oldestPatch.getDatePlacedAsString()
        }
        return nil
    }
    
    public static func printSchedule(patches: [Patch]) {
        for patch in patches {
            print(patch.getLocation() + ", " + patch.getDatePlacedAsString())
        }
    }
    
    
    // MARK: - Query Bools
    
    public func scheduleHasNoDates() -> Bool {
        var allEmptyDates: Bool = true
        for i in 0...(patches.count - 1) {
            let patch = patches[i]
            if patch.getDatePlaced() != nil {
                allEmptyDates = false
                break
            }
        }
        return allEmptyDates
        
    }
    
    public func scheduleHasNoLocations() -> Bool {
        var allEmptyLocations: Bool = true
        for i in 0...(patches.count - 1){
            let patch = patches[i]
            if patch.getLocation() != "unplaced" {
                allEmptyLocations = false
                break
            }
        }
        return allEmptyLocations
    }
    
    public func scheduleIsEmpty() -> Bool {
        return scheduleHasNoDates() && scheduleHasNoLocations()
    }
    
    public func oldestPatchInScheduleHasNoDateAndIsCustomLocated() -> Bool {
        if let oldestPatch = getOldestPatch() {
            return oldestPatch.getDatePlaced() == nil && oldestPatch.isCustomLocated()
        }
        return false
    }
    
}
