//
//  CorePatchData.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/11/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData

internal class CorePatchData {
    
    // Description: CorePatchData is where the Core Data Stack is initialized. It is the internal class for interacting with core data to load and save patch attributes.  The core data model expresses Patch MOs with the attributes: datePlaced, serving as a Date object created on the day and time it was placed, and the location, a String representing the location of the patch.  CorePatchData is the class the PatchDataController, the UI class for the patch data, uses to load and save the patch data.  
    
    // MARK: - Managed Object Array
    
    internal var userPatches: [Patch]
    
    init() {
        var patches: [Patch] = []
        for i in 0...(SettingsDefaultsController.getNumberOfPatchesInt() - 1) {
            if let userPatch = CorePatchData.createPatchFromCoreData(patchEntityNameIndex: i) {
                patches.append(userPatch)
            }
            else {
                let userPatch = CorePatchData.createGenericPatch(patchEntityNameIndex: i)
                patches.append(userPatch)
            }
            CorePatchData.saveContext()
        }
        // sort during init()
        patches.sort(by: <)
        self.userPatches = patches
        
    }
    
    // MARK: - Public
    
    internal func sortSchedule() {
        self.userPatches.sort(by: <)
    }
    
    internal func getPatch(forIndex: Int) -> Patch? {
        // negative indices need not abide
        if forIndex < 0 {
            return nil
        }
            // no patch in userPatches forIndex (such as the NumberOfPatches changed), and it is still less than the numberOfPatches... then make a new patch and append and return it.
        else if forIndex < SettingsDefaultsController.getNumberOfPatchesInt() {
            if forIndex >= userPatches.count {
                let newPatch = CorePatchData.createGenericPatch(patchEntityNameIndex: forIndex)
                userPatches.append(newPatch)
                sortSchedule()
                return newPatch
            }
            else {
                return userPatches[forIndex]
            }
        }
        else {
            return nil
        }
    }
    
    internal func setPatchLocation(patchIndex: Int, with: String) {
        // attempt to set the Patch's location at given index
        // exit function if given bad patchIndex
        if patchIndex >= SettingsDefaultsController.getNumberOfPatchesInt() || patchIndex < 0 {
            return
        }
        // set location
        if let patch = getPatch(forIndex: patchIndex) {
            patch.setLocation(with: with)
        }
        CorePatchData.saveContext()
    }
    
    internal func setPatchDate(patchIndex: Int, with: Date) {
        if patchIndex >= SettingsDefaultsController.getNumberOfPatchesInt() || patchIndex < 0 {
            return
        }
        // attempt to set Patch's date at given index
        if let patch = getPatch(forIndex: patchIndex) {
            patch.setDatePlaced(withDate: with)
        }
        // if there is no Patch, make one there and set that one's date
        CorePatchData.saveContext()
    }
    
    internal func setPatch(patchIndex: Int, patchDate: Date, location: String) {
        if let patch = getPatch(forIndex: patchIndex) {
            patch.setLocation(with: location)
            patch.setDatePlaced(withDate: patchDate)
        }
        CorePatchData.saveContext()
    }
    
    internal func setPatch(with: Patch, patchIndex: Int) {
        if patchIndex < userPatches.count && patchIndex >= 0 {
            userPatches[patchIndex] = with
        }
        CorePatchData.saveContext()
    }
    
    internal func resetPatchData() {
        for patch in userPatches {
            patch.reset()
        }
        CorePatchData.saveContext()
    }
    
    // MARK: - Core Data stack
    
    internal static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: PDStrings.patchData)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                PDAlertController.alertForPersistentStoreLoadError(error: error)
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    internal static func saveContext () {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                PDAlertController.alertForCoreDataSaveError()
            }
        }
    }
    
    // MARK: Private functions
    
    static private func createGenericPatch(patchEntityNameIndex: Int) -> Patch {
        let entityName = PDStrings.patchEntityNames[patchEntityNameIndex]
        if let patch = NSEntityDescription.insertNewObject(forEntityName: entityName, into: persistentContainer.viewContext) as? Patch {
            return patch
        }
        else {
            PDAlertController.alertForCoreDataError()
            return Patch()
        }
    }
    
    // called by PatchDataController.createPatches()
    static private func createPatchFromCoreData(patchEntityNameIndex: Int) -> Patch? {
        var userPatch: Patch?
        if let patchFetchRequest = createPatchFetch(patchEntityNameIndex: patchEntityNameIndex) {
            patchFetchRequest.propertiesToFetch = PDStrings.patchPropertyNames
            do {
                // load user data if it exists
                let requestedPatch = try persistentContainer.viewContext.fetch(patchFetchRequest)
                if requestedPatch.count > 0 {
                    userPatch = requestedPatch[0]
                }
            }
            catch {
                // no alert needed here (calling function will automatically create a generic patch if we can't load one from core data)
                print("PatchData Fetch Request Failed")
            }
        }
        return userPatch
    }
    
    // called by PatchDataController.createPatchFromCoreData() to make a FetchRequest
    static private func createPatchFetch(patchEntityNameIndex: Int) -> NSFetchRequest<Patch>? {
        return NSFetchRequest<Patch>(entityName: PDStrings.patchEntityNames[patchEntityNameIndex])
    }
    
}
