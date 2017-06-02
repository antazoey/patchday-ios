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

let moProperties = ["patch_a","patch_b","patch_c","patch_d"]
let entityName = "PatchDataStrings"

class PatchDataController: NSObject {
    
    // Data manipulation functions
    
    static var workingPatchStringsMO: PatchDataStringsMO?
    
    // MARK: - Core Data stack
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "patchData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    static func saveContext () {
        if PatchDataController.persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // USER Functions
    
    // This is how the user controls the PatchSchedule object
    static func patchSchedule() -> PatchSchedule {
        var patchSchedule = PatchSchedule()
        // Update the working PatchStringsMO from core data
        self.workingPatchStringsMO = self.getPatchDataStringsMOFromCoreData()
        // make Patch objects from the strings from the working PatchStringsMO
        if self.getStoredPatchData() != nil {
            let patches = self.makePatchesFromPatchStrings(storedPatchData: self.getStoredPatchData()!)
            patchSchedule = PatchSchedule(patches: patches)
        }
        // Return a PatchSchedule object form created Patch objects
        return patchSchedule
    }
    
    static func changePatch() {
        // Look at the stored data...
        let patchSchedule = self.patchSchedule()
        // change the oldest patch...
        patchSchedule.changePatch()
        // update stored data.
        workingPatchStringsMO?.append(patches: patchSchedule.patches)
        saveContext()
    }
    
    static func resetPatchData() {
        self.workingPatchStringsMO?.reset()
        self.saveContext()
    }
    
    
    // MARK: - PD Data Controller Methods (Private)
    
    private static func getPatchDataStringsMOFromCoreData() -> PatchDataStringsMO? {
        // Look at the stored entity: PatchDataStrings
        var patchDataStringsMO: PatchDataStringsMO?
        let fetchRequest = NSFetchRequest<PatchDataStringsMO>(entityName: entityName)
        // determine number of patches based on how many properties to fetch
        fetchRequest.propertiesToFetch = self.getPropertiesToFetch()
        do {
            // load user data if it exists
            let patchDataStringsMORequest = try persistentContainer.viewContext.fetch(fetchRequest)
            if patchDataStringsMORequest.count > 0 {
                patchDataStringsMO = patchDataStringsMORequest[0]
            }
            // if there is no data, the view controller displays an image, therefore return nil
            else {
                return nil
            }
        }
        catch {
            print("PatchData Fetch Request Failed")
        }
        return patchDataStringsMO
    }
    
    // get the properties to fetch from core data based on number of patches
    private static func getPropertiesToFetch() -> [String] {
        let numberOfPropertiesToFetch = Int(SettingsDefaultsController.getNumberOfPatches())!
        var propertiesToFetch: [String] = []
        for i in 0...(numberOfPropertiesToFetch-1) {
            propertiesToFetch.append(moProperties[i])
        }
        return propertiesToFetch
        
    }
    
    private static func getStoredPatchData() -> [String]? {
        // Look at the stored entity: PatchSchedule from self's attribute
        return (self.workingPatchStringsMO?.getAllData())
    }
    
    private static func makePatchesFromPatchStrings(storedPatchData: [String?]) -> [Patch] {
        var patches: [Patch] = []
        let numberOfPatches = Int(SettingsDefaultsController.getNumberOfPatches())!
        for i in 0...(numberOfPatches - 1) {
            let data = storedPatchData[i]
            patches.append((Patch.patch(from: data!)))
        }
        return patches
        
    }

}
