//
//  PDUbiquitousKVStore.swift
//  PatchData
//
//  Real `NSUbiquitousKeyValueStore` adapter.
//

import Foundation
import PDKit

public final class PDUbiquitousKVStore: UbiquitousKeyValueStoring {

    private let store = NSUbiquitousKeyValueStore.default
    private var observer: NSObjectProtocol?

    public init() {}

    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    public func set(_ value: Any?, for key: String) {
        store.set(value, forKey: key)
    }

    public func object(for key: String) -> Any? {
        store.object(forKey: key)
    }

    @discardableResult
    public func synchronize() -> Bool {
        store.synchronize()
    }

    public func startObserving(_ handler: @escaping ([String]) -> Void) {
        observer = NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: store,
            queue: .main
        ) { note in
            let changed = note.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] ?? []
            handler(changed)
        }
        _ = store.synchronize()
    }
}

/// Inert implementation used in local-only builds and as a default for
/// tests that don't care about KVS. Set/get fully no-op; observation
/// never fires.
public final class NoOpUbiquitousKVStore: UbiquitousKeyValueStoring {
    public init() {}
    public func set(_ value: Any?, for key: String) {}
    public func object(for key: String) -> Any? { nil }
    @discardableResult public func synchronize() -> Bool { true }
    public func startObserving(_ handler: @escaping ([String]) -> Void) {}
}
