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

    public func reset(defaultSiteCount: Int = 4) {
        replaceStoredDeliveryMethod(to: DefaultSettings.DELIVERY_METHOD_VALUE)
        replaceStoredExpirationInterval(to: DefaultSettings.EXPIRATION_INTERVAL_VALUE)
        replaceStoredQuantity(to: DefaultSettings.QUANTITY_RAW_VALUE)
        replaceStoredNotifications(to: DefaultSettings.NOTIFICATIONS_RAW_VALUE)
        replaceStoredNotificationsMinutesBefore(
            to: DefaultSettings.NOTIFICATIONS_MINUTES_BEFORE_RAW_VALUE
        )
        replaceStoredMentionedDisclaimer(to: DefaultSettings.MENTIONED_DISCLAIMER_RAW_VALUE)
        replaceStoredSiteIndex(to: DefaultSettings.SITE_INDEX_RAW_VALUE)
    }

    public func replaceStoredDeliveryMethod(to newValue: DeliveryMethod) {
        let rawValue = DeliveryMethodUD.getRawValue(for: newValue)
        handler.replace(deliveryMethod, to: rawValue)
    }

    @objc public func replaceStoredQuantity(to newValue: Int) {
        handler.replace(quantity, to: newValue)
    }

    public func replaceStoredExpirationInterval(to newValue: ExpirationInterval) {
        let rawValue = ExpirationIntervalUD.getRawValue(for: newValue)
        handler.replace(expirationInterval, to: rawValue)
    }

    public func replaceStoredXDays(to newValue: String) {
        handler.replace(expirationInterval.xDays, to: newValue)
    }

    public func replaceStoredNotifications(to newValue: Bool) {
        handler.replace(notifications, to: newValue)
    }

    public func replaceStoredNotificationsMinutesBefore(to newValue: Int) {
        handler.replace(notificationsMinutesBefore, to: newValue)
    }

    public func replaceStoredMentionedDisclaimer(to newValue: Bool) {
        handler.replace(mentionedDisclaimer, to: newValue)
    }

    public func replaceStoredPillsEnabled(to newValue: Bool) {
        handler.replace(pillsEnabled, to: newValue)
    }

    @discardableResult
    public func replaceStoredSiteIndex(to newValue: Index) -> Index {
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
            return replaceStoredSiteIndex(to: 0)
        }
        let incrementedIndex = currentIndex + 1
        return replaceStoredSiteIndex(to: incrementedIndex)
    }

    private func getXDays(_ expirationInterval: ExpirationIntervalUD) -> String {
        let defaultXDays = "\(expirationInterval.days)"
        let value = handler.load(.XDays) ?? defaultXDays
        return expirationInterval.value == .EveryXDays ? value : defaultXDays
    }
}
