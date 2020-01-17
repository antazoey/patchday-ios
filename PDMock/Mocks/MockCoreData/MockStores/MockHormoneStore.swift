//
//  MockHormonesStore.swift
//  PDMock
//
//  Created by Juliya Smith on 1/9/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class MockHormoneStore: MockPatchDataStore<Hormonal>, HormoneStoring {
    
    public override init() {
        super.init()
        createNewObjectReturnValue = MockHormone()
    }

    public func getStoredHormones(_ scheduleProperties: HormoneScheduleProperties) -> [Hormonal] {
        getNextMockStoredObjects()
    }
    
    public func createNewHormone(_ scheduleProperties: HormoneScheduleProperties) -> Hormonal? {
        createNewObjectReturnValue
    }
    
    public func delete(_ hormone: Hormonal) {
        deleteCallArgs.append(hormone)
    }
    
    public func pushLocalChangesToManagedContext(_ hormones: [Hormonal], doSave: Bool) {
        pushLocalChangesCallArgs.append((hormones, doSave))
    }
}
