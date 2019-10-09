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

    public let dataMeter: PDDataMeting
    public var patchdata: PatchDataCalling
    public let swallowHandler: PDPillSwallowing
    
    public convenience init(defaults: PDDefaultManaging,
                            dataMeter: PDDataMeting,
                            hormones: HormoneScheduling,
                            pills: PDPillScheduling,
                            sites: HormoneSiteScheduling,
                            swallowHandler: PDPillSwallowing) {
        self.init(defaults: defaults,
                  dataMeter: dataMeter,
                  hormones: hormones,
                  pills: pills,
                  sites: sites,
                  state: PDState(),
                  patchdata: PatchDataCaller(),
                  swallowHandler: swallowHandler)
    }

    public init(defaults: PDDefaultManaging,
                dataMeter: PDDataMeting,
                hormones: HormoneScheduling,
                pills: PDPillScheduling,
                sites: HormoneSiteScheduling,
                state: PDStateManaging,
                patchdata: PatchDataCalling,
                swallowHandler: PDPillSwallowing) {
        self.defaults = defaults
        self.dataMeter = dataMeter
        self.hormones = hormones
        self.pills = pills
        self.sites = sites
        self.state = state
        self.patchdata = patchdata
        self.swallowHandler = swallowHandler
    }
    
    public init(swallowHandler: PDPillSwallowing) {
        self.dataMeter = PDDataMeter()
        self.state = PDState()
        self.patchdata = PatchDataCaller()
        self.pills = PDPills()
        self.defaults = PDDefaults(stateManager: self.state, meter: self.dataMeter)
        self.hormones = PDHormones(deliveryMethod: self.defaults.deliveryMethod.value,
                                   interval: self.defaults.expirationInterval)
        let indexer = PDSiteIndexer(defaults: self.defaults)
        self.sites = PDSites(deliveryMethod: self.defaults.deliveryMethod.value,
                             globalExpirationInterval: self.defaults.expirationInterval,
                             siteIndexRebounder: indexer)
        self.swallowHandler = swallowHandler
    }
    
    public var defaults: PDDefaultManaging
    public var hormones: HormoneScheduling
    public var sites: HormoneSiteScheduling
    public var pills: PDPillScheduling
    public var state: PDStateManaging
    
    /// Returns the total hormones expired and pills due.
    public var totalAlerts: Int {
        return totalHormonesExpired + pills.totalDue
    }

    public var totalHormonesExpired: Int {
        return hormones.totalExpired(defaults.expirationInterval)
    }
    
    public var allSiteNames: [String] {
        return Array(sites.unionize(deliveryMethod: deliveryMethod))
    }

    // MARK: - Defaults

    public var siteIndex: Index {
        get { return defaults.siteIndex.rawValue }
        set { _ = defaults.setSiteIndex(to: newValue, siteCount: sites.count) }
    }

    public var deliveryMethod: DeliveryMethod {
        get { return defaults.deliveryMethod.value }
        set {
            defaults.setDeliveryMethod(to: newValue)
            let newIndex = PDKeyStorableHelper.defaultQuantity(for: newValue)
            _ = defaults.setSiteIndex(to: newIndex, siteCount: sites.count)
            broadcastHormones()
            state.deliveryMethodChanged = true
        }
    }

    public var deliveryMethodName: String {
        let deliv = defaults.deliveryMethod.value
        return PDPickerStrings.getDeliveryMethod(for: deliv)
    }

    public func setQuantity(to newQuantity: Int) {
        let oldQuantity = defaults.quantity.value.rawValue
        defaults.setQuantity(to: newQuantity)
        if oldQuantity < newQuantity {
            // Fill in new estros
            for _ in oldQuantity..<newQuantity {
                let _ = hormones.insert(expiration: defaults.expirationInterval,
                                        deliveryMethod: defaults.deliveryMethod.value)
            }
        } else {
            hormones.delete(after: oldQuantity - 1)
        }
    }

    // MARK: - Hormones

    public func setHormoneSite(at index: Index, with site: Bodily) {
        state.bodilyChanged = true
        hormones.setSite(at: index, with: site)
        broadcastHormones()
        patchdata.save()
    }

    public func setHormoneDate(at index: Index, with date: Date) {
        hormones.setDate(at: index, with: date)
        broadcastHormones()
        patchdata.save()
    }

    public func setHormoneDateAndSite(for id: UUID, date: Date, site: Bodily) {
        hormones.set(for: id, date: date, site: site)
        broadcastHormones()
        patchdata.save()
    }

    /// Returns set of current occupied SiteNames
    public func getNamesOfOccupiedSites() -> Set<SiteName> {
        return Set(hormones.all.map({(mone: Hormonal) -> SiteName in
            return mone.site?.name ?? ""
        }).filter() { $0 != "" })
    }

    // MARK: - Sites
    
    public func insertNewSite() {
        let name = PDStrings.PlaceholderStrings.new_site
        insertNewSite(name: name, completion: nil)
    }

    public func insertNewSite(name: SiteName, completion: (() -> ())?) {
        if var site = sites.insert(
            deliveryMethod: defaults.deliveryMethod.value,
            globalExpirationInterval: defaults.expirationInterval,
            completion: completion
        ) {
            site.name = name
        }
    }

    // MARK: - Pills

    public func swallow(_ pill: Swallowable) {
        pills.swallow(pushSharedData: broadcastPills)
        swallowHandler.handleSwallow(pill)
    }

    // MARK: - DataMeter

    public func broadcastHormones() {
        if let mone = hormones.next {
            let interval = defaults.expirationInterval
            let name = sites.suggested?.name ?? PDStrings.PlaceholderStrings.new_site
            let deliveryMethod = defaults.deliveryMethod
            dataMeter.broadcastRelevantHormoneData(
                oldestHormone: mone,
                nextSuggestedSite: name,
                interval: interval,
                deliveryMethod: deliveryMethod
            )
        }
    }

    func broadcastPills() {
        if let next = pills.nextDue {
            dataMeter.broadcastRelevantPillData(nextPill: next)
        }
    }

    // MARK: - Stateful

    public func stampQuantity() {
        state.oldQuantity = defaults.quantity.value.rawValue
    }
    
    public func stateChanged(forHormoneAtIndex index: Index) -> Bool {
        if let mone = hormones.at(index) {
            return state.hormoneHasStateChanges(mone, at: index, quantity: hormones.count)
        }
        return false
    }

    // MARK: - Other public

    /// Returns array of occupied site indices.
    func occupiedSitesIndices() -> [Index] {
        var indices: [Index] = []
        if let pdSites = sites.all.asPDSiteArray() {
            for mone in hormones.all {
                if let occupiedSite = mone.site?.asPDSite(),
                    let i = pdSites.firstIndex(of: occupiedSite) {
                    indices.append(i)
                }
            }
        }
        return indices
    }

    public func nuke() {
        PatchData.nuke()
        hormones.reset(from: 0)
        pills.new()
        let method = defaults.deliveryMethod.value
        let interval = defaults.expirationInterval
        sites.reset(deliveryMethod: method, globalExpirationInterval: interval)
    }
}

extension Array where Iterator.Element == Bodily {
    func asPDSiteArray() -> [PDSite]? {
        return self as? [PDSite]
    }
}

extension Bodily {
    func asPDSite() -> PDSite? {
        return self as? PDSite
    }
}
