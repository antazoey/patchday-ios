//
//  PDSchedule.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/13/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import UIKit
import PDKit

public typealias SiteSet = [String]

public class PDSchedule: NSObject {
    
    override public var description: String {
        return "Singleton for reading, writing, and querying Core Data objects."
    }
    
    // Sub-controllers
    public static var estrogenSchedule = EstrogenSchedule()
    public static var pillSchedule = PillSchedule()
    public static var siteSchedule = SiteSchedule()

    // MARK: - Public
    
    /// Returns total number of MOEstrogens in the schedule.
    public static func estroCount() -> Int {
        return PDSchedule.estrogenSchedule.getEstrogens().count
    }
    
    /// Returns total number of MOPills in the schedule.
    public static func pillCount() -> Int {
        return PDSchedule.pillSchedule.getPills().count
    }
    
    /// Returns total number of MOSites in the schedule.
    public static func siteCount() -> Int {
        return PDSchedule.siteSchedule.getSites().count
    }
    
    /// Returns array of current occupied SiteNames
    public static func getCurrentSiteNamesInEstrogenSchedule() -> [SiteName] {
        return estrogenSchedule.getEstrogens().map({
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
        let sites = PDSchedule.siteSchedule.getSites()
        if let i = PDSchedule.siteSchedule.getNextSiteIndex() {
            return sites[i]
        }
        return nil
    }
    
    /// Returns total number of MOEstrogens that are expired.
    public static func totalEstrogenDue(intervalStr: String) -> Int {
        return PDEstrogenHelper.expiredCount(PDSchedule.estrogenSchedule.getEstrogens(), intervalStr: intervalStr)
    }
    
    /// Returns total number of MOPills that need to be taken.
    public static func totalPillsDue() -> Int {
        
        return pillSchedule.getPills().reduce(0, {
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
        if UserDefaultsController.usingPatches(), let nextEstro = estrogenSchedule.nextEstroDue() {
            return nextEstro
        } else {
            return PDSchedule.estrogenSchedule.getEstrogen(at: 0)
        }
    }
    

    /// Returns array of occupied site indices.
    public static func getOccupiedSiteIndices() -> [Index] {
        var indices: [Index] = []
        for estro in PDSchedule.estrogenSchedule.getEstrogens() {
            if let site = estro.getSite(),
                let index = PDSchedule.siteSchedule.getSites().index(of: site) {
                indices.append(index)
            } else {
                indices.append(-1)
            }
        }
        return indices
    }
}
