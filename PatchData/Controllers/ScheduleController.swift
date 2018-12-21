//
//  ScheduleController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/13/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
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
}
