 //
//  CoreData.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/11/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData

internal class CoreData {
    
    // Description: CoreData is where the Core Data Stack is initialized. It is the internal class for interacting with core data to load and save MO attributes.  The core data model expresses MOs with the attributes: date, serving as a Date object created on the day and time it was placed, and the location, a String representing the location of the MO.  CoreData is the class the ScheduleController, the UI class for the MO data, uses to load and save the MO data.
    
    // MARK: - Managed Object Array
    
    internal var mo_array: [MOEstrogenDelivery]
    
    init() {
        var mos: [MOEstrogenDelivery] = []
        for i in 0...(SettingsDefaultsController.getQuantityInt() - 1) {
            if let mo = CoreData.createMO(entityIndex: i) {
                mos.append(mo)
            }
            else {
                let mo = CoreData.generateMO(entityIndex: i)
                mos.append(mo)
            }
            CoreData.saveContext()
        }
        // sort during init()
        mos.sort(by: <)
        self.mo_array = mos
        
    }
    
    // MARK: - Core Data stack
    
    internal static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: PDStrings.persistantContainer_key)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                PDAlertController.alertForPersistentStoreLoadError(error: error)
            }
        })
        return container
    }()
    
    // MARK: - Public
    
    internal func sortSchedule() {
        self.mo_array.sort(by: <)
    }
    
    internal func getMO(forIndex: Int) -> MOEstrogenDelivery? {
        // negative indices need not abide
        if forIndex < 0 || forIndex > 4 {
            return nil
        }
            // no MO in mo_array forIndex (such as the Count changed), and it is still less than the count... then make a new MO and append and return it.
        else if forIndex < SettingsDefaultsController.getQuantityInt() {
            if forIndex >= mo_array.count {
                let newMO = CoreData.generateMO(entityIndex: forIndex)
                mo_array.append(newMO)
                sortSchedule()
                return newMO
            }
            else {
                return mo_array[forIndex]
            }
        }
        else {
            return nil
        }
    }
    
    internal func setLocation(scheduleIndex: Int, with: String) {
        // attempt to set the MO's location at given index
        // exit function if given bad scheduleIndex
        if scheduleIndex >= SettingsDefaultsController.getQuantityInt() || scheduleIndex < 0 {
            return
        }
        // set location
        if let mo = getMO(forIndex: scheduleIndex) {
            mo.setLocation(with: with)
        }
        CoreData.saveContext()
    }
    
    internal func setDate(scheduleIndex: Int, with: Date) {
        if scheduleIndex >= SettingsDefaultsController.getQuantityInt() || scheduleIndex < 0 {
            return
        }
        // attempt to set MO's date at given index
        if let mo = getMO(forIndex: scheduleIndex) {
            mo.setDatePlaced(withDate: with)
        }
        // if there is no MO, make one there and set that one's date
        CoreData.saveContext()
    }
    
    internal func setMO(scheduleIndex: Int, date: Date, location: String) {
        if let mo = getMO(forIndex: scheduleIndex) {
            mo.setLocation(with: location)
            mo.setDatePlaced(withDate: date)
        }
        CoreData.saveContext()
    }
    
    internal func setMO(with: MOEstrogenDelivery, scheduleIndex: Int) {
        if scheduleIndex < mo_array.count && scheduleIndex >= 0 {
            mo_array[scheduleIndex] = with
        }
        CoreData.saveContext()
    }
    
    internal func resetData() {
        for mo in mo_array {
            mo.reset()
        }
        CoreData.saveContext()
    }

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
    
    // generateMO(entityIndex) : generates a generic MO when there is no data saved.
    private static func generateMO(entityIndex: Int) -> MOEstrogenDelivery {
        if entityIndex < PDStrings.entityNames.count && entityIndex >= 0 {
            let entityName = PDStrings.entityNames[entityIndex]
            if let mo = NSEntityDescription.insertNewObject(forEntityName: entityName, into: persistentContainer.viewContext) as? MOEstrogenDelivery {
                return mo
            }
            else {
                PDAlertController.alertForCoreDataError()
                return MOEstrogenDelivery()
            }
        }
        else {
            return MOEstrogenDelivery()
        }
    }
    
    // createMO(entityIndex) : creates an MO object when it is able be loaded from CoreData
    private static func createMO(entityIndex: Int) -> MOEstrogenDelivery? {
        var userMO: MOEstrogenDelivery?
        if let fetchRequest = self.createFetch(entityIndex: entityIndex) {
            fetchRequest.propertiesToFetch = PDStrings.moPropertyNames
            do {
                // load user data if it exists
                let requestedMO = try persistentContainer.viewContext.fetch(fetchRequest)
                if requestedMO.count > 0 {
                    userMO = requestedMO[0]
                }
            }
            catch {
                // no alert needed here (calling function will automatically create a generic MO if we can't load one from core data)
                print("Data Fetch Request Failed")
            }
        }
        return userMO
    }
    
    // createFetch(entityIndex) : called by ScheduleController.createMO() to make a FetchRequest
    private static func createFetch(entityIndex: Int) -> NSFetchRequest<MOEstrogenDelivery>? {
        if entityIndex < PDStrings.entityNames.count && entityIndex >= 0 {
            return NSFetchRequest<MOEstrogenDelivery>(entityName: PDStrings.entityNames[entityIndex])
        }
        return nil
    }
    
}
