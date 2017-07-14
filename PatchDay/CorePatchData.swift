//
//  CorePatchData.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/11/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData

class CorePatchData {

    
    // MARK: - Core Data stack
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: PatchDayStrings.patchData)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                PDAlertController.alertForPersistentStoreLoadError(error: error)
            }
        })
        return container
    }()
    
    // MARK: - Managed Object Array
    
    var userPatches: [Patch]
    
    init() {
        var patches: [Patch] = []
        for i in 0...(SettingsDefaultsController.getNumberOfPatchesInt() - 1) {
            if let userPatch = CorePatchData.createPatchFromCoreData(patchEntityNameIndex: i) {
                patches.append(userPatch)
            }
            else {
                let userPatch = CorePatchData.createGenericPatch(entityName: PatchDayStrings.patchEntityNames[i])
                patches.append(userPatch)
            }
            CorePatchData.saveContext()
        }
        // sort during init()
        patches.sort(by: <)
        self.userPatches = patches
        
    }
    
    // MARK: - Core Data Saving support
    
    static func saveContext () {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                PDAlertController.alertForCoreDataSaveError()
            }
        }
    }
    
    // MARK: - Public
    
    public func getPatch(forIndex: Int) -> Patch? {
        if forIndex < userPatches.count && forIndex >= 0 {
            return userPatches[forIndex]
        }
        return nil
    }
    
    public func setPatchLocation(patchIndex: Int, with: String) {
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
    
    public func setPatchDate(patchIndex: Int, with: Date) {
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
    
    public func setPatch(patchIndex: Int, patchDate: Date, location: String) {
        if let patch = getPatch(forIndex: patchIndex) {
            patch.setLocation(with: location)
            patch.setDatePlaced(withDate: patchDate)
        }
        CorePatchData.saveContext()
    }
    
    public func setPatch(with: Patch, patchIndex: Int) {
        if patchIndex < userPatches.count && patchIndex >= 0 {
            userPatches[patchIndex] = with
        }
        CorePatchData.saveContext()
    }
    
    public func resetPatchData() {
        for patch in userPatches {
            patch.reset()
        }
        CorePatchData.saveContext()
    }
    
    // MARK: Private functions
    
    static func createGenericPatch(entityName: String) -> Patch {
        if let patch = NSEntityDescription.insertNewObject(forEntityName: entityName, into: persistentContainer.viewContext) as? Patch {
            return patch
        }
        else {
            PDAlertController.alertForCoreDataError()
            return Patch()
        }
    }
    
    // called by PatchDataController.createPatches()
    private static func createPatchFromCoreData(patchEntityNameIndex: Int) -> Patch? {
        var userPatch: Patch?
        
        if let patchFetchRequest = createPatchFetch(patchEntityNameIndex: patchEntityNameIndex) {
            patchFetchRequest.propertiesToFetch = PatchDayStrings.patchPropertyNames
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
    private static func createPatchFetch(patchEntityNameIndex: Int) -> NSFetchRequest<Patch>? {
        return NSFetchRequest<Patch>(entityName: PatchDayStrings.patchEntityNames[patchEntityNameIndex])
    }
    
}
