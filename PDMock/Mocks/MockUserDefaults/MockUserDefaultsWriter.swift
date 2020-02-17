//
// Created by Juliya Smith on 1/7/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class MockUserDefaultsWriter: UserDefaultsWriting, PDMocking {

    public var deliveryMethod = DeliveryMethodUD()
    public var expirationInterval = ExpirationIntervalUD()
    public var quantity = QuantityUD()
    public var notifications = NotificationsUD()
    public var notificationsMinutesBefore = NotificationsMinutesBeforeUD()
    public var mentionedDisclaimer = MentionedDisclaimerUD()
    public var siteIndex = SiteIndexUD()
    public var theme = PDThemeUD()
    
    public var resetCallArgs: [Int] = []
    public var replaceSiteIndexMockReturnValue = 0
    
    public var incrementSiteIndexCallCount = 0
    
    public init() {}
    
    public func resetMock() {
        resetCallArgs = []
        self.deliveryMethod = DeliveryMethodUD()
        self.expirationInterval = ExpirationIntervalUD()
        self.quantity = QuantityUD()
        self.notifications = NotificationsUD()
        self.notificationsMinutesBefore = NotificationsMinutesBeforeUD()
        self.mentionedDisclaimer = MentionedDisclaimerUD()
        self.siteIndex = SiteIndexUD()
        self.theme = PDThemeUD()
    }
    
    public func reset(defaultSiteCount: Int) {
        resetCallArgs.append(defaultSiteCount)
    }
    
    public func replaceStoredDeliveryMethod(to newMethod: DeliveryMethod) {
        self.deliveryMethod.value = newMethod
    }
    
    public func replaceStoredExpirationInterval(to newExpirationInterval: ExpirationInterval) {
        self.expirationInterval.value = newExpirationInterval
    }
    
    public func replaceStoredQuantity(to newQuantity: Int) {
        if let q = Quantity(rawValue: newQuantity) {
            self.quantity.value = q
        }
    }
    
    public func replaceStoredNotifications(to newNotitifications: Bool) {
        self.notifications.value = newNotitifications
    }
    
    public func replaceStoredNotificationsMinutesBefore(to newNotificationsMinutesBefore: Int) {
        self.notificationsMinutesBefore.value = newNotificationsMinutesBefore
    }
    
    public func replaceStoredMentionedDisclaimer(to newMentionedDisclaimer: Bool) {
        self.mentionedDisclaimer.value = newMentionedDisclaimer
    }
    
    public func replaceStoredSiteIndex(to i: Index) -> Index {
        self.siteIndex.value = i
        return i
    }
    
    public func incrementStoredSiteIndex() -> Index {
        incrementSiteIndexCallCount += 1
        return incrementSiteIndexCallCount
    }
    
    public func replaceStoredTheme(to newTheme: PDTheme) {
        self.theme.value = newTheme
    }
}
