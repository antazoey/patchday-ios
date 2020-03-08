//
//  UserDefaultsReading.swift
//  PDKit
//
//  Created by Juliya Smith on 11/11/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public protocol UserDefaultsReading {

    /// The method by which you take hormones. Supports patches and injections.
    var deliveryMethod: DeliveryMethodUD { get }
    
    /// The interval until you need to re-dose hormones. Supports twice-a-week, once-a-week, and once-every-two-weeks.
    var expirationInterval: ExpirationIntervalUD { get }
    
    /// The quantity of hormones. Supports 1, 2, 3, 4.
    var quantity: QuantityUD { get }
    
    /// Whether you want notifications for expired hormones.
    var notifications: NotificationsUD { get }
    
    /// The amount of time before a hormone expires that you want a notification.
    var notificationsMinutesBefore: NotificationsMinutesBeforeUD { get }
    
    /// Whether you have seen the PatchDay disclaimer.
    var mentionedDisclaimer: MentionedDisclaimerUD { get }
    
    /// The index of the next suggested site.
    var siteIndex: SiteIndexUD { get }
    
    /// The desired theme for user interfaces. Supports dark and light.
    var theme: ThemeUD { get }
}
