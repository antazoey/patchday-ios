//
//  PatchSchedule.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/5/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation

class PatchSchedule {
    
    var patches = [Patch]()

    // constructors:  schedule can hold up to four patches
    
    init(){
    }
    
    init(patches: Patch...){
        for patch in patches{
            self.patches.append(patch)
        }
    }

    init(patches: [Patch]){
        for patch in patches{
            self.patches.append(patch)
        }
    }
    
    // end constructors
    
    // getters
    
    func getPatch(rank: Int) -> Patch {
        var patch = Patch()
        if rank < self.length(){
            patch = patches[rank]
        }
        return patch
    }
    
    func getPatchCount() -> Int {
        return self.patches.count
    }
    
    func length() -> Int {
        return patches.count
    }
    
    // END getters
    
    // MARK: return value methods
    
    func string() -> String {
        self.sort()
        var scheduleString = ""
        if self.getPatchCount() > 0 {
            for patch in patches {
                let location = patch.getLocation()
                scheduleString += location
                if location != "unplaced" {
                    scheduleString += (", " +
                    patch.getPatchDate().string() +
                        "\r\n")
                }
                else {
                    scheduleString += (" patch" + "\r\n")
                }
            }
        }
        else {
            scheduleString = "Empty Patch Schedule"
        }
        return scheduleString
    }
    
    func nextPatchWhenAndWhere() -> String {
        // makes an instructional String explaining where and when to change your patch
        var message = ""
        if patches.count > 0 {
            let nextPatch = self.oldestPatch()
            message = "Change the patch on your " + nextPatch.getLocation()
                + " and place it on your " + nextLocation() + " on " +
                nextPatch.getPatchDate().nextPatchDate()
        }
        return message
    }
    
    func oldestPatch() -> Patch {
        // find the patch with the oldest date
        var earliestPatch = patches[0]
        for patch in patches {
            if  patch.getPatchDate() < earliestPatch.getPatchDate(){
                earliestPatch = patch
            }
        }
        return earliestPatch
    }
    
    // end return value methods
    
    // MARK: modifiers
    
    func changePatch(){
        if self.length() != 0 {
            let changingPatch = oldestPatch()
            changingPatch.getPatchDate().progressToNow()
            changingPatch.setLocation(location: nextLocation())
        }
    }
    
    func sort() {
        self.patches.sort(by: <)
    }
    
    func append(newPatch: Patch) -> Void{
        self.patches.append(newPatch)
    }
    
    func remove(patchToRemove: Patch) {
        var placeMarker = 0;
        for patch in self.patches {
            if patch.string() == patchToRemove.string(){
                self.patches.remove(at: placeMarker)
            }
            placeMarker += 1
        }
    }
    
    // end modifiers
    
    // private functions
    
    private func nextLocation() -> String {
        // finds optimal location for next patch
        let oldestPatchLocation = oldestPatch().getLocation()
        var newLocation = ""
        
        // for only one patch in the schedule
        if patches.count == 1 {
            if oldestPatchLocation == "Left Buttock"{
                newLocation = "Right Buttock"
            }
            else if oldestPatchLocation == "Right Buttock" {
                newLocation = "Left Stomach"
            }
            else if oldestPatchLocation == "Left Stomach" {
                newLocation = "Right Stomach"
            }
            else if oldestPatchLocation == "Right Stomach" {
                newLocation = "Left Buttock"
            }
        }
            
            // for two or three patches in the schedule
        else if patches.count == 2 || patches.count == 3 {
            var locations = ["Left Buttock","Right Buttock","Left Stomach","Right Stomach"]
            for patch in patches {
                for i in 0...(locations.count-1) {
                    if locations[i] == patch.getLocation(){
                        locations.remove(at: i)
                        break
                    }
                }
            }
            newLocation = locations[0]
        }
            
            // for four patches in the schedule
        else if patches.count == 4 {
            newLocation = oldestPatchLocation
        }
        return newLocation
    }
    
    // Testing
    
    func printPatches(){
        for patch in patches {
            print(patch.string())
        }
    }
}
