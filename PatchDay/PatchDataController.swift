//
//  PatchDataController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/13/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData
import UIKit

// MARK: Strings

class PatchDataController: NSObject {
    
    // Class for handling getting and setting patch data, such as datePlaced and location for each patch.
    // Also has access to a PatchSchedule object for quering the patch data collectively
    
    static internal var corePatchData: CorePatchData = CorePatchData()
    
    // MARK: - Public
    
    public static func patchSchedule() -> PatchSchedule {
        return PatchSchedule(patches: self.corePatchData.userPatches)
    }
    
    public static func save() {
        // save core data
        CorePatchData.saveContext()
    }
    
    public static func getPatch(index: Int) -> Patch? {
        return PatchDataController.corePatchData.getPatch(forIndex: index)
    }
    
    public static func setPatchLocation(patchIndex: Int, with: String) {
        self.corePatchData.setPatchLocation(patchIndex: patchIndex, with: with)
        corePatchData.sortSchedule()
        save()
    }
    
    public static func setPatchDate(patchIndex: Int, with: Date) {
        self.corePatchData.setPatchDate(patchIndex: patchIndex, with: with)
        corePatchData.sortSchedule()
        save()
    }
    
    public static func setPatch(patchIndex: Int, patchDate: Date, location: String) {
        self.corePatchData.setPatch(patchIndex: patchIndex, patchDate: patchDate, location: location)
        corePatchData.sortSchedule()
        save()
    }
    
    public static func setPatch(with: Patch, patchIndex: Int) {
        self.corePatchData.setPatch(with: with, patchIndex: patchIndex)
        corePatchData.sortSchedule()
        save()
    }
    
    public static func resetPatch(forIndex: Int) {
        if let patch = getPatch(index: forIndex) {
            patch.reset()
        }
    }
    
    public static func resetPatchData() {
        self.corePatchData.resetPatchData()
    }
    
    // MARK: - called by notification
    
    public static func changePatchFromNotification(patchIndex: Int) {
        if getPatch(index: patchIndex) != nil {
            let suggestedLocation = SuggestedPatchLocation.suggest(patchIndex: patchIndex)
            let suggestDate = Date()
            setPatch(patchIndex: patchIndex, patchDate: suggestDate, location: suggestedLocation)
            save()
        }
    }
    
}
