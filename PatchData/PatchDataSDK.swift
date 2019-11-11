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
        "Main interface for controlling patch data"
    }

    let dataMeter: PDDataMeting
    let patchData: PatchDataCalling
    let hormoneDataBroadcaster: HormoneDataBroadcasting
    
    public init(
        defaults: PDDefaultManaging,
        dataMeter: PDDataMeting,
        hormones: HormoneScheduling,
        pills: PDPillScheduling,
        sites: HormoneSiteScheduling,
        state: PDStateManaging,
        patchData: PatchDataCalling,
        hormoneDataBroadcaster: HormoneDataBroadcasting
    ) {
        self.defaults = defaults
        self.dataMeter = dataMeter
        self.hormones = hormones
        self.pills = pills
        self.sites = sites
        self.state = state
        self.patchData = patchData
        self.hormoneDataBroadcaster = hormoneDataBroadcaster
        super.init()
    }
    
    public convenience init(
        defaults: PDDefaultManaging,
        dataMeter: PDDataMeting,
        hormones: HormoneScheduling,
        pills: PDPillScheduling,
        sites: HormoneSiteScheduling,
        patchData: PatchDataCalling,
        hormoneDataBroadcaster: HormoneDataBroadcasting
    ) {
        self.init(
            defaults: defaults,
            dataMeter: dataMeter,
            hormones: hormones,
            pills: pills,
            sites: sites,
            state: PDState(),
            patchData: patchData,
            hormoneDataBroadcaster: hormoneDataBroadcaster
        )
    }
    
    public override convenience init() {
        let store = PatchDataCaller()
        let dataMeter = PDDataMeter()
        let state = PDState()
        let defaultsStore = PDDefaultsStore(
            stateManager: state, handler: PDDefaultsStorageHandler(meter: dataMeter)
        )
        let isNew = !defaultsStore.mentionedDisclaimer.value
        let pills = PDPills(store: store, pillDataMeter: dataMeter, isFirstInit: isNew)
        let method = defaultsStore.deliveryMethod
        let interval = defaultsStore.expirationInterval
        let indexer = PDSiteIndexer(defaults: defaultsStore)
        let sites = PDSites(store: store, defaults: defaultsStore, siteIndexRebounder: indexer)
        
        let hormoneData = HormoneScheduleData(
            deliveryMethod: method, expirationInterval: interval
        )
        
        let hormoneDataBroadcaster = HormoneDataBroadcaster(
            sites: sites,
            siteDataMeter: dataMeter,
            defaults: defaultsStore
        )
        
        let hormones = PDHormones(
            data: hormoneData,
            hormoneDataBroadcaster: hormoneDataBroadcaster,
            store: store,
            stateManager: state,
            defaults: defaultsStore
        )
        
        let defaults = PDDefaults(
            store: defaultsStore,
            state: state,
            hormones: hormones,
            sites: sites,
            hormoneBroadcaster: hormoneDataBroadcaster
        )
        
        self.init(
            defaults: defaults,
            dataMeter: dataMeter,
            hormones: hormones,
            pills: pills,
            sites: sites,
            patchData: store,
            hormoneDataBroadcaster: hormoneDataBroadcaster
        )
    }
    
    public var defaults: PDDefaultManaging
    public var hormones: HormoneScheduling
    public var sites: HormoneSiteScheduling
    public var pills: PDPillScheduling
    public var state: PDStateManaging

    public var isFresh: Bool {
        hormones.isEmpty && sites.isDefault
    }

    public var totalAlerts: Int {
        hormones.totalExpired + pills.totalDue
    }

    public var occupiedSites: Set<SiteName> {
        Set(hormones.all.map({(mone: Hormonal) ->
            SiteName in return mone.site?.name ?? ""
        }).filter() { $0 != "" })
    }

    // MARK: - DataMeter

    private func broadcastPills() {
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
    public func occupiedSitesIndices() -> [Index] {
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
        hormones.reset()
        pills.reset()
        let newSiteCount = sites.reset()
        defaults.reset(defaultSiteCount: newSiteCount)
    }
    
    private func broadcastHormones() {
        hormoneDataBroadcaster.broadcast(nextHormone: hormones.next)
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
