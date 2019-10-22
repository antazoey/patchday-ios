//
//  PDDefaultManaging.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PDDefaultManaging {
    var deliveryMethod: DeliveryMethodUD { get }
    var expirationInterval: ExpirationIntervalUD { get }
    var quantity: QuantityUD { get }
    var notifications: NotificationsUD { get }
    var notificationsMinutesBefore: NotificationsMinutesBeforeUD { get }
    var mentionedDisclaimer: MentionedDisclaimerUD { get }
    var siteIndex: SiteIndexUD { get }
    var theme: PDThemeUD { get }
    func setDeliveryMethod(to method: DeliveryMethod)
    func setExpirationInterval(to interval: ExpirationInterval)
    func setQuantity(to q: Int)
    func setNotifications(to b: Bool)
    func setNotificationsMinutesBefore(to i: Int)
    func setMentionedDisclaimer(to b: Bool)
    func setSiteIndex(to i: Int, siteCount: Int) -> Index
    func setTheme(to t: PDTheme)
}
