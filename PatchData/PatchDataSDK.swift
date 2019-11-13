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
        "Root object for developing with PatchData."
    }

    let dataMeter: PDDataMeting
    let patchData: PatchDataCalling
    let hormoneDataBroadcaster: HormoneDataBroadcasting

    public var defaults: PDDefaultManaging
    public var hormones: HormoneScheduling
    public var sites: HormoneSiteScheduling
    public var pills: PDPillScheduling
    public var stateManager: PDStateManaging
    
    public init(
        defaults: PDDefaultManaging,
        dataMeter: PDDataMeting,
        hormones: HormoneScheduling,
        pills: PDPillScheduling,
        sites: HormoneSiteScheduling,
        stateManager: PDStateManaging,
        patchData: PatchDataCalling,
        hormoneDataBroadcaster: HormoneDataBroadcasting
    ) {
        self.defaults = defaults
        self.dataMeter = dataMeter
        self.hormones = hormones
        self.pills = pills
        self.sites = sites
        self.stateManager = stateManager
        self.patchData = patchData
        self.hormoneDataBroadcaster = hormoneDataBroadcaster
        super.init()
    }
    
    public override convenience init() {
        let store = PatchDataCaller()
        let dataMeter = PDDataMeter()
        let state = PDState()
        let defaultsStore = PDDefaultsStore(
            state: state, handler: PDDefaultsStorageHandler(meter: dataMeter)
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
            state: state,
            defaults: defaultsStore
        )
        
        let defaults = PDDefaults(
            store: defaultsStore,
            state: state,
            hormones: hormones,
            sites: sites,
            hormoneBroadcaster: hormoneDataBroadcaster
        )
        
        let stateManager = PatchDataStateManager(
            state: state,
            defaults: defaults,
            hormones: hormones
        )
        
        self.init(
            defaults: defaults,
            dataMeter: dataMeter,
            hormones: hormones,
            pills: pills,
            sites: sites,
            stateManager: stateManager,
            patchData: store,
            hormoneDataBroadcaster: hormoneDataBroadcaster
        )
    }

    public var isFresh: Bool {
        hormones.isEmpty && sites.isDefault
    }

    public var totalAlerts: Int {
        hormones.totalExpired + pills.totalDue
    }

    public func nuke() {
        PatchData.nuke()
        hormones.reset()
        pills.reset()
        let newSiteCount = sites.reset()
        defaults.reset(defaultSiteCount: newSiteCount)
    }
}
