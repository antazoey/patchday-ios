//
//  MockPillStore.swift
//  PDMock
//
//  Created by Juliya Smith on 1/16/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockPillStore: MockPatchDataStore<Swallowable>, PillStoring {

    public var state: PillScheduleState = PillScheduleState.Working

    public override init() {
        super.init()
        newObjectFactory = { () in MockPill() }
    }

    public func getStoredPills() -> [Swallowable] {
        getNextMockStoredObjects()
    }

    public func createNewPill(name: String) -> Swallowable? {
        if let mock = newObjectFactory?() as? MockPill {
            mock.name = name
            return mock
        }
        return nil
    }

    public func createNewPill() -> Swallowable? {
        newObjectFactory?()
    }

    public func delete(_ hormone: Swallowable) {
        deleteCallArgs.append(hormone)
    }

    public func pushLocalChangesToManagedContext(_ hormones: [Swallowable], doSave: Bool) {
        pushLocalChangesCallArgs.append((hormones, doSave))
    }
}
