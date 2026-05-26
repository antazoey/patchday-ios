//
//  MockUbiquitousKVStore.swift
//  PDTest
//

import Foundation
import PDKit

public final class MockUbiquitousKVStore: UbiquitousKeyValueStoring {

    public var storage: [String: Any] = [:]
    public var setCalls: [(key: String, value: Any?)] = []
    public var synchronizeCallCount = 0
    public var observerHandler: (([String]) -> Void)?

    public init() {}

    public func set(_ value: Any?, for key: String) {
        setCalls.append((key, value))
        if let value = value {
            storage[key] = value
        } else {
            storage.removeValue(forKey: key)
        }
    }

    public func object(for key: String) -> Any? {
        storage[key]
    }

    @discardableResult
    public func synchronize() -> Bool {
        synchronizeCallCount += 1
        return true
    }

    public func startObserving(_ handler: @escaping ([String]) -> Void) {
        observerHandler = handler
    }

    /// Test hook — simulate a remote-change push.
    public func simulateRemoteChange(_ keys: [String]) {
        observerHandler?(keys)
    }
}
