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

// ScheduleController is the public accessor class for controlling the app's managed objects.  A PatchDay Managed Object is known as a "Patch" or an "Injection", an abstraction of a patch on the physical body or an injection into the physical body.  The ScheduleController is how the user changes any of their patches or re-injects.  The user may also use the ScheduleController to edit a MOEstrogen object's attributes.  This static class uses a "Schedule" object to work with all of the MOEstrogens together in an array.  Schedule objects are for querying an array of MOEstrogens.

public class ScheduleController: NSObject {
    
    public static var estrogenController = EstrogenDataController()
    public static var pillController = PillDataController()
    public static var siteController = SiteDataController()
    
    // MARK: - Core Data stack
    
    internal static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: PDStrings.CoreDataKeys.persistantContainer_key)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                PDAlertController.alertForPersistentStoreLoadError(error: error)
            }
        })
        return container
    }()
    
    internal static func getContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Public
    
    public static func estroCount() -> Int {
        return ScheduleController.estrogenController.estrogenArray.count
    }
    
    public static func pillCount() -> Int {
        return ScheduleController.pillController.pillArray.count
    }
    
    public static func siteCount() -> Int {
        return ScheduleController.siteController.siteArray.count
    }
    
    public static func getCurrentSiteNamesInEstrogenSchedule() -> [SiteName] {
        return estrogenController.estrogenArray.map({
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
    
    public static func totalEstrogenDue(intervalStr: String) -> Int {
        return PDEstrogenHelper.expiredCount(ScheduleController.estrogenController.estrogenArray, intervalStr: intervalStr)
    }
    
    public static func totalPillsDue() -> Int {
        
        return pillController.pillArray.reduce(0, {
            (count: Int, pill: MOPill) -> Int in
            let r = pill.isExpired() ? 1 + count : count
            return r
        })
    }
    
    public static func totalDue(intervalStr: String) -> Int {
        return totalEstrogenDue(intervalStr: intervalStr) + totalPillsDue()
    }
    
    public static func setEstrogenDataForToday() {
        let defaults = UserDefaults(suiteName: "group.com.patchday.todaydata")!
        let siteKey = PDStrings.TodayKey.nextEstroSiteName.rawValue
        let dateKey = PDStrings.TodayKey.nextEstroDate.rawValue
        let estro = getEstroForToday()
        if let siteName = getSiteNameToSaveForToday(using: estro) {
            defaults.set(siteName, forKey: siteKey)
        }
        else {
            defaults.set(nil, forKey: siteKey)
        }
        if let date = estro.expirationDate(intervalStr: UserDefaultsController.getTimeIntervalString()) {
            defaults.set(date, forKey: dateKey)
        }
        else {
            defaults.set(nil, forKey: dateKey)
        }
    }
    
    private static func getEstroForToday() -> MOEstrogen {
        if UserDefaultsController.usingPatches(), let nextEstro = estrogenController.nextEstroDue() {
            return nextEstro
        }
        else {
            return ScheduleController.estrogenController.getEstrogenMO(at: 0)
        }
    }
    
    private static func getSiteNameToSaveForToday(using estro: MOEstrogen) -> SiteName? {
        if UserDefaultsController.usingPatches() {
            return estro.getSiteName()
        }
        if let suggestedSite = SiteSuggester.getSuggestedSite(), let name = suggestedSite.getName() {
            return name
        }
        return nil
    }
    
    public static func getSiteIndices() -> [Index] {
        var indices: [Index] = []
        for estro in ScheduleController.estrogenController.estrogenArray {
            if let site = estro.getSite(),
                let index = ScheduleController.siteController.siteArray.index(of: site) {
                indices.append(index)
            }
            else {
                indices.append(-1)
            }
        }
        return indices
    }
    
    public static func setPillDataForToday() {
        let defaults = UserDefaults(suiteName: "group.com.patchday.todaydata")!
        let pillNameKey = PDStrings.TodayKey.nextPillToTake.rawValue
        let pillDateKey = PDStrings.TodayKey.nextPillTakeTime.rawValue
        if let nextPill = pillController.nextPillDue() {
            if let pillName = nextPill.getName() {
                defaults.set(pillName, forKey: pillNameKey)
            }
            else {
                defaults.set(nil, forKey: pillNameKey)
            }
            if let pillDate = nextPill.getDueDate() {
                defaults.set(pillDate, forKey: pillDateKey)
            }
            else {
                defaults.set(nil, forKey: pillDateKey)
            }
        }
    }
    
    public static func setDataForTodayApp() {
        setEstrogenDataForToday()
        setPillDataForToday()
    }
    
    /**
     For knowing which estrogen buttons to animate when loading EstrogensVC.
     */
    internal static var animateScheduleFromChangeDelivery: Bool = false
    internal static var increasedCount: Bool = false
    internal static var decreasedCount: Bool = false
    internal static var siteChanged: Bool = false
    internal static var onlySiteChanged: Bool = false
    internal static var deliveryMethodChanged: Bool = false
    internal static var oldDeliveryCount: Int = 1
    internal static var indexOfChangedDelivery: Int = -1

    /**
     ANIMATION ALGORITHM
     */
    public static func shouldAnimate(estrogenIndex: Index, newBG: UIImage, estrogenController: EstrogenDataController, estrogenCount: Int) -> Bool {
        
        /* -- Reasons to Animate -- */
        
        var hasDateAndItMatters: Bool = true
        let estro = estrogenController.getEstrogenMO(at: estrogenIndex)
        if estro.hasNoDate() {
            hasDateAndItMatters = false
        }
        
        // 1.) from ESTROGEN: animate affected non-empty MO dates from changing
        let moreThanSiteChangedFromDetails: Bool = animateScheduleFromChangeDelivery && newBG != PDImages.addPatch  && !onlySiteChanged && indexOfChangedDelivery <= estrogenIndex && hasDateAndItMatters
        
        // 2.) from ESTROGEN: animate the newly changed site and none else (date didn't change)
        let isChangedSiteFromDetails: Bool = siteChanged && estrogenIndex == indexOfChangedDelivery
        
        // 3.) from SETTINGS: animate new empty MOs when loading from the changing count
        let indexLessThanOldCountFromSettings: Bool = (increasedCount && estrogenIndex >= oldDeliveryCount) || (decreasedCount && estrogenIndex >= oldDeliveryCount)

        
        return (moreThanSiteChangedFromDetails || isChangedSiteFromDetails || indexLessThanOldCountFromSettings || deliveryMethodChanged)
        
    }
    
    internal static func save() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                PDAlertController.alertForCoreDataError()
            }
        }
    }
    
    public static func migrate(needs: Bool) {
        if needs {
            
            let migrater = PDDataMigrater(container: ScheduleController.persistentContainer)
            migrater.migrate(newEstros: &ScheduleController.estrogenController.estrogenArray, into: ScheduleController.getContext())
            UserDefaultsController.migrated()
        }
    }


}
