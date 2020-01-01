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

    func getStoredHormones(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> [Hormonal] {
        var hormones: [Hormonal] = []
        for hormoneData in entities.getStoredHormoneData(
            expirationInterval: expiration, deliveryMethod: deliveryMethod
        ) {
            let hormone = Hormone(hormoneData: hormoneData, interval: expiration, deliveryMethod: deliveryMethod)
            hormones.append(hormone)
        }
        return hormones
    }

    func createNewHormone(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> Hormone? {
        if let newHormoneDataFromStore = entities.createNewHormone(
            expirationInterval: expiration, deliveryMethod: deliveryMethod
        ) {
            return Hormone(hormoneData: newHormoneDataFromStore, interval: expiration, deliveryMethod: deliveryMethod)
        }
        return nil
    }

    func delete(_ hormone: Hormonal) {
        entities.deleteHormoneData([CoreDataEntityAdapter.convertToHormoneStruct(hormone)])
    }

    func save(_ hormones: [Hormonal]) {
        let hormoneData = hormones.map { h in CoreDataEntityAdapter.convertToHormoneStruct(h) }
        self.save(hormoneData)
    }

    func save(_ hormone: Hormonal) {
        self.save([CoreDataEntityAdapter.convertToHormoneStruct(hormone)])
    }

    private func save(_ hormoneData: [HormoneStruct]) {
        entities.pushHormoneData(hormoneData)
    }
}
