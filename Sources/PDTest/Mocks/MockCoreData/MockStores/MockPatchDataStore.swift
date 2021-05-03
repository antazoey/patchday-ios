//
//  MockPatchDataStore.swift
//  PDTest
//
//  Created by Juliya Smith on 1/16/20.

import Foundation

public class MockPatchDataStore<T>: PDTesting {

    public var getStoredCollectionReturnValues: [[T]] = []
    public var newObjectFactory: (() -> T)?
    public var deleteCallArgs: [T] = []
    public var pushLocalChangesCallArgs: [([T], Bool)] = []

    public init() { }

    public func resetMock() {
        getStoredCollectionReturnValues = []
        newObjectFactory = nil
        deleteCallArgs = []
        pushLocalChangesCallArgs = []
    }

    public func getNextMockStoredObjects() -> [T] {
        if let ele = getStoredCollectionReturnValues.first {
            getStoredCollectionReturnValues.remove(at: 0)
            return ele
        }
        return []
    }

    public func recordCallDelete(on object: T) {
        deleteCallArgs.append(object)
    }

    public func recordPushLocalChanges(objs: [T], doSave: Bool) {
        pushLocalChangesCallArgs.append((objs, doSave))
    }
}
