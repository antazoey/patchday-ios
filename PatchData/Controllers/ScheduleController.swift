//
//  ScheduleController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/13/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import PDKit

public typealias SiteSet = [String]

public class ScheduleController: NSObject {
    
    override public var description: String {
        return "Singleton for reading, writing, and querying Core Data objects."
    }
    
    // Sub-controllers
    public static var estrogenController = EstrogenDataController()
    public static var pillController = PillDataController()
    public static var siteController = SiteDataController()
    
    // Core Data stack
    internal static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: PDStrings.CoreDataKeys.persistantContainer_key)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                PatchDataAlert.alertForPersistentStoreLoadError(error: error)
            }
        })
        return container
    }()
    
    /// Saves the all changed data in the persistentContainer.
    public static func save() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                PatchDataAlert.alertForCoreDataError()
            }
        }
    }
    
    public static func getContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Public
    
    /// Returns total number of MOEstrogens in the schedule.
    public static func estroCount() -> Int {
        return ScheduleController.estrogenController.getEstrogens().count
    }
    
    /// Returns total number of MOPills in the schedule.
    public static func pillCount() -> Int {
        return ScheduleController.pillController.getPills().count
    }
    
    /// Returns total number of MOSites in the schedule.
    public static func siteCount() -> Int {
        return ScheduleController.siteController.getSites().count
    }
    
    /// Returns array of current occupied SiteNames
    public static func getCurrentSiteNamesInEstrogenSchedule() -> [SiteName] {
        return estrogenController.getEstrogens().map({
            (estro: MOEstrogen) -> SiteName in
            if let site = estro.getSite(), let name = site.getName() {
                return name
            }
            else {
                return ""
            }
        }).filter() {
            $0 != ""
        }
    }
    
    /// Returns the next site in the site schedule as a suggestion of where to relocate.
    public static func getSuggestedSite() -> MOSite? {
        let sites = ScheduleController.siteController.getSites()
        if let i = ScheduleController.siteController.getNextSiteIndex() {
            return sites[i]
        }
        return nil
    }
    
    /// Returns total number of MOEstrogens that are expired.
    public static func totalEstrogenDue(intervalStr: String) -> Int {
        return PDEstrogenHelper.expiredCount(ScheduleController.estrogenController.getEstrogens(), intervalStr: intervalStr)
    }
    
    /// Returns total number of MOPills that need to be taken.
    public static func totalPillsDue() -> Int {
        
        return pillController.getPills().reduce(0, {
            (count: Int, pill: MOPill) -> Int in
            let r = pill.isExpired() ? 1 + count : count
            return r
        })
    }
    
    /// Returns the total due of MOEstrogens and MOPills in the schedule.
    public static func totalDue(intervalStr: String) -> Int {
        return totalEstrogenDue(intervalStr: intervalStr) + totalPillsDue()
    }
    
    public static func getEstroForToday() -> MOEstrogen {
        if UserDefaultsController.usingPatches(), let nextEstro = estrogenController.nextEstroDue() {
            return nextEstro
        } else {
            return ScheduleController.estrogenController.getEstrogen(at: 0)
        }
    }
    

    /// Returns array of occupied site indices.
    public static func getOccupiedSiteIndices() -> [Index] {
        var indices: [Index] = []
        for estro in ScheduleController.estrogenController.getEstrogens() {
            if let site = estro.getSite(),
                let index = ScheduleController.siteController.getSites().index(of: site) {
                indices.append(index)
            } else {
                indices.append(-1)
            }
        }
        return indices
    }
    
    /// Helper function for retrieving correct SiteName data to be saved in PatchDay Today widget.
    private static func getSiteNameToSaveForToday(using estro: MOEstrogen) -> SiteName? {
        if UserDefaultsController.usingPatches() {
            return estro.getSiteName()
        } else if let suggestedSite = ScheduleController.getSuggestedSite(), let name = suggestedSite.getName() {
            return name
        }
        return nil
    }
    
    
    /// Sets MOEstrogen data for PatchDay Today widget.
    public static func setEstrogenDataForToday() {
        let defaults = UserDefaults(suiteName: "group.com.patchday.todaydata")!
        let siteKey = PDStrings.TodayKey.nextEstroSiteName.rawValue
        let dateKey = PDStrings.TodayKey.nextEstroDate.rawValue
        let estro = getEstroForToday()
        if let siteName = getSiteNameToSaveForToday(using: estro) {
            defaults.set(siteName, forKey: siteKey)
        } else {
            defaults.set(nil, forKey: siteKey)
        }
        if let date = estro.expirationDate(intervalStr: UserDefaultsController.getTimeIntervalString()) {
            defaults.set(date, forKey: dateKey)
        } else {
            defaults.set(nil, forKey: dateKey)
        }
    }
    
    /// Sets MOPill data for PatchDay Today widget.
    public static func setPillDataForToday() {
        let defaults = UserDefaults(suiteName: "group.com.patchday.todaydata")!
        let pillNameKey = PDStrings.TodayKey.nextPillToTake.rawValue
        let pillDateKey = PDStrings.TodayKey.nextPillTakeTime.rawValue
        if let nextPill = pillController.nextPillDue() {
            if let pillName = nextPill.getName() {
                defaults.set(pillName, forKey: pillNameKey)
            } else {
                defaults.set(nil, forKey: pillNameKey)
            }
            if let pillDate = nextPill.getDueDate() {
                defaults.set(pillDate, forKey: pillDateKey)
            } else {
                defaults.set(nil, forKey: pillDateKey)
            }
        }
    }
    
    /// Sets data to be displayed in PatchDay Today widget.
    public static func setDataForTodayApp() {
        setEstrogenDataForToday()
        setPillDataForToday()
    }
}
