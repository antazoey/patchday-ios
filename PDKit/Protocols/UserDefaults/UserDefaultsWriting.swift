//
//  UserDefaultsManaging.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public protocol UserDefaultsWriting: UserDefaultsReading {
    
    /// Resets all values back to their default.
    func reset(defaultSiteCount: Int)

    /// Replaces the value of 'delivery method' with the given one.
    func replaceStoredDeliveryMethod(to method: DeliveryMethod)

    /// Replaces the value of 'expiration interval' with the given one.
    func replaceStoredExpirationInterval(to interval: ExpirationInterval)
    
    /// Replaces the value of 'quantity' with the given one. Accepts 1, 2, 3, 4.
    func replaceStoredQuantity(to q: Int)
    
    /// Replaces the value of 'notifications' with the given one.
    func replaceStoredNotifications(to b: Bool) 

    /// Replaces the value of 'notifications minutes before' with the given one.
    func replaceStoredNotificationsMinutesBefore(to i: Int)

    /// Replaces the value of 'mentioned disclaimer' with the given one.
    func replaceStoredMentionedDisclaimer(to b: Bool)
    
    /// Replaces the value of 'site index' with the given one. Accepts 0..<siteCount. Returns the index after trying to set.
    @discardableResult
    func replaceStoredSiteIndex(to i: Int, siteCount: Int) -> Index

    /// Replaces the value of 'theme' with the given one.
    func replaceStoredTheme(to t: PDTheme)
}
