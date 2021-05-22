//
//  UserDefaultsReading.swift
//  PDKit
//
//  Created by Juliya Smith on 11/11/19.

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

    /// Whether pills are enabled.
    var pillsEnabled: PillsEnabledUD { get }

    /// Whether to use a consistent expiration time or to keep it dynamic.
    var useStaticExpirationTime: UseStaticExpirationTimeUD { get }
}
