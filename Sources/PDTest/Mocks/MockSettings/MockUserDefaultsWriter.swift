//
// Created by Juliya Smith on 1/7/20.
// Copyright (c) 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockUserDefaultsWriter: PDMocking, UserDefaultsWriting {

    public var deliveryMethod = DeliveryMethodUD(DefaultSettings.DELIVERY_METHOD_RAW_VALUE)
    public var expirationInterval = ExpirationIntervalUD(
        DefaultSettings.EXPIRATION_INTERVAL_RAW_VALUE
    )
    public var quantity = QuantityUD(DefaultSettings.QUANTITY_RAW_VALUE)
    public var notifications = NotificationsUD(DefaultSettings.NOTIFICATIONS_RAW_VALUE)
    public var notificationsMinutesBefore = NotificationsMinutesBeforeUD(
        DefaultSettings.NOTIFICATIONS_MINUTES_BEFORE_RAW_VALUE
    )
    public var mentionedDisclaimer = MentionedDisclaimerUD(
        DefaultSettings.MENTIONED_DISCLAIMER_RAW_VALUE
    )
    public var siteIndex = SiteIndexUD(DefaultSettings.SITE_INDEX_RAW_VALUE)
    public var pillsEnabled = PillsEnabledUD(DefaultSettings.PILLS_ENABLED_RAW_VALUE)

    public init() { }

    public func resetMock() {
        replaceDeliveryMethodCallArgs = []
        replaceExpirationIntervalCallArgs = []
        replaceQuantityCallArgs = []
        resetCallArgs = []
        replaceSiteIndexMockReturnValue = 0
    }

    public var resetCallArgs: [Int] = []
    public func reset(defaultSiteCount: Int) {
        resetCallArgs.append(defaultSiteCount)
    }

    public var replaceDeliveryMethodCallArgs: [DeliveryMethod] = []
    public func replaceDeliveryMethod(to newValue: DeliveryMethod) {
        replaceDeliveryMethodCallArgs.append(newValue)
    }

    public var replaceExpirationIntervalCallArgs: [ExpirationInterval] = []
    public func replaceExpirationInterval(to newValue: ExpirationInterval) {
        replaceExpirationIntervalCallArgs.append(newValue)
    }

    public var replaceXDaysCallArgs: [String] = []
    public func replaceXDays(to newValue: String) {
        replaceXDaysCallArgs.append(newValue)
    }

    public var replaceQuantityCallArgs: [Int] = []
    public func replaceQuantity(to newValue: Int) {
        replaceQuantityCallArgs.append(newValue)
        self.quantity = QuantityUD(newValue)
    }

    public var replaceNotificationsCallArgs: [Bool] = []
    public func replaceNotifications(to newValue: Bool) {
        replaceNotificationsCallArgs.append(newValue)
        self.notifications = NotificationsUD(newValue)
    }

    public var replaceNotificationsMinutesBeforeCallArgs: [Int] = []
    public func replaceNotificationsMinutesBefore(to newValue: Int) {
        replaceNotificationsMinutesBeforeCallArgs.append(newValue)
        self.notificationsMinutesBefore = NotificationsMinutesBeforeUD(
            newValue
        )
    }

    public var replaceMentionedDisclaimerCallArgs: [Bool] = []
    public func replaceMentionedDisclaimer(to newValue: Bool) {
        replaceMentionedDisclaimerCallArgs.append(newValue)
        self.mentionedDisclaimer = MentionedDisclaimerUD(newValue)
    }

    public var replaceSiteIndexMockReturnValue = 0
    public var replaceSiteIndexCallArgs: [Index] = []
    public func replaceSiteIndex(to newValue: Index) -> Index {
        replaceSiteIndexCallArgs.append(newValue)
        self.siteIndex = SiteIndexUD(newValue)
        return newValue
    }

    public var incrementStoredSiteIndexCallArgs: [Int?] = []
    public func incrementStoredSiteIndex(from start: Int?) -> Index {
        incrementStoredSiteIndexCallArgs.append(start)
        self.siteIndex = SiteIndexUD(self.siteIndex.rawValue + 1)
        return self.siteIndex.rawValue + 1
    }

    public var replacePillsEnabledCallArgs: [Bool] = []
    public func replacePillsEnabled(to newValue: Bool) {
        replacePillsEnabledCallArgs.append(newValue)
    }
}
