//
//  PillStoring.swift
//  PDKit
//
//  Created by Juliya Smith on 1/9/20.

import Foundation

public enum PillScheduleState {
    case Initial
    case Working
}

public protocol PillStoring {

    /// Returns True if anyone of the stored pill have saved times.
    var state: PillScheduleState { get }

    /// Fetches all the pills from storage.
    func getStoredPills() -> [Swallowable]

    /// Creates a new stored pill with the given name and returns it.
    func createNewPill(name: String) -> Swallowable?

    /// Creates a new stored pill and returns it.
    func createNewPill() -> Swallowable?

    /// Deletes the given pill from storage.
    func delete(_ pill: Swallowable)

    /// Pushes the given pills to the managed context to stage changes for saving and optionally writes-through.
    func pushLocalChangesToManagedContext(_ pills: [Swallowable], doSave: Bool)
}
