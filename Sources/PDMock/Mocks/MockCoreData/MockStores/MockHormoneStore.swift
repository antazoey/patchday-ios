//
//  MockHormonesStore.swift
//  PDMock
//
//  Created by Juliya Smith on 1/9/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockHormoneStore: MockPatchDataStore<Hormonal>, HormoneStoring {

    public override init() {
        super.init()
        newObjectFactory = { () in MockHormone() }
    }

    public func getStoredHormones(_ settings: UserDefaultsReading) -> [Hormonal] {
        getNextMockStoredObjects()
    }

    public func createNewHormone(_ settings: UserDefaultsReading) -> Hormonal? {
        newObjectFactory?()
    }

    public func delete(_ hormone: Hormonal) {
        deleteCallArgs.append(hormone)
    }

    public func pushLocalChangesToManagedContext(_ hormones: [Hormonal], doSave: Bool) {
        pushLocalChangesCallArgs.append((hormones, doSave))
    }

    public var clearSitesFromHormoneCallArgs: [UUID] = []
    public func clearSitesFromHormone(_ hormoneId: UUID) {
        clearSitesFromHormoneCallArgs.append(hormoneId)
    }
}
