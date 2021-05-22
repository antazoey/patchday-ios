//
//  UserDefaultsManaging.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.

import Foundation

public protocol UserDefaultsWriting: UserDefaultsReading {

    /// Reset all values back to their default values. The `defaultSiteCount` depends on the `DeliveryMethod`.
    func reset(defaultSiteCount: Int)

    /// Replace the value of `deliveryMethod` with the given one.
    func replaceDeliveryMethod(to newMethod: DeliveryMethod)

    /// Replace the value of `expirationInterval` with the given one.
    func replaceExpirationInterval(to newValue: ExpirationInterval)

    /// Replace the value of `XDays` with the given one. Accepts 1...25.
    func replaceXDays(to newValue: String)

    /// Replace the value of `quantity` with the given one. Accepts 1, 2, 3, 4.
    func replaceQuantity(to newValue: Int)

    /// Replace the value of `notifications` with the given one.
    func replaceNotifications(to newNotifications: Bool)

    /// Replace the value of `notificationsMinutesBefore` with the given one.
    func replaceNotificationsMinutesBefore(to newValue: Int)

    /// Replace the value of `mentionedDisclaimer` with the given one.
    func replaceMentionedDisclaimer(to newValue: Bool)

    /// Increment the site index modularly. Use `start` when changing sites outside of schedule order.
    @discardableResult
    func incrementStoredSiteIndex(from start: Int?) -> Index

    /// Replace the value of `siteIndex` with the given one.
    /// Accepts `0..<siteCount`. Returns the index after trying to set.
    @discardableResult
    func replaceSiteIndex(to newValue: Index) -> Index

    /// Replace the value that indicates whether pills are activated.
    func replacePillsEnabled(to newValue: Bool)

    /// Replace the value that indicates to use static expiration times instead of dynamic.
    func replaceUseStaticExpirationTime(to newValue: Bool)
}
