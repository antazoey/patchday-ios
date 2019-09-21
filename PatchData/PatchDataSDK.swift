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

public class PatchDataSDK: NSObject, PatchDataDelegate {
    
    override public var description: String {
        return "Main interface for controlling patch data"
    }
    
    // Sub-schedules
//    public var _defaults: PDDefaultManaging
      public let dataMeter: PDDataMeting
//    public let _estrogenSchedule: EstrogenScheduling
//    public let _pillSchedule: PDPillScheduling
//    public let _siteSchedule: EstrogenSiteScheduling
  //   public var _state: PDStateManaging
      public var patchdata: PatchDataCalling
    
    public convenience init(defaults: PDDefaultManaging,
                            dataMeter: PDDataMeting,
                            estrogenSchedule: EstrogenScheduling,
                            pillSchedule: PDPillScheduling,
                            estrogenSiteSchedule: EstrogenSiteScheduling) {
        self.init(defaults: defaults,
                  dataMeter: dataMeter,
                  estrogenSchedule: estrogenSchedule,
                  pillSchedule: pillSchedule,
                  estrogenSiteSchedule: estrogenSiteSchedule,
                  state: PDState(),
                  patchdata: PatchDataCaller())
    }

    public init(defaults: PDDefaultManaging,
                dataMeter: PDDataMeting,
                estrogenSchedule: EstrogenScheduling,
                pillSchedule: PDPillScheduling,
                estrogenSiteSchedule: EstrogenSiteScheduling,
                state: PDStateManaging,
                patchdata: PatchDataCalling) {
        self.defaults = defaults
        self.dataMeter = dataMeter
        self.estrogens = estrogenSchedule
        self.pills = pillSchedule
        self.sites = estrogenSiteSchedule
        self.state = state
        self.patchdata = patchdata
    }
    
    public override init() {
        self.dataMeter = PDDataMeter()
        self.state = PDState()
        self.patchdata = PatchDataCaller()
        self.pills = PillSchedule()

        self.defaults = PDDefaults(stateManager: self.state, meter: self.dataMeter)
        self.estrogens = EstrogenSchedule(deliveryMethod: self.defaults.deliveryMethod.value,
                                          interval: self.defaults.expirationInterval)
        
        let indexer = PDSiteIndexer(defaults: self.defaults)
        self.sites = SiteSchedule(deliveryMethod: self.defaults.deliveryMethod.value,
                                  globalExpirationInterval: self.defaults.expirationInterval,
                                  siteIndexRebounder: indexer)
    }
    
    public var defaults: PDDefaultManaging
    public var estrogens: EstrogenScheduling
    public var sites: EstrogenSiteScheduling
    public var pills: PDPillScheduling
    public var state: PDStateManaging
    
    /// Returns the total due of MOEstrogens and MOPills in the schedule.
    public var totalDue: Int {
        return estrogens.totalDue(defaults.expirationInterval) + pills.totalDue
    }
    
    // MARK: - Defaults
    
    public var siteIndex: Index {
        get {
            return defaults.siteIndex.rawValue
        }
        set {
            _ = defaults.setSiteIndex(to: newValue, siteCount: sites.count)
        }
    }
    
    public var deliveryMethod: DeliveryMethod {
        get { return defaults.deliveryMethod.value }
        set {
            defaults.setDeliveryMethod(to: newValue)
            let newIndex = PDKeyStorableHelper.defaultQuantity(for: newValue)
            _ = defaults.setSiteIndex(to: newIndex, siteCount: sites.count)
            attemptToBroadcastRelevantEstrogenData()
            state.deliveryMethodChanged = true
        }
    }
    
    public func setQuantity(to newQuantity: Int) {
        let oldQuantity = defaults.quantity.value.rawValue
        defaults.setQuantity(to: newQuantity)
        if oldQuantity < newQuantity {
            // Fill in new estros
            for _ in oldQuantity..<newQuantity {
                let _ = estrogens.insert(expiration: defaults.expirationInterval,
                                         deliveryMethod: defaults.deliveryMethod.value)
            }
        } else {
            estrogens.delete(after: oldQuantity - 1)
        }
    }
    
    // MARK: - Estrogen Schedule
    
    public func setEstrogenSite(at index: Index, with site: Bodily) {
        state.siteChanged = true
        estrogens.setSite(at: index, with: site)
        attemptToBroadcastRelevantEstrogenData()
        patchdata.save()
    }
    
    public func setEstrogenDate(at index: Index, with date: Date) {
        estrogens.setDate(at: index, with: date)
        attemptToBroadcastRelevantEstrogenData()
        patchdata.save()
    }
    
    public func setEstrogenDateAndSite(for id: UUID, date: Date, site: Bodily) {
        estrogens.setEstrogenDateAndSite(for: id, date: date, site: site)
        attemptToBroadcastRelevantEstrogenData()
        patchdata.save()
    }
    
    /// Returns array of current occupied SiteNames
    public func getCurrentSiteNamesInEstrogenSchedule() -> [SiteName] {
        return estrogens.get.map({
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
    
    // MARK: - DataMeter
    
    public func attemptToBroadcastRelevantEstrogenData() {
        if let estro = estrogens.next {
            let interval = defaults.expirationInterval
            let name = sites.suggestedSite?.name ?? PDStrings.PlaceholderStrings.new_site
            let deliveryMethod = defaults.deliveryMethod
            dataMeter.broadcastRelevantEstrogenData(oldestEstrogen: estro,
                                                    nextSuggestedSite: name,
                                                    interval: interval,
                                                    deliveryMethod: deliveryMethod)
        }
    }

    // MARK: - Other public

    /// Returns array of occupied site indices.
    public func getOccupiedSiteIndices() -> [Index] {
        var indices: [Index] = []
        for estro in estrogens.get {
            if let site = estro.site, let pdSite = site as? PDSite, let pdSites = sites.get as? [PDSite],
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
        estrogens.reset(from: 0)
        pills.new()
        sites.reset(deliveryMethod: defaults.deliveryMethod.value,
                    globalExpirationInterval: defaults.expirationInterval)
    }
}
