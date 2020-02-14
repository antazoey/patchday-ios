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


public class PatchData: NSObject, PatchDataSDK {

    override public var description: String {
        "Root object for developing with PatchData."
    }

    let dataSharer: DataSharing
    let coreData: PDCoreDataWrapping
    let hormoneDataSharer: HormoneDataSharing

    public var defaults: UserDefaultsManaging
    public var hormones: HormoneScheduling
    public var sites: SiteScheduling
    public var pills: PillScheduling
    public var stateManager: PDStateManaging
    
    public init(
        defaults: UserDefaultsManaging,
        dataSharer: DataSharing,
        hormones: HormoneScheduling,
        pills: PillScheduling,
        sites: SiteScheduling,
        stateManager: PDStateManaging,
        coreData: PDCoreDataWrapping,
        hormoneDataSharer: HormoneDataSharing
    ) {
        self.defaults = defaults
        self.dataSharer = dataSharer
        self.hormones = hormones
        self.pills = pills
        self.sites = sites
        self.stateManager = stateManager
        self.coreData = coreData
        self.hormoneDataSharer = hormoneDataSharer
        super.init()
    }
    
    public override convenience init() {
        let store = CoreDataStackWrapper()

        // ******************************************************
        if CommandLine.arguments.contains("-n") {
            store.nuke()
        }
        // ******************************************************

        let dataSharer = DataSharer()
        let pillDataSharer = PillDataSharer(baseSharer: dataSharer)
        let state = PDState()
        let defaultsStore = PDUserDefaultsWriter(state: state, handler: PDUserDefaultsWriteHandler(dataSharer: dataSharer))
        let pillScheduleState = PatchData.determinePillScheduleState(defaults: defaultsStore)
        let pills = PillSchedule(store: PillStore(store), pillDataSharer: pillDataSharer, state: pillScheduleState)
        let sites = SiteSchedule(store: SiteStore(store), defaults: defaultsStore)
        let hormoneDataSharer = HormoneDataSharer(baseSharer: dataSharer, sites: sites, defaults: defaultsStore)
        
        let hormones = HormoneSchedule(
            store: HormoneStore(store),
            hormoneDataSharer: hormoneDataSharer,
            state: state,
            defaults: defaultsStore
        )
        
        let defaults = PDDefaults(writer: defaultsStore, state: state, hormones: hormones, sites: sites)
        let stateManager = PDStateManager(state: state, defaults: defaults, hormones: hormones)
        
        self.init(
            defaults: defaults,
            dataSharer: dataSharer,
            hormones: hormones,
            pills: pills,
            sites: sites,
            stateManager: stateManager,
            coreData: store,
            hormoneDataSharer: hormoneDataSharer
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
        defaults.mentionedDisclaimer.value
            ? PillSchedule.PillScheduleState.Working
            : PillSchedule.PillScheduleState.Initial
    }
}
