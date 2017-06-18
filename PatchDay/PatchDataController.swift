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
    
    // MARK: - Core Data stack
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: PatchDayStrings.patchData)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Managed Object Array
    
    static var patches: [Patch] = {
        var userPatches: [Patch] = []
        for i in 0...(getNumberOfPatches()-1) {
            var userPatch = createPatchFromCoreData(patchEntityNameIndex: i)
            // handles the case where there was never a Patch init() in core data
            if userPatch == nil {
                userPatch = createGenericPatch(entityName: PatchDayStrings.patchEntityNames[i])
                saveContext()
            }
            userPatches.append(userPatch!)
        }
        return userPatches
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

    // MARK: ints
    
    public static func getNumberOfPatches() -> Int {
        return Int(SettingsController.getNumberOfPatchesInt())
    }
    
    public static func getPatches() -> [Patch] {
        return self.patches
    }
    
    
    // MARK: - patches
    
    public static func getOldestPatch() -> Patch {
        var oldestPatch: Patch = patches[0]
        if self.getNumberOfPatches() > 1 {
            for i in 1...(patches.count-1) {
                if patches[i].getDatePlaced() != nil && oldestPatch.getDatePlaced() != nil {
                    if patches[i].getDatePlaced()! < oldestPatch.getDatePlaced()! {
                        oldestPatch = patches[i]
                    }
                }
            }
        }
        return oldestPatch
    }
    
    public static func getPatch(forIndex: Int) -> Patch? {
        var patch: Patch?
        if self.patches.count >= (forIndex+1) {
            patch = self.patches[forIndex]
        }
        return patch
    }
    
    // MARK: - strings
    
    public static func suggestLocation(patchIndex: Int) -> String {
        return SuggestedPatchLocation.suggest(patchIndex: patchIndex)
    }
    
    public static func notificationString(index: Int) -> String {
        let patch = self.getPatch(forIndex: index)!
        var locationNotificationPart = ""
        // for non-custom located patches
        if patch.isNotCustomLocated() {
            locationNotificationPart = PatchDayStrings.notificationIntros[patch.getLocation()]!
        }
        // for custom located patches
        else {
            locationNotificationPart = PatchDayStrings.notificationForCustom + patch.getLocation() + " " + PatchDayStrings.notificationForCustom_at
        }
        return locationNotificationPart + patch.getDatePlacedAsString()
    }
    
    public static func getOldestPatchDateAsString() -> String {
        let oldestPatch = getOldestPatch()
        return oldestPatch.getDatePlacedAsString()
    }
    
    // MARK: - modifiers and setters
    
    public static func resetPatchData() {
        for patch in patches {
            patch.reset()
        }
        self.saveContext()
    }
    
    public static func setPatchLocation(patchIndex: Int, with: String) {
        getPatch(forIndex: patchIndex)!.setLocation(with: with)
        saveContext()
    }
    
    // MARK: - dates
    
    public static func getOldestPatchDate() -> Date {
        return getOldestPatch().getDatePlaced()!
    }
    
    public static func setPatchDate(patchIndex: Int, with: Date) {
        getPatch(forIndex: patchIndex)!.setDatePlaced(withDate: with)
        saveContext()
    }
    
    // MARK: - called by notification
    public static func changePatchFromNotification(patchIndex: Int) {
        let suggestedLocation = SuggestedPatchLocation.suggest(patchIndex: patchIndex)
        let suggestDate = Date()
        let patch = getPatch(forIndex: patchIndex)!
        patch.setLocation(with: suggestedLocation)
        patch.setDatePlaced(withDate: suggestDate)
        saveContext()
    }
    
    // MARK: Private functions
    
    private static func createPatches() -> [Patch] {
        var userPatches: [Patch] = []
        for i in 0...(self.getNumberOfPatches()-1) {
            var userPatch = createPatchFromCoreData(patchEntityNameIndex: i)
            // handles the case where there was never a Patch init() in core data
            if userPatch == nil {
                userPatch = createGenericPatch(entityName: PatchDayStrings.patchEntityNames[i])
                saveContext()
            }
            userPatches.append(userPatch!)
        }
        return userPatches
    }
    
    static private func createGenericPatch(entityName: String) -> Patch {
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: persistentContainer.viewContext) as! Patch
        
    }
    
    // called by PatchDataController.createPatches()
    private static func createPatchFromCoreData(patchEntityNameIndex: Int) -> Patch? {
        let patchFetchRequest = createPatchFetch(patchEntityNameIndex: patchEntityNameIndex)
        var userPatch: Patch?
        patchFetchRequest!.propertiesToFetch = PatchDayStrings.patchPropertyNames
        do {
            // load user data if it exists
            let requestedPatch = try persistentContainer.viewContext.fetch(patchFetchRequest!)
            if requestedPatch.count > 0 {
                userPatch = requestedPatch[0]
            }
        }
        catch {
            print("PatchData Fetch Request Failed")
        }
        
        return userPatch
        
    }
    
    // called by PatchDataController.createPatchFromCoreData() to make a FetchRequest
    private static func createPatchFetch(patchEntityNameIndex: Int) -> NSFetchRequest<Patch>? {
        return NSFetchRequest<Patch>(entityName: PatchDayStrings.patchEntityNames[patchEntityNameIndex])
    }
    
}
