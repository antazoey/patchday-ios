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
        let def = DefaultSettings.DELIVERY_METHOD_RAW_VALUE
        let deliveryMethod = handler.load(setting: .DeliveryMethod, defaultValue: def)
        return DeliveryMethodUD(deliveryMethod)
    }

    public var expirationInterval: ExpirationIntervalUD {
        let defaultInterval = DefaultSettings.EXPIRATION_INTERVAL_RAW_VALUE
        let expirationInterval = handler.load(
            setting: .ExpirationInterval, defaultValue: defaultInterval
        )
        let expirationIntervalUserDefault = ExpirationIntervalUD(expirationInterval)
        expirationIntervalUserDefault.xDays.rawValue = getXDays(expirationIntervalUserDefault)
        return expirationIntervalUserDefault
    }

    public var quantity: QuantityUD {
        let def = DefaultSettings.QUANTITY_RAW_VALUE
        let quantity = handler.load(setting: .Quantity, defaultValue: def)
        return QuantityUD(quantity)
    }

    public var notifications: NotificationsUD {
        let def = DefaultSettings.NOTIFICATIONS_RAW_VALUE
        let notifications = handler.load(setting: .Notifications, defaultValue: def)
        return NotificationsUD(notifications)
    }

    public var notificationsMinutesBefore: NotificationsMinutesBeforeUD {
        let def = DefaultSettings.NOTIFICATIONS_MINUTES_BEFORE_RAW_VALUE
        let notificationsMinutesBefore = handler.load(
            setting: .NotificationsMinutesBefore, defaultValue: def
        )
        return NotificationsMinutesBeforeUD(notificationsMinutesBefore)
    }

    public var mentionedDisclaimer: MentionedDisclaimerUD {
        let def = DefaultSettings.MENTIONED_DISCLAIMER_RAW_VALUE
        let mentionedDisclaimer = handler.load(setting: .MentionedDisclaimer, defaultValue: def)
        return MentionedDisclaimerUD(mentionedDisclaimer)
    }

    public var siteIndex: SiteIndexUD {
        let def = DefaultSettings.SITE_INDEX_RAW_VALUE
        let siteIndex = handler.load(setting: .SiteIndex, defaultValue: def)
        return SiteIndexUD(siteIndex)
    }

    public var pillsEnabled: PillsEnabledUD {
        let def = DefaultSettings.PILLS_ENABLED_RAW_VALUE
        let pillsEnabled = handler.load(setting: .PillsEnabled, defaultValue: def)
        return PillsEnabledUD(pillsEnabled)
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
        return expirationInterval.value == .EveryXDays
            ? handler.load(setting: .XDays, defaultValue: defaultXDays)
            : defaultXDays
    }
}
