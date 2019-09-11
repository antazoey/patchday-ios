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

public class PDSchedule: NSObject, PDScheduling {
    
    override public var description: String {
        return "Singleton for reading, writing, and querying Core Data objects."
    }
    
    // Sub-schedules
    public var defaults: PDDefaultManaging
    public let dataMeter: PDDataMeting
    public let estrogenSchedule: EstrogenScheduling
    public let pillSchedule: PDPillScheduling
    public let siteSchedule: EstrogenSiteScheduling

    public static let state: PDStateManaging = PDState()
    
    public init(defaults: PDDefaultManaging,
                dataMeter: PDDataMeting,
                estrogenSchedule: EstrogenScheduling,
                pillSchedule: PDPillScheduling,
                estrogenSiteSchedule: EstrogenSiteScheduling) {
        // PatchData depedencies
        self.defaults = defaults
        self.dataMeter = dataMeter
        self.estrogenSchedule = estrogenSchedule
        self.pillSchedule = pillSchedule
        self.siteSchedule = estrogenSiteSchedule
    }
    
    public override init() {
        self.dataMeter = PDDataMeter()
        self.defaults = PDDefaults(stateManager: PDSchedule.state, meter: self.dataMeter)
        self.estrogenSchedule = EstrogenSchedule(deliveryMethod: self.defaults.deliveryMethod.value,
                                                 interval: self.defaults.expirationInterval)
        self.pillSchedule = PillSchedule()
        self.siteSchedule = SiteSchedule(deliveryMethod: self.defaults.deliveryMethod.value,
                                         globalExpirationInterval: self.defaults.expirationInterval,
                                         correctSiteIndex: self.defaults.setSiteIndex(to:siteCount:))
    }
    
    // MARK: - Public
    
    public var deliveryMethod: DeliveryMethod {
        return defaults.deliveryMethod.value
    }

    public func setQuantity(to newQuantity: Int) {
        let oldQuantity = defaults.quantity.value.rawValue
        defaults.setQuantity(to: newQuantity)
        if oldQuantity < newQuantity {
            // Fill in new estros
            for _ in oldQuantity..<newQuantity {
                let _ = estrogenSchedule.insert(expiration: defaults.expirationInterval,
                                                deliveryMethod: defaults.deliveryMethod.value)
            }
        } else {
            estrogenSchedule.delete(after: oldQuantity - 1)
        }
    }
    
    public func attemptToBroadcastRelevantEstrogenData() {
        if let estro = estrogenSchedule.next {
            let interval = defaults.expirationInterval
            let name = siteSchedule.suggestedSite?.name ?? PDStrings.PlaceholderStrings.new_site
            let deliveryMethod = defaults.deliveryMethod
            dataMeter.broadcastRelevantEstrogenData(oldestEstrogen: estro,
                                                    nextSuggestedSite: name,
                                                    interval: interval,
                                                    deliveryMethod: deliveryMethod)
        }
    }

    /// Returns array of current occupied SiteNames
    public func getCurrentSiteNamesInEstrogenSchedule() -> [SiteName] {
        return estrogenSchedule.estrogens.map({
            (estro: Hormonal) -> SiteName in
            if let site = estro.site {
                return site.name
            } else {
                return ""
            }
        }).filter() {
            $0 != ""
        }
    }
    
    /// Returns the total due of MOEstrogens and MOPills in the schedule.
    public func totalDue(interval: ExpirationIntervalUD) -> Int {
        return estrogenSchedule.totalDue(defaults.expirationInterval) + pillSchedule.totalDue
    }

    /// Returns array of occupied site indices.
    public func getOccupiedSiteIndices() -> [Index] {
        var indices: [Index] = []
        for estro in estrogenSchedule.estrogens {
            if let site = estro.site, let pdSite = site as? PDSite, let pdSites = siteSchedule.sites as? [PDSite],
                let index = pdSites.firstIndex(of: pdSite) {
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
        pillSchedule.new()
        siteSchedule.reset(deliveryMethod: defaults.deliveryMethod.value,
                           globalExpirationInterval: defaults.expirationInterval)
    }
}
