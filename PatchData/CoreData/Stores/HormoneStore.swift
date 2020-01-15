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
    
    private let log = PDLog<HormoneStore>()

    func getStoredHormones(_ scheduleProperties: HormoneScheduleProperties) -> [Hormonal] {
        var hormones: [Hormonal] = []
        let hormoneDataEntries = entities.getManagedHormoneData()
        for hormoneData in hormoneDataEntries {
            let hormone = Hormone(hormoneData: hormoneData, scheduleProperties: scheduleProperties)
            hormones.append(hormone)
        }
        return hormones
    }
    
    func createNewHormone(_ scheduleProperties: HormoneScheduleProperties) -> Hormonal? {
        if let newHormoneDataFromStore = entities.createNewManagedHormone() {
            return Hormone(hormoneData: newHormoneDataFromStore, scheduleProperties: scheduleProperties)
        }
        return nil
    }

    func delete(_ hormone: Hormonal) {
        entities.deleteManagedHormoneData([CoreDataEntityAdapter.convertToHormoneStruct(hormone)])
    }

    func pushLocalChanges(_ hormones: [Hormonal], doSave: Bool=true) {
        guard hormones.count > 0 else { return }
        let hormoneData = hormones.map { h in CoreDataEntityAdapter.convertToHormoneStruct(h) }
        self.pushLocalChanges(hormoneData, doSave: doSave)
    }
    
    func save() {
        stack.save(saverName: "Hormone Store")
    }
    
    private func pushLocalChanges(_ hormoneData: [HormoneStruct], doSave: Bool) {
        entities.pushHormoneDataToManagedContext(hormoneData, doSave: doSave)
    }
}
