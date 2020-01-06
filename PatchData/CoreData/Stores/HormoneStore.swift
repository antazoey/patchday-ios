//
//  HormoneRepository.swift
//  PatchData
//
//  Created by Juliya Smith on 12/24/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class HormoneStore: EntityStore {

    private let log = PDLog<HormoneStore>()

    func getStoredHormones(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> [Hormonal] {
        var hormones: [Hormonal] = []
        let hormoneDataEntries = entities.getStoredHormoneData(
            expiration: expiration, method: deliveryMethod
        )
        for hormoneData in hormoneDataEntries {
            let hormone = Hormone(hormoneData: hormoneData, interval: expiration, deliveryMethod: deliveryMethod)
            hormones.append(hormone)
        }
        return hormones
    }

    func createNewHormone(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> Hormone? {
        if let newHormoneDataFromStore = entities.createNewHormone(expiration: expiration, method: deliveryMethod) {
            return Hormone(hormoneData: newHormoneDataFromStore, interval: expiration, deliveryMethod: deliveryMethod)
        }
        return nil
    }

    func delete(_ hormone: Hormonal) {
        entities.deleteHormoneData([CoreDataEntityAdapter.convertToHormoneStruct(hormone)])
    }

    func pushLocalChangesToBeSaved(_ hormones: [Hormonal], doSave: Bool=true) {
        if hormones.count == 0 {

        }
        let hormoneData = hormones.map { h in CoreDataEntityAdapter.convertToHormoneStruct(h) }
        self.pushLocalChangesToBeSaved(hormoneData, doSave: doSave)
    }

    func pushLocalChangesToBeSaved(_ hormone: Hormonal, doSave: Bool=true) {
        self.pushLocalChangesToBeSaved([CoreDataEntityAdapter.convertToHormoneStruct(hormone)], doSave: doSave)
    }

    private func pushLocalChangesToBeSaved(_ hormoneData: [HormoneStruct], doSave: Bool) {
        entities.pushHormoneData(hormoneData, doSave: doSave)
    }
}
