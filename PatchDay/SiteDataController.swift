//
//  SiteDataController.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData
import PDKit

public class SiteDataController {
    
    internal var siteArray: [MOSite]
    internal let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        siteArray = SiteDataController.loadSiteMOs(into: context)
        siteArray = SiteDataController.filterEmptySites(from: siteArray)
        if siteArray.count == 0 {
            siteArray = SiteDataController.newSiteMOs(into: context)
        }
        siteArray.sort(by: <)
    }
    
    // MARK: - Public
    
    internal func setSiteName(index: Index, to: String) {
        if index >= 0 && index < siteArray.count {
            siteArray[index].setName(to: to)
            ScheduleController.saveContext(context)
        }
    }
    
    internal func setSiteOrder(index: Index, to: Int16) {
        if index >= 0 && index < siteArray.count {
            siteArray[index].setOrder(to: to)
            ScheduleController.saveContext(context)
        }
    }
    
    /// Returns the MOSite for the given name. Appends new site with given name if doesn't exist.
    internal func getSite(for name: String) -> MOSite? {
        if let index = PDSiteHelper.getSiteNames(siteArray).index(of: name) {
            return siteArray[index]
        }
        // Append new site
        return SiteDataController.appendSite(name: name, order: siteArray.count, sites: &siteArray, into: context)
    }
    
    internal func deleteSite(at index: Index) {
        if index >= 0 && index < siteArray.count {
            siteArray[index].reset()
        }
        if (index+1) < (siteArray.count-1) {
            for i in (index+1)..<siteArray.count {
                siteArray[i].decrement()
            }
        }
        siteArray = siteArray.filter() { $0.getOrder() != -1 && $0.getName() != ""}
        ScheduleController.saveContext(context)
    }
    
    internal func resetSiteData() {
        let resetSiteNames: [String] = (UserDefaultsController.usingPatches()) ? PDStrings.SiteNames.patchSiteNames : PDStrings.SiteNames.injectionSiteNames
        let oldCount = siteArray.count
        let newcount = resetSiteNames.count
        for i in 0..<newcount {
            if i < siteArray.count {
                siteArray[i].setOrder(to: Int16(i))
                siteArray[i].setName(to: resetSiteNames[i])
            }
            else if let newSiteMO = NSEntityDescription.insertNewObject(forEntityName: PDStrings.CoreDataKeys.siteEntityName, into: context) as? MOSite {
                newSiteMO.setOrder(to: Int16(i))
                newSiteMO.setName(to: resetSiteNames[i])
                siteArray.append(newSiteMO)
            }
        }
        if oldCount > resetSiteNames.count {
            for i in resetSiteNames.count..<oldCount {
                siteArray[i].reset()
            }
        }
        siteArray = SiteDataController.filterEmptySites(from: siteArray)
        siteArray.sort(by: <)
        ScheduleController.saveContext(context)
        
    }
    
    /// Returns if the sites in the site schedule are the same as the default sites.
    public func isDefault() -> Bool {
        let defaultSites = (UserDefaultsController.usingPatches()) ? PDStrings.SiteNames.patchSiteNames : PDStrings.SiteNames.injectionSiteNames
        let c = defaultSites.count
        if siteArray.count != c {
            return false
        }
        for i in 0..<c {
            if let n = siteArray[i].getName() {
                if n != defaultSites[i] {
                    return false
                }
            }
            else {
                return false
            }
        }
        return true
    }
    
    internal func printSites() {
        print("PRINTING SITES")
        print("--------------")
        for site in siteArray {
            print("Order: " + String(site.getOrder()))
            if let n = site.getName() {
                print("Name: " + n)
            }
            else {
                print("Unnamed")
            }
            print("---------")
        }
        print("*************")
    }
    
    internal static func filterEmptySites(from: [MOSite]) -> [MOSite] {
        return from.filter() { $0.getName() != "" && $0.getName() != nil && $0.getOrder() != -1 }
    }
    
    /** For when the user switches delivery methods:
     Resets SiteMOs to the default orders based on
     the new delivery method. */
    internal static func switchDefaultSites(deliveryMethod: String, sites: inout [MOSite], into context: NSManagedObjectContext) {
        // Default orderings found in PDStrings...
        let names = (deliveryMethod == PDStrings.PickerData.deliveryMethods[0]) ? PDStrings.SiteNames.patchSiteNames : PDStrings.SiteNames.injectionSiteNames
        for i in 0..<names.count {
            // Reset existing siteMO to default site
            if i < sites.count {
                sites[i].setName(to: names[i])
            }
                // Create new siteMO for a default site
            else if let loc = NSEntityDescription.insertNewObject(forEntityName: PDStrings.CoreDataKeys.siteEntityName, into: context) as? MOSite {
                loc.setName(to: names[i])
                sites.append(loc)
            }
        }
        // Mark unneeded siteMOs
        if (names.count < sites.count) {
            for i in names.count..<sites.count {
                sites[i].reset()
            }
        }
        // Filter out nil sites and ones we ignored
        sites = filterEmptySites(from: sites)
        saveContext(context)
    }
    
    /// Appends the the new site to the siteArray and returns it.
    internal static func appendSite(name: String, order: Int, sites: inout [MOSite], into context: NSManagedObjectContext) -> MOSite? {
        if let sitemo = NSEntityDescription.insertNewObject(forEntityName: PDStrings.CoreDataKeys.siteEntityName, into: context) as? MOSite {
            sitemo.setName(to: name)
            sites.append(sitemo)
            saveContext(context)
            return sitemo
        }
        return nil
    }
    
    // MARK: Private
    
    /// Generates a generic list of MOSites when there are none in store.
    private static func newSiteMOs(into context: NSManagedObjectContext) -> [MOSite] {
        var generatedSiteMOs: [MOSite] = []
        var names = (UserDefaultsController.usingPatches()) ? PDStrings.SiteNames.patchSiteNames : PDStrings.SiteNames.injectionSiteNames
        for i in 0..<names.count {
            if let sitemo = NSEntityDescription.insertNewObject(forEntityName: PDStrings.CoreDataKeys.siteEntityName, into: context) as? MOSite {
                sitemo.setOrder(to: Int16(i))
                sitemo.setName(to: names[i])
                generatedSiteMOs.append(sitemo)
            }
        }
        saveContext(context)
        return generatedSiteMOs
    }
    
    
    /// For bringing persisted MOSites into memory when starting the app.
    private static func loadSiteMOs(into context: NSManagedObjectContext) -> [MOSite] {
        let fetchRequest = NSFetchRequest<MOSite>(entityName: PDStrings.CoreDataKeys.siteEntityName)
        fetchRequest.propertiesToFetch = PDStrings.CoreDataKeys.sitePropertyNames
        do {
            return try context.fetch(fetchRequest)
        }
        catch {
            print("Data Fetch Request Failed")
        }
        return []
    }
    
    internal static func saveContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                PDAlertController.alertForCoreDataError()
            }
        }
    }
    
}
