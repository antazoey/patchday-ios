//
//  PatchDataCalling.swift
//  PDKit
//
//  Created by Juliya Smith on 9/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PDCoreDataDelegate: Saving {

    /// Load the stored pill from Core Data into memory.
    ///
    /// - Returns: The list of stored pills.
    func createPills() -> [Swallowable]

    /// Creates a new stored pill and returns it on success.
    ///
    /// - Returns: The new pill on success.
    func createNewPill() -> Swallowable?

    /// Creates a new stored pill, names it with the given name, and returns it on success.
    ///
    /// - Parameter name: The name of the pill to create
    /// - Returns: The new pill on success.
    func createNewPill(named name: String) -> Swallowable?

    /// Loads the stored hormones from Core Data into memory.
    ///
    /// - Parameters:
    ///   - expiration: The expiration interval user default
    ///   - deliveryMethod: The value of the delivery method user default
    /// - Returns: The list of stored hormones.
    func loadHormones(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> [Hormonal]

    /// Creates a new stored hormone and returns it on success.
    ///
    /// - Parameters:
    ///   - expiration: The expiration interval user default
    ///   - deliveryMethod: The value of the delivery method user default
    /// - Returns: The new hormone on success.
    func createNewHormone(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> Hormonal?

    /// Load the stored sites from Core Data into memory.
    ///
    /// - Parameters:
    ///   - expiration: The expiration interval user default
    ///   - deliveryMethod: The value of the delivery method user default
    /// - Returns: The list of stored sites.
    func loadSites(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> [Bodily]

    /// Creates a mew stored site and returns it on success.
    ///
    /// - Parameters:
    ///   - expiration: The expiration interval user default
    ///   - deliveryMethod: The value of the delivery method user default
    /// - Returns: The new stored site on success.
    func createNewSite(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> Bodily?

    /// Resets Core Data.
    func nuke()
}
