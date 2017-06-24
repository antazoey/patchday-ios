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
                
            }
        })
        return container
    }()
    
    // MARK: - Managed Object Array
    
    static var patches: [Patch] = {
        var userPatches: [Patch] = []
        for i in 0...(getNumberOfPatches()-1) {
            if let userPatch = createPatchFromCoreData(patchEntityNameIndex: i) {
                userPatches.append(userPatch)
            }
            else {
                let userPatch = createGenericPatch(entityName: PatchDayStrings.patchEntityNames[i])
                userPatches.append(userPatch)
            }
            saveContext()
        }
        
        return userPatches
    }()
    
    // MARK: - Core Data Saving support
    
    static func saveContext () {
        if PatchDataController.persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                PDAlertController.alertForCoreDataSaveError()
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
                if let datePlaced = patches[i].getDatePlaced(), let oldDate = oldestPatch.getDatePlaced() {
                    if datePlaced < oldDate {
                        oldestPatch = patches[i]
                    }
                }
            }
        }
        return oldestPatch
    }
    
    public static func getPatch(forIndex: Int) -> Patch? {
        var patch: Patch?
        if self.patches.count >= (forIndex+1) && forIndex >= 0 && forIndex < self.patches.count {
            patch = self.patches[forIndex]
        }
        return patch
    }
    
    // MARK: - public
    
    public static func appendToPatches(patch: Patch, patchIndex: Int) {
        // if there is room
        if patches.count < 4 {
            patches.append(patch)
        }
        else {
            setPatch(with: patch, patchIndex: patchIndex)
        }
    }
    
    public static func setPatchLocation(patchIndex: Int, with: String) {
        // attempt to set the Patch's location at given index
        if let patch = getPatch(forIndex: patchIndex) {
            patch.setLocation(with: with)
        }
        // if there is no Patch there, make one there and set it's location
        else if patchIndex >= 0 && patchIndex < 4 {
            let patch = createGenericPatch(entityName: PatchDayStrings.patchEntityNames[patchIndex])
            patch.setLocation(with: with)
            appendToPatches(patch: patch, patchIndex: patchIndex)
        }
        saveContext()
    }
    
    public static func setPatchDate(patchIndex: Int, with: Date) {
        // attempt to set Patch's date at given index
        if let patch = getPatch(forIndex: patchIndex) {
            patch.setDatePlaced(withDate: with)
        }
        // if there is no Patch, make one there and set that one's date
        else {
            let patch = createGenericPatch(entityName: PatchDayStrings.patchEntityNames[patchIndex])
            patch.setDatePlaced(withDate: with)
            appendToPatches(patch: patch, patchIndex: patchIndex)
        }
        saveContext()
    }
    
    public static func setPatch(patchIndex: Int, patchDate: Date, location: String) {
        if let patch = getPatch(forIndex: patchIndex) {
            patch.setDatePlaced(withDate: patchDate)
            patch.setLocation(with: location)
        }
        else {
            let patch = createGenericPatch(entityName: PatchDayStrings.patchEntityNames[patchIndex])
            patch.setDatePlaced(withDate: patchDate)
            patch.setLocation(with: location)
            appendToPatches(patch: patch, patchIndex: patchIndex)
        }
        saveContext()
    }
    
    public static func setPatch(with: Patch, patchIndex: Int) {
        if patchIndex <= 3 && patchIndex >= 0 {
            patches[patchIndex] = with
        }
        saveContext()
    }
    
    public static func getOldestPatchDate() -> Date {
        if let oldestPatchDate = getOldestPatch().getDatePlaced() {
            return oldestPatchDate
        }
        return Date()
    }
    
    public static func resetPatchData() {
        for patch in patches {
            patch.reset()
        }
        self.saveContext()
    }
    
    public static func makeArrayOfLocations() -> [String] {
        var locationArray: [String] = []
        for i in 0...(getNumberOfPatches()-1) {
            locationArray.append(getPatches()[i].getLocation())
        }
        return locationArray
    }
    
    // MARK: - strings
    
    public static func suggestLocation(patchIndex: Int) -> String {
        return SuggestedPatchLocation.suggest(patchIndex: patchIndex)
    }
    
    public static func notificationString(index: Int) -> String {
        if let patch = self.getPatch(forIndex: index) {
            // for non-custom located patches
            if patch.isNotCustomLocated() {
                guard let locationNotificationPart = PatchDayStrings.notificationIntros[patch.getLocation()] else {
                    return PatchDayStrings.notificationWithoutLocation + patch.getDatePlacedAsString()
                }
                return locationNotificationPart + patch.getDatePlacedAsString()
            }
            // for custom located patches
            else {
                let locationNotificationPart = PatchDayStrings.notificationForCustom + patch.getLocation() + " " + PatchDayStrings.notificationForCustom_at
                return locationNotificationPart + patch.getDatePlacedAsString()
            }
        }
        return ""
    }
    
    public static func getOldestPatchDateAsString() -> String {
        let oldestPatch = getOldestPatch()
        return oldestPatch.getDatePlacedAsString()
    }
    
    // MARK: - called by notification
    public static func changePatchFromNotification(patchIndex: Int) {
        if let patch = getPatch(forIndex: patchIndex) {
            let suggestedLocation = SuggestedPatchLocation.suggest(patchIndex: patchIndex)
            let suggestDate = Date()
            patch.setLocation(with: suggestedLocation)
            patch.setDatePlaced(withDate: suggestDate)
            saveContext()
        }
    }
    
    // MARK: Private functions
    
    static private func createGenericPatch(entityName: String) -> Patch {
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
