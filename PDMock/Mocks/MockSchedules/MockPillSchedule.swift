//
//  MockPillSchedule.swift
//  PDMock
//
//  Created by Juliya Smith on 4/26/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class MockPillSchedule: PillScheduling {
    
    public var count: Int = 0
    
    public var all: [Swallowable] = []
    
    public var nextDue: Swallowable? = nil
    
    public var totalDue: Int = 0
    
    public var insertNewCallArgs: [(() -> ())?] = []
    public var insertNewReturnValue: Swallowable? = nil
    public func insertNew(onSuccess: (() -> ())?) -> Swallowable? {
        insertNewCallArgs.append(onSuccess)
        return insertNewReturnValue
    }
    
    public var subscriptIndexCallArgs: [Index] = []
    public var subscriptIndexReturnValue: Swallowable? = nil
    public subscript(index: Index) -> Swallowable? {
        subscriptIndexCallArgs.append(index)
        return subscriptIndexReturnValue
    }
    
    public var subscriptIdCallArgs: [UUID] = []
    public var subscriptIdReturnValue: Swallowable? = nil
    public subscript(id: UUID) -> Swallowable? {
        subscriptIdCallArgs.append(id)
        return subscriptIdReturnValue
    }
    
    public var setIndexCallArgs: [(Index, PillAttributes)] = []
    public func set(at index: Index, with attributes: PillAttributes) {
        setIndexCallArgs.append((index, attributes))
    }
    
    public var setIdCallArgs: [(UUID, PillAttributes)] = []
    public func set(by id: UUID, with attributes: PillAttributes) {
        setIdCallArgs.append((id, attributes))
    }
    
    public var resetCallCount = 0
    public func reset() {
        resetCallCount += 1
    }
    
    public var swallowIdCallArgs: [(UUID, (() -> ())?)] = []
    public func swallow(_ id: UUID, onSuccess: (() -> ())?) {
        swallowIdCallArgs.append((id, onSuccess))
    }
    
    public var swallowCallArgs: [(() -> ())?] = []
    public func swallow(onSuccess: (() -> ())?) {
        swallowCallArgs.append(onSuccess)
    }
    
    public var indexOfCallArgs: [Swallowable] = []
    public var indexOfReturnsValue = 0
    public func indexOf(_ pill: Swallowable) -> Index? {
        indexOfCallArgs.append(pill)
        return indexOfReturnsValue
    }
    
    public var shareDataCallCount = 0
    public func shareData() {
        shareDataCallCount += 1
    }
    
    public var deleteCallArgs: [Index] = []
    public func delete(at index: Index) {
        deleteCallArgs.append(index)
    }
}
