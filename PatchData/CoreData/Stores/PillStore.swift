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
        for pillData in entities.getStoredPillData() {
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

    func save(_ pills: [Swallowable]) {
        let pillData = pills.map { p in CoreDataEntityAdapter.convertToPillStruct(p) }
        self.save(pillData)
    }

    func save(_ pill: Swallowable) {
        self.save([CoreDataEntityAdapter.convertToPillStruct(pill)])
    }

    private func save(_ pillData: [PillStruct]) {
        entities.pushPillData(pillData)
    }
}