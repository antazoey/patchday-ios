//
//  UserDefaultsManaging.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.

import Foundation

public protocol UserDefaultsWriting: UserDefaultsReading {

    /// Reset all values back to their default values. The defaultSiteCount depends on the DeliveryMethod.
    func reset(defaultSiteCount: Int)

    /// Replace the value of 'delivery method' with the given one.
    func replaceStoredDeliveryMethod(to newMethod: DeliveryMethod)

    /// Replace the value of 'expiration interval' with the given one.
    func replaceStoredExpirationInterval(to newExpirationInterval: ExpirationInterval)

    /// Replace the value of 'quantity' with the given one. Accepts 1, 2, 3, 4.
    func replaceStoredQuantity(to newQuantity: Int)

    /// Replace the value of 'notifications' with the given one.
    func replaceStoredNotifications(to newNotifications: Bool)

    /// Replace the value of 'notifications minutes before' with the given one.
    func replaceStoredNotificationsMinutesBefore(to newNotificationsMinutesBefore: Int)

    /// Replace the value of 'mentioned disclaimer' with the given one.
    func replaceStoredMentionedDisclaimer(to newMentionedDisclaimer: Bool)

    /// Increment the site index modularly. Use `start` when changing sites outside of schedule order.
    @discardableResult
    func incrementStoredSiteIndex(from start: Int?) -> Index

    /// Replace the value of 'site index' with the given one.
    /// Accepts 0..<siteCount. Returns the index after trying to set.
    @discardableResult
    func replaceStoredSiteIndex(to i: Index) -> Index

    /// Replace the value that indicates whether pills are activated.
    func replaceStoredPillsEnabled(to newValue: Bool)
}
