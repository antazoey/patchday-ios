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
    
    // Sub-schedules
    public var defaults: PDDefaults!
    public let estrogenSchedule = EstrogenSchedule()
    public let pillSchedule = PillSchedule()
    public let siteSchedule = SiteSchedule()
    public let state = ScheduleState()
    private let alerter: PatchDataAlert!
    
    public override init() {
        defaults = PDDefaults(estrogenSchedule: estrogenSchedule,
                              siteSchedule: siteSchedule,
                              scheduleState: state, alerter: alerter)
        alerter = PatchDataAlert(estrogenSchedule: estrogenSchedule,
                                 defaults: defaults)
    }

    // MARK: - Public

    /// Returns array of current occupied SiteNames
    public func getCurrentSiteNamesInEstrogenSchedule() -> [SiteName] {
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
    public func suggest(current: Index) -> MOSite? {
        let sites = siteSchedule.sites
        if let i = siteSchedule.nextIndex() {
            return sites[i]
        }
        return nil
    }
    
    /// Returns the total due of MOEstrogens and MOPills in the schedule.
    public func totalDue(interval: String) -> Int {
        return estrogenSchedule.totalDue(interval) + pillSchedule.totalDue()
    }
    
    /// For patches, get the next due. For injections, get the only one.
    public func getEstrogenForToday() -> MOEstrogen? {
        if defaults.usingPatches(),
            let estro = estrogenSchedule.nextDue() {
            return estro
        } else {
            return estrogenSchedule.getEstrogen(at: 0)
        }
    }

    /// Returns array of occupied site indices.
    public func getOccupiedSiteIndices() -> [Index] {
        var indices: [Index] = []
        for estro in estrogenSchedule.getEstrogens() {
            if let site = estro.getSite(),
                let index = siteSchedule.sites.index(of: site) {
                indices.append(index)
            } else {
                indices.append(-1)
            }
        }
        return indices
    }
}
