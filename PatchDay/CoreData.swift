 //
//  CoreData.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/11/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData

internal class CoreData {
    
    // Description: CoreData is where the Core Data Stack is initialized. It is the internal class for interacting with core data to load and save MO attributes.  The core data model expresses MOs with the attributes: date, serving as a Date object created on the day and time it was placed, and the site, a String representing the site of the MO.  CoreData is the class the CoreDataController, the UI class for the MO data, uses to load and save the MO data.
    
    // MARK: - Managed Object Array
    
    internal var estro_array: [MOEstrogenDelivery]
    internal var loc_array: [MOSite]
    
    init() {
        var mos: [MOEstrogenDelivery] = []
        var locmos: [MOSite] = []
        for i in 0...(UserDefaultsController.getQuantityInt() - 1) {
            if let mo = CoreData.createEstrogenDeliveryMO(entityIndex: i) {
                mos.append(mo)
            } 
            else {
                let mo = CoreData.generateEstrogenDeliveryMO(entityIndex: i)
                mos.append(mo)
            }
            CoreData.saveContext()
        }
        locmos = CoreData.createSiteMOs()
        locmos = locmos.filter() { $0.getName() != "" && $0.getName() != nil && $0.getOrder() != -1 } 
        if locmos.count == 0 {
            locmos = CoreData.generateSiteMOs()
        }
        
        // sort during init()
        mos.sort(by: <)
        locmos.sort(by: <)
        self.estro_array = mos
        self.loc_array = locmos
    }
    
    // MARK: - Core Data stack
    
