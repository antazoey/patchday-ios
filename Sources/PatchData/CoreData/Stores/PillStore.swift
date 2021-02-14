//
//  PillStore.swift
//  PatchData
//
//  Created by Juliya Smith on 12/24/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class PillStore: EntityStore, PillStoring {

    private let entities: MOPillList

    override init(_ stack: PDCoreDataWrapping) {
        self.entities = MOPillList(coreDataStack: stack)
        super.init(stack)
    }

    /// Returns True if any of the stored pill have saved times.
    var state: PillScheduleState {
        var state = PillScheduleState.Initial
        var pillsToSave: [Swallowable] = []
        let storedPills = getStoredPills()
        for pill in storedPills {
            if pill.times.count > 0 {
                state = .Working
            } else {
                // Fix Pill that for some reason doesn't have a single Time set.
                pill.appendTime(Time())
                pillsToSave.append(pill)
            }
        }
        if pillsToSave.count > 0 {
            pushLocalChangesToManagedContext(pillsToSave, doSave: true)
        }
        return state
    }

    func getStoredPills() -> [Swallowable] {
        var pills: [Swallowable] = []
        let pillDataEntries = entities.getManagedPillData()
        for pillData in pillDataEntries {
            let pill = Pill(pillData: pillData)
            pills.append(pill)
        }
        return pills
    }

    func createNewPill(name: String) -> Swallowable? {
        guard let storedPill = entities.createNewManagedPill(name: name) else { return nil }
        return Pill(pillData: storedPill)
    }

    func createNewPill() -> Swallowable? {
        guard let newPillDataFromStore = entities.createNewManagedPill() else { return nil }
        return Pill(pillData: newPillDataFromStore)
    }

    func delete(_ pill: Swallowable) {
        entities.deleteManagedPillData([EntityAdapter.convertToPillStruct(pill)])
    }

    func pushLocalChangesToManagedContext(_ pills: [Swallowable], doSave: Bool) {
        guard pills.count > 0 else { return }
        let pillData = pills.map { p in EntityAdapter.convertToPillStruct(p) }
        self.pushLocalChangesToManagedContext(pillData, doSave: doSave)
    }

    private func pushLocalChangesToManagedContext(_ pillData: [PillStruct], doSave: Bool) {
        entities.pushPillDataToManagedContext(pillData, doSave: doSave)
    }
}
