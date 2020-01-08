//
//  PatchData.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/13/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import UIKit
import PDKit


public class PatchData: NSObject, PatchDataDelegate {

    override public var description: String {
        "Root object for developing with PatchData."
    }

    let dataMeter: DataShareDelegate
    let coreData: PDCoreDataDelegate
    let hormoneDataBroadcaster: HormoneDataBroadcasting

    public var defaults: UserDefaultsManaging
    public var hormones: HormoneScheduling
    public var sites: HormoneSiteScheduling
    public var pills: PillScheduling
    public var stateManager: PDStateManaging
    
    public init(
        defaults: UserDefaultsManaging,
        dataMeter: DataShareDelegate,
        hormones: HormoneScheduling,
        pills: PillScheduling,
        sites: HormoneSiteScheduling,
        stateManager: PDStateManaging,
        coreData: PDCoreDataDelegate,
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
        let store = CoreDataStackWrapper()

        // ******************************************************
        if CommandLine.arguments.contains("-n") {
            store.nuke()
        }
        // ******************************************************

        let dataMeter = DataShare()
        let state = PDState()
        let defaultsStore = PDUserDefaultsWriter(
            state: state, handler: PDUserDefaultsWriteHandler(meter: dataMeter)
        )
        let pillScheduleState = PatchData.determinePillScheduleState(defaults: defaultsStore)
        let pills = PillSchedule(coreDataStack: store, pillDataMeter: dataMeter, state: pillScheduleState)
        let indexer = SiteIndexer(defaults: defaultsStore)

        let sites = SiteSchedule(coreDataStack: store, defaults: defaultsStore, siteIndexRebounder: indexer)
        
        let hormoneDataBroadcaster = HormoneDataBroadcaster(
            sites: sites,
            siteDataMeter: dataMeter,
            defaults: defaultsStore
        )
        
        let hormones = HormoneSchedule(
            hormoneDataBroadcaster: hormoneDataBroadcaster,
            coreDataStack: store,
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
    
    private static func determinePillScheduleState(defaults: UserDefaultsWriting) -> PillSchedule.PillScheduleState {
        !defaults.mentionedDisclaimer.value
            ? PillSchedule.PillScheduleState.Initial
            : PillSchedule.PillScheduleState.Working
    }
}
