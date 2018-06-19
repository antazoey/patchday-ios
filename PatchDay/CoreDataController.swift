 //
//  CoreDataController.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/11/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData

internal class CoreDataController {
    
    // Description: CoreDataController is where the Core Data Stack is initialized. It is the internal class for interacting with core data to load and save MO attributes.  The core data model expresses MOs with the attributes: date, serving as a Date object created on the day and time it was placed, and the site, a String representing the site of the MO.  CoreDataController is the class the ScheduleController, the UI class for the MO data, uses to load and save the MO data.
    
    // MARK: - Managed Object Array
    
    internal var estro_array: [MOEstrogen]
    internal var loc_array: [MOSite]
    
    init() {
        var estromos: [MOEstrogen] = []
        var sitemos: [MOSite] = []
        for i in 0...(UserDefaultsController.getQuantityInt() - 1) {
            if let estro = CoreDataController.createEstrogenDeliveryMO(entityIndex: i) {
                estromos.append(estro)
            } 
            else {
                let estro = CoreDataController.generateEstrogenDeliveryMO(entityIndex: i)
                estromos.append(estro)
            }
            CoreDataController.saveContext()
        }
        sitemos = CoreDataController.createSiteMOs()
        sitemos = CoreDataController.filterEmptySites(from: sitemos)
        if sitemos.count == 0 {
            sitemos = CoreDataController.generateSiteMOs()
        }
        
        // sort during init()
        estromos.sort(by: <)
        sitemos.sort(by: <)
        self.estro_array = estromos
        self.loc_array = sitemos
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
    
    // MARK: - Public estrogen functions
    
    internal func sortEstrogenSchedule() {
        self.estro_array.sort(by: <)
    }
    
    internal func getEstrogenDeliveryMO(forIndex: Int) -> MOEstrogen? {
        // negative indices need not abide
        if forIndex < 0 || forIndex > 4 {
            return nil
        }
        
            // no MO in estro_array forIndex (such as the Count changed), and it is still less than the count... then make a new MO and append and return it.
        else if forIndex < UserDefaultsController.getQuantityInt() {
            if forIndex >= estro_array.count {
                let newMO = CoreDataController.generateEstrogenDeliveryMO(entityIndex: forIndex)
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
        CoreDataController.saveContext()
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
        CoreDataController.saveContext()
    }
    
    internal func setEstrogenDeliveryMO(scheduleIndex: Int, date: Date, location: String) {
        if let estro = getEstrogenDeliveryMO(forIndex: scheduleIndex) {
            estro.setLocation(with: location)
            estro.setDatePlaced(withDate: date)
        }
        self.sortEstrogenSchedule()
        CoreDataController.saveContext()
    }
    
    internal func setEstrogenDeliveryMO(with: MOEstrogen, scheduleIndex: Int) {
        if scheduleIndex < estro_array.count && scheduleIndex >= 0 {
            estro_array[scheduleIndex] = with
        }
        self.sortEstrogenSchedule()
        CoreDataController.saveContext()
    }
    
    internal func resetEstrogenData(start_i: Int, end_i: Int) {
        for i in start_i...end_i {
            if let mo = self.getEstrogenDeliveryMO(forIndex: i) {
                mo.reset()
            }
        }
        CoreDataController.saveContext()
    }
    
    // MARK: - Public site functions
    
    internal func setSiteName(index: Int, to: String) {
        if index >= 0 && index < loc_array.count {
            loc_array[index].setName(to: to)
        }
        CoreDataController.saveContext()
    }
    
    internal func setSiteOrder(index: Int, to: Int16) {
        if index >= 0 && index < loc_array.count {
            loc_array[index].setOrder(to: to)
        }
        CoreDataController.saveContext()
    }
    
    internal func deleteSite(index: Int) {
        if index >= 0 && index < loc_array.count {
            loc_array[index].reset()
        }
        if (index+1) < (loc_array.count-1) {
            for i in (index+1)...(loc_array.count-1) {
               loc_array[i].decrement()
            }
        }
        loc_array = loc_array.filter() { $0.getOrder() != -1 && $0.getName() != ""}
        CoreDataController.saveContext()
    }
    
    internal func resetSiteData() {
        self.loc_array = CoreDataController.createSiteMOs()
        let resetSiteNames: [String] = (UserDefaultsController.usingPatches()) ? PDStrings.siteNames.patchSiteNames : PDStrings.siteNames.injectionSiteNames
        for i in 0...(resetSiteNames.count-1) {
            if i < loc_array.count {
                loc_array[i].setOrder(to: Int16(i))
                loc_array[i].setName(to: resetSiteNames[i])
            }
            else if let newSiteMO = NSEntityDescription.insertNewObject(forEntityName: PDStrings.coreDataKeys.locEntityName, into: CoreDataController.persistentContainer.viewContext) as? MOSite {
                newSiteMO.setOrder(to: Int16(i))
                newSiteMO.setName(to: resetSiteNames[i])
                loc_array.append(newSiteMO)
            }
        }
        if self.loc_array.count-1 > resetSiteNames.count {
            for i in resetSiteNames.count...(self.loc_array.count-1) {
                self.loc_array[i].reset()
            }
        }
        self.loc_array = CoreDataController.filterEmptySites(from: loc_array)
        self.loc_array.sort(by: <)
        CoreDataController.saveContext()
        
    }

    internal func printSites() {
        print("PRINTING SITES")
        print("--------------")
        for site in self.loc_array {
            print("Order: " + String(site.getOrder()))
            if let n = site.getName() {
                print("Name: " + n)
            }
            print("Unnamed")
        }
        print("*************")
    }
    
    internal static func appendSite(name: String, order: Int, sites: inout [MOSite]) {
        if let locmo = NSEntityDescription.insertNewObject(forEntityName: PDStrings.coreDataKeys.locEntityName, into: persistentContainer.viewContext) as? MOSite {
            locmo.setName(to: name)
            sites.append(locmo)
        }
        saveContext()
    }
    
    internal static func filterEmptySites(from: [MOSite]) -> [MOSite] {
        return from.filter() { $0.getName() != "" && $0.getName() != nil && $0.getOrder() != -1 }
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
                sites[i].reset()
            }
        }
        // Filter out nil sites and ones we ignored
        sites = filterEmptySites(from: sites)
        saveContext()
    }
    
    // MARK: - Shared public

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
    
    // generates a generic MOEstrogen when there is none in store.
    private static func generateEstrogenDeliveryMO(entityIndex: Int) -> MOEstrogen {
        if entityIndex < PDStrings.coreDataKeys.estroEntityNames.count && entityIndex >= 0 {
            let entityName = PDStrings.coreDataKeys.estroEntityNames[entityIndex]
            if let mo = NSEntityDescription.insertNewObject(forEntityName: entityName, into: persistentContainer.viewContext) as? MOEstrogen {
                return mo
            }
            else {
                PDAlertController.alertForCoreDataError()
                return MOEstrogen()
            }
        }
        else {
            return MOEstrogen()
        }
    }
    
    // Generates a generic list of MOSites when there are none in store.
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
    
    // For bringing persisted MOEstrogenDeliveries into memory when starting the app.
    private static func createEstrogenDeliveryMO(entityIndex: Int) -> MOEstrogen? {
        var userMO: MOEstrogen?
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
    
    // MOEstrogen...
    private static func createEstrogenDeliveryFetch(entityIndex: Int) -> NSFetchRequest<MOEstrogen>? {
        if entityIndex < PDStrings.coreDataKeys.estroEntityNames.count && entityIndex >= 0 {
            return NSFetchRequest<MOEstrogen>(entityName: PDStrings.coreDataKeys.estroEntityNames[entityIndex])
        }
        return nil
    }
    
    // MOSite...
    private static func createSiteFetch() -> NSFetchRequest<MOSite> {
        return NSFetchRequest<MOSite>(entityName: PDStrings.coreDataKeys.locEntityName)
    }
}
