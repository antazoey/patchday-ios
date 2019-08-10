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

public class PDSchedule: NSObject, PDTodayAppPrepared, TotalDueAnnoying {
    
    override public var description: String {
        return "Singleton for reading, writing, and querying Core Data objects."
    }
    
    // Sub-schedules
    public var defaults: PDDefaults
    public let sharedData: PDSharedData
    public let estrogenSchedule = EstrogenSchedule()
    public let pillSchedule = PillSchedule()
    public let siteSchedule = SiteSchedule()
    public let state = PDState()
    
    public override init() {
        sharedData = PDSharedData(estrogenSchedule: estrogenSchedule,
                                  pillSchedule: pillSchedule,
                                  siteSchedule: siteSchedule)
        defaults = PDDefaults(estrogenSchedule: estrogenSchedule,
                              siteSchedule: siteSchedule,
                              state: state,
                              sharedData: sharedData)
    }

    // MARK: - Public
    
    public func setEstrogenDataForToday() {
        let interval = defaults.expirationInterval
        let siteIndex = defaults.siteIndex
        let deliveryMethod = defaults.deliveryMethod
        let setSiteIndex = defaults.setSiteIndex
        self.sharedData.setEstrogenDataForToday(interval: interval,
                                                deliveryMethod: deliveryMethod,
                                                index: siteIndex.value,
                                                setSiteIndex: setSiteIndex)
    }

    /// Returns array of current occupied SiteNames
    public func getCurrentSiteNamesInEstrogenSchedule() -> [SiteName] {
        return estrogenSchedule.estrogens.map({
            (estro: TimeReleased) -> SiteName in
            if let site = estro.site, let name = site.name {
                return name
            }
            else {
                return ""
            }
        }).filter() {
            $0 != ""
        }
    }
    
    /// Returns the total due of MOEstrogens and MOPills in the schedule.
    public func totalDue(interval: ExpirationIntervalUD) -> Int {
        return estrogenSchedule.totalDue(interval) + pillSchedule.totalDue()
    }

    /// Returns array of occupied site indices.
    public func getOccupiedSiteIndices() -> [Index] {
        var indices: [Index] = []
        for estro in estrogenSchedule.estrogens {
            if let site = estro.site,
                let index = siteSchedule.sites.firstIndex(of: site) {
                indices.append(index)
            } else {
                indices.append(-1)
            }
        }
        return indices
    }
    
    public func nuke() {
        PatchData.nuke()
        estrogenSchedule.reset(from: 0)
        pillSchedule.reset()
        siteSchedule.reset()
    }
}
