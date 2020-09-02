//
//  HormoneRepository.swift
//  PatchData
//
//  Created by Juliya Smith on 12/24/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class HormoneStore: EntityStore, HormoneStoring {

    private let entities: MOHormoneList

    override init(_ stack: PDCoreDataWrapping) {
        self.entities = MOHormoneList(coreDataStack: stack)
        super.init(stack)
    }

    private lazy var log = PDLog<HormoneStore>()

    func getStoredHormones(_ settings: UserDefaultsReading) -> [Hormonal] {
        var hormones: [Hormonal] = []
        let hormoneDataEntries = entities.getManagedHormoneData()
        for hormoneData in hormoneDataEntries {
            let hormone = Hormone(hormoneData: hormoneData, settings: settings)
            hormones.append(hormone)
        }
        return hormones
    }

    func createNewHormone(_ settings: UserDefaultsReading) -> Hormonal? {
        guard let newHormoneDataFromStore = entities.createNewManagedHormone() else { return nil }
        return Hormone(hormoneData: newHormoneDataFromStore, settings: settings)
    }

    func delete(_ hormone: Hormonal) {
        entities.deleteManagedHormoneData([CoreDataEntityAdapter.convertToHormoneStruct(hormone)])
    }

    func clearSitesFromHormone(_ hormoneId: UUID) {
        entities.clearSitesFromHormone(hormoneId)
    }

    func pushLocalChangesToManagedContext(_ hormones: [Hormonal], doSave: Bool = true) {
        guard hormones.count > 0 else { return }
        let hormoneData = hormones.map { h in CoreDataEntityAdapter.convertToHormoneStruct(h) }
        pushLocalChangesToManagedContext(hormoneData, doSave: doSave)
    }

    func save() {
        stack.save(saverName: "Hormone Store")
    }

    private func pushLocalChangesToManagedContext(_ hormoneData: [HormoneStruct], doSave: Bool) {
        entities.pushHormoneDataToManagedContext(hormoneData, doSave: doSave)
    }
}
