//
//  PillStore.swift
//  PatchData
//
//  Created by Juliya Smith on 12/24/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class PillStore: EntityStore {

    func getStoredPills() -> [Swallowable] {
        var pills: [Swallowable] = []
        let pillDataEntries = entities.getStoredPillData()
        for pillData in pillDataEntries {
            let pill = Pill(pillData: pillData)
            pills.append(pill)
        }
        return pills
    }

    func createNewPill(name: String) -> Swallowable? {
        if let newPillDataFromStore = entities.createNewPill(name: name) {
            return Pill(pillData: newPillDataFromStore)
        }
        return nil
    }

    func createNewPill() -> Swallowable? {
        if let newPillDataFromStore = entities.createNewPill() {
            return Pill(pillData: newPillDataFromStore)
        }
        return nil
    }

    func delete(_ pill: Swallowable) {
        entities.deletePillData([CoreDataEntityAdapter.convertToPillStruct(pill)])
    }

    func pushLocalChangesToBeSaved(_ pills: [Swallowable]) {
        if pills.count == 0 {
            return
        }
        let pillData = pills.map { p in CoreDataEntityAdapter.convertToPillStruct(p) }
        self.pushLocalChangesToBeSaved(pillData)
    }

    func pushLocalChangesToBeSaved(_ pill: Swallowable) {
        self.pushLocalChangesToBeSaved([CoreDataEntityAdapter.convertToPillStruct(pill)])
    }

    private func pushLocalChangesToBeSaved(_ pillData: [PillStruct]) {
        entities.pushPillData(pillData)
    }
}