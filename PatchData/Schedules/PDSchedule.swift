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
    public var defaults: PDDefaults
    public let sharedData: PDSharedData
    public let estrogenSchedule = EstrogenSchedule()
    public let pillSchedule = PillSchedule()
    public let siteSchedule = SiteSchedule()
    public let state = PDState()
    private let alerter: PatchDataAlert
    
    public override init() {
        alerter = PatchDataAlert(estrogenSchedule: estrogenSchedule)
        defaults = PDDefaults(estrogenSchedule: estrogenSchedule,
                              siteSchedule: siteSchedule,
                              state: state,
                              alerter: alerter)
        sharedData = PDSharedData(defaults: defaults,
                              estrogenSchedule: estrogenSchedule,
                              pillSchedule: pillSchedule,
                              siteSchedule: siteSchedule)
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
    
    /// Returns the total due of MOEstrogens and MOPills in the schedule.
    public func totalDue(interval: String) -> Int {
        return estrogenSchedule.totalDue(interval) + pillSchedule.totalDue()
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
