//
//  MockPillStore.swift
//  PDMock
//
//  Created by Juliya Smith on 1/16/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class MockPillStore: MockPatchDataStore<Swallowable>, PillStoring {

    public override init() {
        super.init()
        createNewObjectReturnValue = MockPill()
    }

    public func getStoredPills() -> [Swallowable] {
        getNextMockStoredObjects()
    }
    
    public func createNewPill(name: String) -> Swallowable? {
        var pill = createNewObjectReturnValue
        pill?.name = name
        return pill
    }
    
    public func createNewPill() -> Swallowable? {
        createNewObjectReturnValue
    }
    
    public func delete(_ hormone: Swallowable) {
        deleteCallArgs.append(hormone)
    }
    
    public func pushLocalChangesToManagedContext(_ hormones: [Swallowable], doSave: Bool) {
        pushLocalChangesCallArgs.append((hormones, doSave))
    }
}
