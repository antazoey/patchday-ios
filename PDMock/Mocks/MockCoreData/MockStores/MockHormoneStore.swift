//
//  MockHormonesStore.swift
//  PDMock
//
//  Created by Juliya Smith on 1/9/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class MockHormoneStore: HormoneStoring, PDMocking {

    public var getStoredHormonesReturnValues: [[Hormonal]] = []
    public var createNewHormoneReturnValue: Hormonal? = MockHormone()
    public var deleteCallArgs: [Hormonal] = []
    public var pushLocalChangesCallArgs: [([Hormonal], Bool)] = []
    
    public init() {}
    
    public func resetMock() {
        getStoredHormonesReturnValues = []
        createNewHormoneReturnValue = MockHormone()
        deleteCallArgs = []
    }
    
    public func getStoredHormones(_ scheduleProperties: HormoneScheduleProperties) -> [Hormonal] {
        if let mockHormoneList = getStoredHormonesReturnValues.first {
            getStoredHormonesReturnValues.remove(at: 0)
            return mockHormoneList
        }
        return []
    }
    
    public func createNewHormone(_ scheduleProperties: HormoneScheduleProperties) -> Hormonal? {
        return createNewHormoneReturnValue
    }
    
    public func delete(_ hormone: Hormonal) {
        deleteCallArgs.append(hormone)
    }
    
    public func pushLocalChanges(_ hormones: [Hormonal], doSave: Bool) {
        pushLocalChangesCallArgs.append((hormones, doSave))
    }
}
