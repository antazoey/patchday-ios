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

public class PatchData: NSObject, PatchDataDelegate {

    override public var description: String {
        "Root object for developing with PatchData."
    }

    let dataMeter: DataMeting
    let coreData: CoreDataCalling
    let hormoneDataBroadcaster: HormoneDataBroadcasting

    public var defaults: UserDefaultsManaging
    public var hormones: HormoneScheduling
    public var sites: HormoneSiteScheduling
    public var pills: PillScheduling
    public var stateManager: PDStateManaging
    
    public init(
        defaults: UserDefaultsManaging,
        dataMeter: DataMeting,
        hormones: HormoneScheduling,
        pills: PillScheduling,
        sites: HormoneSiteScheduling,
        stateManager: PDStateManaging,
        coreData: CoreDataCalling,
        hormoneDataBroadcaster: HormoneDataBroadcasting
    ) {
        self.defaults = defaults
        self.dataMeter = dataMeter
        self.hormones = hormones
        self.pills = pills
        self.sites = sites
        self.stateManager = stateManager
        self.coreData = coreData
        self.hormoneDataBroadcaster = hormoneDataBroadcaster
        super.init()
    }
    
    public override convenience init() {
        let store = CoreDataWrapper()
        let dataMeter = DataMeter()
        let state = PDState()
        let defaultsStore = PDDefaultsStore(
            state: state, handler: PDDefaultsStorageHandler(meter: dataMeter)
        )
        let isNew = !defaultsStore.mentionedDisclaimer.value
        let pills = PillSchedule(store: store, pillDataMeter: dataMeter, isFirstInit: isNew)
        let method = defaultsStore.deliveryMethod
        let interval = defaultsStore.expirationInterval
        let indexer = SiteIndexer(defaults: defaultsStore)
        let sites = SiteSchedule(store: store, defaults: defaultsStore, siteIndexRebounder: indexer)
        
        let hormoneData = HormoneScheduleData(
            deliveryMethod: method, expirationInterval: interval
        )
        
        let hormoneDataBroadcaster = HormoneDataBroadcaster(
            sites: sites,
            siteDataMeter: dataMeter,
            defaults: defaultsStore
        )
        
        let hormones = HormoneSchedule(
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
            coreData: store,
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
        coreData.nuke()
        hormones.reset()
        pills.reset()
        let newSiteCount = sites.reset()
        defaults.reset(defaultSiteCount: newSiteCount)
    }
}
