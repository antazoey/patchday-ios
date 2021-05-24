//
//  UserDefaultsWriter.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/25/17.

import UIKit
import PDKit

public class UserDefaultsWriter: UserDefaultsWriting {

    private let handler: UserDefaultsWriteHandler
    private var sites: SiteStoring

    init(handler: UserDefaultsWriteHandler, siteStore: SiteStoring) {
        self.handler = handler
        self.sites = siteStore
    }

    public var deliveryMethod: DeliveryMethodUD {
        let defaultValue = DefaultSettings.DELIVERY_METHOD_RAW_VALUE
        let deliveryMethod: String? = handler.load(.DeliveryMethod)
        return DeliveryMethodUD(deliveryMethod ?? defaultValue)
    }

    public var expirationInterval: ExpirationIntervalUD {
        let defaultValue = DefaultSettings.EXPIRATION_INTERVAL_RAW_VALUE
        let value: String? = handler.load(.ExpirationInterval)
        let expirationInterval = ExpirationIntervalUD(value ?? defaultValue)
        expirationInterval.xDays.rawValue = getXDays(expirationInterval)
        return expirationInterval
    }

    public var quantity: QuantityUD {
        let defaultQuantity = DefaultSettings.QUANTITY_RAW_VALUE
        let quantity: Int? = handler.load(.Quantity)
        return QuantityUD(quantity ?? defaultQuantity)
    }

    public var notifications: NotificationsUD {
        let defaultValue = DefaultSettings.NOTIFICATIONS_RAW_VALUE
        let value: Bool? = handler.load(.Notifications)
        return NotificationsUD(value ?? defaultValue)
    }

    public var notificationsMinutesBefore: NotificationsMinutesBeforeUD {
        let defaultValue = DefaultSettings.NOTIFICATIONS_MINUTES_BEFORE_RAW_VALUE
        let value: Int? = handler.load(.NotificationsMinutesBefore)
        return NotificationsMinutesBeforeUD(value ?? defaultValue)
    }

    public var mentionedDisclaimer: MentionedDisclaimerUD {
        let defaultValue = DefaultSettings.MENTIONED_DISCLAIMER_RAW_VALUE
        let value: Bool? = handler.load(.MentionedDisclaimer)
        return MentionedDisclaimerUD(value ?? defaultValue)
    }

    public var siteIndex: SiteIndexUD {
        let defaultValue = DefaultSettings.SITE_INDEX_RAW_VALUE
        let value: Int? = handler.load(.SiteIndex)
        return SiteIndexUD(value ?? defaultValue)
    }

    public var pillsEnabled: PillsEnabledUD {
        let defaultValue = DefaultSettings.PILLS_ENABLED_RAW_VALUE
        let value: Bool? = handler.load(.PillsEnabled)
        return PillsEnabledUD(value ?? defaultValue)
    }

    public var useStaticExpirationTime: UseStaticExpirationTimeUD {
        let defaultValue = DefaultSettings.USE_STATIC_EXPIRATION_TIME
        let value: Bool? = handler.load(.UseStaticExpirationTime)
        return UseStaticExpirationTimeUD(value ?? defaultValue)
    }

    public func reset(defaultSiteCount: Int = 4) {
        typealias Defaults = DefaultSettings
        replaceDeliveryMethod(to: Defaults.DELIVERY_METHOD_VALUE)
        replaceExpirationInterval(to: Defaults.EXPIRATION_INTERVAL_VALUE)
        replaceQuantity(to: Defaults.QUANTITY_RAW_VALUE)
        replaceNotifications(to: Defaults.NOTIFICATIONS_RAW_VALUE)
        replaceNotificationsMinutesBefore(to: Defaults.NOTIFICATIONS_MINUTES_BEFORE_RAW_VALUE)
        replaceMentionedDisclaimer(to: Defaults.MENTIONED_DISCLAIMER_RAW_VALUE)
        replaceSiteIndex(to: Defaults.SITE_INDEX_RAW_VALUE)
        replaceUseStaticExpirationTime(to: Defaults.USE_STATIC_EXPIRATION_TIME)
    }

    public func replaceDeliveryMethod(to newValue: DeliveryMethod) {
        let rawValue = DeliveryMethodUD.getRawValue(for: newValue)
        handler.replace(deliveryMethod, to: rawValue)
    }

    @objc public func replaceQuantity(to newValue: Int) {
        handler.replace(quantity, to: newValue)
    }

    public func replaceExpirationInterval(to newValue: ExpirationInterval) {
        let rawValue = ExpirationIntervalUD.getRawValue(for: newValue)
        handler.replace(expirationInterval, to: rawValue)
    }

    public func replaceXDays(to newValue: String) {
        handler.replace(expirationInterval.xDays, to: newValue)
    }

    public func replaceNotifications(to newValue: Bool) {
        handler.replace(notifications, to: newValue)
    }

    public func replaceNotificationsMinutesBefore(to newValue: Int) {
        handler.replace(notificationsMinutesBefore, to: newValue)
    }

    public func replaceMentionedDisclaimer(to newValue: Bool) {
        handler.replace(mentionedDisclaimer, to: newValue)
    }

    public func replacePillsEnabled(to newValue: Bool) {
        handler.replace(pillsEnabled, to: newValue)
    }

    public func replaceUseStaticExpirationTime(to newValue: Bool) {
        handler.replace(useStaticExpirationTime, to: newValue)
    }

    @discardableResult
    public func replaceSiteIndex(to newValue: Index) -> Index {
        let storedSites = sites.getStoredSites()
        if storedSites.count == 0 || newValue >= storedSites.count || newValue < 0 {
            handler.replace(siteIndex, to: 0)
            return 0
        }
        var newIndex = newValue
        let site = storedSites[newIndex]
        if quantity.rawValue != SUPPORTED_HORMONE_UPPER_QUANTITY_LIMIT && site.hormoneCount > 0 {
            for site in storedSites where site.hormoneCount == 0 {
                newIndex = site.order
                break
            }
        }
        PDLog<UserDefaultsWriter>().info("Setting new site index to \(newIndex)")
        handler.replace(siteIndex, to: newIndex)
        return newIndex
    }

    @discardableResult
    public func incrementStoredSiteIndex(from start: Int?=nil) -> Index {
        let currentIndex = start ?? siteIndex.value
        let siteCount = sites.siteCount

        if siteCount == 0 {
            handler.replace(siteIndex, to: 0)
            return 0
        } else if !(0..<siteCount ~= currentIndex) {
            return replaceSiteIndex(to: 0)
        }
        let incrementedIndex = currentIndex + 1
        return replaceSiteIndex(to: incrementedIndex)
    }

    private func getXDays(_ expirationInterval: ExpirationIntervalUD) -> String {
        let defaultXDays = "\(expirationInterval.days)"
        let value = handler.load(.XDays) ?? defaultXDays
        return expirationInterval.value == .EveryXDays ? value : defaultXDays
    }
}
