//
// Created by Juliya Smith on 1/6/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class MockUserDefaults: UserDefaultsWriting {

    public var deliveryMethod: DeliveryMethodUD = DeliveryMethodUD()
    public var expirationInterval: ExpirationIntervalUD = ExpirationIntervalUD()
    public var quantity: QuantityUD = QuantityUD()
    public var notifications: NotificationsUD = NotificationsUD()
    public var notificationsMinutesBefore: NotificationsMinutesBeforeUD = NotificationsMinutesBeforeUD()
    public var mentionedDisclaimer: MentionedDisclaimerUD = MentionedDisclaimerUD()
    public var siteIndex: SiteIndexUD = SiteIndexUD()
    public var theme: PDThemeUD = PDThemeUD()

    public func reset(defaultSiteCount: Int) {

    }
    
    public func replaceStoredDeliveryMethod(to method: DeliveryMethod) {

    }
    
    public func replaceStoredExpirationInterval(to interval: ExpirationInterval) {

    }
    
    public func replaceStoredQuantity(to q: Int) {

    }
    
    public func replaceStoredNotifications(to b: Bool) {

    }
    
    public func replaceStoredNotificationsMinutesBefore(to i: Int) {

    }
    
    public func replaceStoredMentionedDisclaimer(to b: Bool) {

    }
    
    public func replaceStoredSiteIndex(to i: Int, siteCount: Int) -> Index {

    }
    
    public func replaceStoredTheme(to t: PDTheme) {

    }
}
