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
    
    public convenience init(defaults: PDDefaultManaging,
                            dataMeter: PDDataMeting,
                            hormones: HormoneScheduling,
                            pills: PDPillScheduling,
                            sites: HormoneSiteScheduling) {
        self.init(defaults: defaults,
                  dataMeter: dataMeter,
                  hormones: hormones,
                  pills: pills,
                  sites: sites,
                  state: PDState(),
                  patchdata: PatchDataCaller())
    }

    public init(defaults: PDDefaultManaging,
                dataMeter: PDDataMeting,
                hormones: HormoneScheduling,
                pills: PDPillScheduling,
                sites: HormoneSiteScheduling,
                state: PDStateManaging,
                patchdata: PatchDataCalling) {
        self.defaults = defaults
        self.dataMeter = dataMeter
        self.hormones = hormones
        self.pills = pills
        self.sites = sites
        self.state = state
        self.patchdata = patchdata
    }
    
    public override init() {
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
    }
    
    public var defaults: PDDefaultManaging
    public var hormones: HormoneScheduling
    public var sites: HormoneSiteScheduling
    public var pills: PDPillScheduling
    public var state: PDStateManaging
    
    /// Returns the total hormones expired and pills due.
    public var totalDue: Int {
        return totalEstrogensExpired + pills.totalDue
    }

    public var totalEstrogensExpired: Int {
        return hormones.totalExpired(defaults.expirationInterval)
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
            broadcastEstrogens()
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

    // MARK: - Estrogens

    public func setEstrogenSite(at index: Index, with site: Bodily) {
        state.siteChanged = true
        hormones.setSite(at: index, with: site)
        broadcastEstrogens()
        patchdata.save()
    }

    public func setEstrogenDate(at index: Index, with date: Date) {
        hormones.setDate(at: index, with: date)
        broadcastEstrogens()
        patchdata.save()
    }

    public func setEstrogenDateAndSite(for id: UUID, date: Date, site: Bodily) {
        hormones.set(for: id, date: date, site: site)
        broadcastEstrogens()
        patchdata.save()
    }

    /// Returns array of current occupied SiteNames
    public func getCurrentSiteNamesInEstrogenSchedule() -> [SiteName] {
        return hormones.all.map({(estro: Hormonal) -> SiteName in
            return estro.site?.name ?? ""
        }).filter() { $0 != "" }
    }

    // MARK: - Sites

    public func insertSite(name: SiteName? = nil, completion: (() -> ())?) {
        let n = name ?? PDStrings.PlaceholderStrings.new_site
        if var site = sites.insert(deliveryMethod: defaults.deliveryMethod.value,
                     globalExpirationInterval: defaults.expirationInterval,
                     completion: completion) {
            site.name = n
        }
    }

    // MARK: - Pills

    public func swallow(_ pill: Swallowable) {
        pills.swallow(pushSharedData: broadcastPills)
    }

    // MARK: - DataMeter

    public func broadcastEstrogens() {
        if let estro = hormones.next {
            let interval = defaults.expirationInterval
            let name = sites.suggested?.name ?? PDStrings.PlaceholderStrings.new_site
            let deliveryMethod = defaults.deliveryMethod
            dataMeter.broadcastRelevantEstrogenData(oldestEstrogen: estro,
                                                    nextSuggestedSite: name,
                                                    interval: interval,
                                                    deliveryMethod: deliveryMethod)
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

    public func prepareToSaveSiteImage(for site: Bodily) {
        state.siteChanged = true
        for estro in site.hormones {
            if let i = hormones.indexOf(estro) {
                state.indicesOfChangedDelivery.append(i)
            }
        }
    }

    // MARK: - Other public

    /// Returns array of occupied site indices.
    func occupiedSitesIndices() -> [Index] {
        var indices: [Index] = []
        if let pdSites = sites.all.asPDSiteArray() {
            for estro in hormones.all {
                if let occupiedSite = estro.site?.asPDSite(),
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
