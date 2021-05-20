//
// Created by Juliya Smith on 1/7/20.
// Copyright (c) 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockUserDefaultsWriter: PDMocking, UserDefaultsWriting {

    public var deliveryMethod = DeliveryMethodUD(DefaultSettings.DeliveryMethodRawValue)
    public var expirationInterval = ExpirationIntervalUD(
        DefaultSettings.ExpirationIntervalRawValue
    )
    public var quantity = QuantityUD(DefaultSettings.QuantityRawValue)
    public var notifications = NotificationsUD(DefaultSettings.NotificationsRawValue)
    public var notificationsMinutesBefore = NotificationsMinutesBeforeUD(
        DefaultSettings.NotificationsMinutesBeforeRawValue
    )
    public var mentionedDisclaimer = MentionedDisclaimerUD(
        DefaultSettings.MentionedDisclaimerRawValue
    )
    public var siteIndex = SiteIndexUD(DefaultSettings.SiteIndexRawValue)
    public var pillsEnabled = PillsEnabledUD(DefaultSettings.PillsEnabledRawValue)

    public init() { }

    public func resetMock() {
        replaceStoredDeliveryMethodCallArgs = []
        replaceStoredExpirationIntervalCallArgs = []
        replaceStoredQuantityCallArgs = []
        resetCallArgs = []
        replaceSiteIndexMockReturnValue = 0
    }

    public var resetCallArgs: [Int] = []
    public func reset(defaultSiteCount: Int) {
        resetCallArgs.append(defaultSiteCount)
    }

    public var replaceStoredDeliveryMethodCallArgs: [DeliveryMethod] = []
    public func replaceStoredDeliveryMethod(to newValue: DeliveryMethod) {
        replaceStoredDeliveryMethodCallArgs.append(newValue)
    }

    public var replaceStoredExpirationIntervalCallArgs: [ExpirationInterval] = []
    public func replaceStoredExpirationInterval(to newValue: ExpirationInterval) {
        replaceStoredExpirationIntervalCallArgs.append(newValue)
    }

    public var replaceStoredXDaysCallArgs: [String] = []
    public func replaceStoredXDays(to newValue: String) {
        replaceStoredXDaysCallArgs.append(newValue)
    }

    public var replaceStoredQuantityCallArgs: [Int] = []
    public func replaceStoredQuantity(to newValue: Int) {
        replaceStoredQuantityCallArgs.append(newValue)
        self.quantity = QuantityUD(newValue)
    }

    public var replaceStoredNotificationsCallArgs: [Bool] = []
    public func replaceStoredNotifications(to newValue: Bool) {
        replaceStoredNotificationsCallArgs.append(newValue)
        self.notifications = NotificationsUD(newValue)
    }

    public var replaceStoredNotificationsMinutesBeforeCallArgs: [Int] = []
    public func replaceStoredNotificationsMinutesBefore(to newValue: Int) {
        replaceStoredNotificationsMinutesBeforeCallArgs.append(newValue)
        self.notificationsMinutesBefore = NotificationsMinutesBeforeUD(
            newValue
        )
    }

    public var replaceStoredMentionedDisclaimerCallArgs: [Bool] = []
    public func replaceStoredMentionedDisclaimer(to newValue: Bool) {
        replaceStoredMentionedDisclaimerCallArgs.append(newValue)
        self.mentionedDisclaimer = MentionedDisclaimerUD(newValue)
    }

    public var replaceSiteIndexMockReturnValue = 0
    public var replaceStoredSiteIndexCallArgs: [Index] = []
    public func replaceStoredSiteIndex(to newValue: Index) -> Index {
        replaceStoredSiteIndexCallArgs.append(newValue)
        self.siteIndex = SiteIndexUD(newValue)
        return newValue
    }

    public var incrementStoredSiteIndexCallArgs: [Int?] = []
    public func incrementStoredSiteIndex(from start: Int?) -> Index {
        incrementStoredSiteIndexCallArgs.append(start)
        self.siteIndex = SiteIndexUD(self.siteIndex.rawValue + 1)
        return self.siteIndex.rawValue + 1
    }

    public var replaceStoredPillsEnabledCallArgs: [Bool] = []
    public func replaceStoredPillsEnabled(to newValue: Bool) {
        replaceStoredPillsEnabledCallArgs.append(newValue)
    }
}
