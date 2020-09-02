//
//  PillStoring.swift
//  PDKit
//
//  Created by Juliya Smith on 1/9/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PillStoring {

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
