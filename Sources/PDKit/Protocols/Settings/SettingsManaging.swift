//
//  SettingsManaging.swift
//  PatchData
//
//  Created by Juliya Smith on 11/11/19.

import Foundation

public protocol SettingsManaging: UserDefaultsReading {

    /// Set the stored delivery method for hormones.
    func setDeliveryMethod(to newMethod: DeliveryMethod)

    /// Set the number of hormones in the schedule.
    func setQuantity(to newQuantity: Int)

    /// Set the expiration interval for when hormones expire.
    func setExpirationInterval(to newInterval: String)

    /// Enable notifications globally for hormones.
    func setNotifications(to newValue: Bool)

    /// Set the minutes-before to receive a notification before hormone expiration.
    func setNotificationsMinutesBefore(to newMinutes: Int)

    /// Indicate that the disclaimer has been presented to the user at least once (so it is not presented again).
    func setMentionedDisclaimer(to newValue: Bool)

    /// Enable pills functionality.
    func setPillsEnabled(to newValue: Bool)

    /// Set the current site index.
    @discardableResult func setSiteIndex(to newValue: Index) -> Index

    /// Set the current value for the `useStaticExpirationTime` setting.
    func setUseStaticExpirationTime(to newValue: Bool)

    /// Reset all settings to their default values.
    func reset(defaultSiteCount: Int)
}
