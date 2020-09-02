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
        guard let newPillDataFromStore = entities.createNewManagedPill(name: name) else {
            return nil
        }
        return Pill(pillData: newPillDataFromStore)
    }

    func createNewPill() -> Swallowable? {
        guard let newPillDataFromStore = entities.createNewManagedPill() else { return nil }
        return Pill(pillData: newPillDataFromStore)
    }

    func delete(_ pill: Swallowable) {
        entities.deleteManagedPillData([CoreDataEntityAdapter.convertToPillStruct(pill)])
    }

    func pushLocalChangesToManagedContext(_ pills: [Swallowable], doSave: Bool) {
        guard pills.count > 0 else { return }
        let pillData = pills.map { p in CoreDataEntityAdapter.convertToPillStruct(p) }
        self.pushLocalChangesToManagedContext(pillData, doSave: doSave)
    }

    private func pushLocalChangesToManagedContext(_ pillData: [PillStruct], doSave: Bool) {
        entities.pushPillDataToManagedContext(pillData, doSave: doSave)
    }
}
