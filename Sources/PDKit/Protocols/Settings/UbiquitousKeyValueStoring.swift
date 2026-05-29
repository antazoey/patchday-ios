//
//  UbiquitousKeyValueStoring.swift
//  PDKit
//
//  Wraps `NSUbiquitousKeyValueStore` so the settings writer can
//  optionally route through it without depending on Foundation's
//  concrete type. Tests substitute a mock.
//

import Foundation

public protocol UbiquitousKeyValueStoring: AnyObject {
    func set(_ value: Any?, for key: String)
    func object(for key: String) -> Any?
    @discardableResult
    func synchronize() -> Bool

    /// Fires with the array of changed keys whenever the store reports
    /// `didChangeExternallyNotification` (e.g. another device pushed a change).
    /// Called on the main queue.
    func startObserving(_ handler: @escaping ([String]) -> Void)
}