    internal static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: PDStrings.coreDataKeys.persistantContainer_key)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                PDAlertController.alertForPersistentStoreLoadError(error: error)
            }
        })
        return container
    }()
    
    // MARK: - Public
    
    internal func sortEstrogenSchedule() {
        self.estro_array.sort(by: <)
    }
    
    internal func getEstrogenDeliveryMO(forIndex: Int) -> MOEstrogenDelivery? {
        // negative indices need not abide
        if forIndex < 0 || forIndex > 4 {
            return nil
        }
        
            // no MO in estro_array forIndex (such as the Count changed), and it is still less than the count... then make a new MO and append and return it.
        else if forIndex < UserDefaultsController.getQuantityInt() {
            if forIndex >= estro_array.count {
                let newMO = CoreData.generateEstrogenDeliveryMO(entityIndex: forIndex)
                estro_array.append(newMO)
                sortEstrogenSchedule()
                return newMO
            }
            else {
                return estro_array[forIndex]
            }
        }
        else {
            return nil
        }
    }
    
    internal func setEstrogenDeliveryLocation(scheduleIndex: Int, with: String) {
        // attempt to set the MO's site at given index
        if scheduleIndex >= UserDefaultsController.getQuantityInt() || scheduleIndex < 0 {
            return
        }
        // set site
        if let estro = getEstrogenDeliveryMO(forIndex: scheduleIndex) {
            estro.setLocation(with: with)
        }
        self.sortEstrogenSchedule()
        CoreData.saveContext()
    }
    
    internal func setEstrogenDeliveryDate(scheduleIndex: Int, with: Date) {
        if scheduleIndex >= UserDefaultsController.getQuantityInt() || scheduleIndex < 0 {
            return
        }
        // attempt to set MO's date at given index
        if let mo = getEstrogenDeliveryMO(forIndex: scheduleIndex) {
            mo.setDatePlaced(withDate: with)
        }
        self.sortEstrogenSchedule()
        CoreData.saveContext()
    }
    
    internal func setEstrogenDeliveryMO(scheduleIndex: Int, date: Date, location: String) {
        if let estro = getEstrogenDeliveryMO(forIndex: scheduleIndex) {
            estro.setLocation(with: location)
            estro.setDatePlaced(withDate: date)
        }
        self.sortEstrogenSchedule()
        CoreData.saveContext()
    }
    
    internal func setEstrogenDeliveryMO(with: MOEstrogenDelivery, scheduleIndex: Int) {
        if scheduleIndex < estro_array.count && scheduleIndex >= 0 {
            estro_array[scheduleIndex] = with
        }
        self.sortEstrogenSchedule()
        CoreData.saveContext()
    }
    
    internal func resetEstrogenData(start_i: Int, end_i: Int) {
        for i in start_i...end_i {
            if let mo = self.getEstrogenDeliveryMO(forIndex: i) {
                mo.reset()
            }
        }
        CoreData.saveContext()
    }
    
    internal func setSiteName(index: Int, to: String) {
        if index >= 0 && index < loc_array.count {
            loc_array[index].setName(to: to)
        }
        CoreData.saveContext()
    }
    
    internal func setSiteOrder(index: Int, to: Int16) {
        if index >= 0 && index < loc_array.count {
            loc_array[index].setOrder(to: to)
        }
        CoreData.saveContext()
    }
    
    internal func deleteSite(index: Int) {
        if index >= 0 && index < loc_array.count {
            loc_array[index].setOrder(to: -1)
            loc_array[index].setName(to: "")
        }
        if (index+1) < (loc_array.count-1) {
            for i in (index+1)...(loc_array.count-1) {
               loc_array[i].decrement()
            }
        }
        loc_array = loc_array.filter() { $0.getOrder() != -1 && $0.getName() != ""}
        CoreData.saveContext()
    }
    
    internal func swapSites(index: Int) {
        let loc1 = CoreDataController.coreData.loc_array[index]
        let loc2 = CoreDataController.coreData.loc_array[index+1]
        if let tempName = loc1.getName(), let loc2_name = loc2.getName() {
            loc1.setName(to: loc2_name)
            loc2.setName(to: tempName)
        }
        CoreData.saveContext()
    }
    
    internal static func appendSite(name: String, order: Int, sites: inout [MOSite]) {
        if let locmo = NSEntityDescription.insertNewObject(forEntityName: PDStrings.coreDataKeys.locEntityName, into: persistentContainer.viewContext) as? MOSite {
            locmo.setName(to: name)
            sites.append(locmo)
        }
        saveContext()
    }
    
    /* For when the user switches delivery methods:
       Resets SiteMOs to the default orders based on
          the new delivery method. */
    internal static func switchDefaultSites(deliveryMethod: String, sites: inout [MOSite]) {
        // Default orderings found in PDStrings...
        let names = (deliveryMethod == PDStrings.pickerData.deliveryMethods[0]) ? PDStrings.siteNames.patchSiteNames : PDStrings.siteNames.injectionSiteNames
        for i in 0...(names.count-1) {
            // Reset existing siteMO to default site
            if i < sites.count {
                sites[i].setName(to: names[i])
            }
            // Create new siteMO for a default site
            else if let loc = NSEntityDescription.insertNewObject(forEntityName: PDStrings.coreDataKeys.locEntityName, into: persistentContainer.viewContext) as? MOSite {
                loc.setName(to: names[i])
                sites.append(loc)
            }
        }
        // Mark unneeded siteMOs
        if (names.count < sites.count) {
            for i in names.count...(sites.count-1) {
                sites[i].setOrder(to: -1)
            }
        }
        // Filter out nil sites and ones we ignored
        sites = sites.filter { $0.order != -1 }
        saveContext()
    }

    internal static func saveContext () {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                PDAlertController.alertForCoreDataError()
            }
        }
    }
    
    // MARK: Private functions
    
    // generates a generic MOEstrogenDelivery when there is none in store.
    private static func generateEstrogenDeliveryMO(entityIndex: Int) -> MOEstrogenDelivery {
        if entityIndex < PDStrings.coreDataKeys.estroEntityNames.count && entityIndex >= 0 {
            let entityName = PDStrings.coreDataKeys.estroEntityNames[entityIndex]
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
    
    // generates a generic list of MOSites when there are none in store.
    private static func generateSiteMOs() -> [MOSite] {
        var generatedLocMOs: [MOSite] = []
        var names = (UserDefaultsController.usingPatches()) ? PDStrings.siteNames.patchSiteNames : PDStrings.siteNames.injectionSiteNames
        for i in 0...(names.count-1) {
            if let locmo = NSEntityDescription.insertNewObject(forEntityName: PDStrings.coreDataKeys.locEntityName, into: persistentContainer.viewContext) as? MOSite {
                locmo.setOrder(to: Int16(i))
                locmo.setName(to: names[i])
                generatedLocMOs.append(locmo)
            }
        }
        saveContext()
        return generatedLocMOs
    }
    
    // for bringing persisted MOEstrogenDeliveries into memory when starting the app.
    private static func createEstrogenDeliveryMO(entityIndex: Int) -> MOEstrogenDelivery? {
        var userMO: MOEstrogenDelivery?
        if let fetchRequest = self.createEstrogenDeliveryFetch(entityIndex: entityIndex) {
            fetchRequest.propertiesToFetch = PDStrings.coreDataKeys.estroPropertyNames
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
    
    // For bringing persisted MOSites into memory when starting the app.
    private static func createSiteMOs() -> [MOSite] {
        let fetchRequest = self.createSiteFetch()
        fetchRequest.propertiesToFetch = PDStrings.coreDataKeys.locPropertyNames
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        }
        catch {
            print("Data Fetch Request Failed")
        }
        return []
    }
    
    // MARK: - Fetching from the persistent store
    
    // MOEstrogenDelivery...
    private static func createEstrogenDeliveryFetch(entityIndex: Int) -> NSFetchRequest<MOEstrogenDelivery>? {
        if entityIndex < PDStrings.coreDataKeys.estroEntityNames.count && entityIndex >= 0 {
            return NSFetchRequest<MOEstrogenDelivery>(entityName: PDStrings.coreDataKeys.estroEntityNames[entityIndex])
        }
        return nil
    }
    
    // MOSite...
    private static func createSiteFetch() -> NSFetchRequest<MOSite> {
        return NSFetchRequest<MOSite>(entityName: PDStrings.coreDataKeys.locEntityName)
    }
}
