//
//  PDDefaults.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/25/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

public class PDDefaultsConstants {
    public static let maxQuantity = 4
}

public class PDDefaultsStore: UserDefaultsStoring {

    // Dependencies
    private var state: PDState
    private var handler: PDDefaultsStorageHandler

    // Defaults
    public var deliveryMethod = DeliveryMethodUD()
    public var expirationInterval = ExpirationIntervalUD()
    public var quantity = QuantityUD()
    public var notifications = NotificationsUD()
    public var notificationsMinutesBefore = NotificationsMinutesBeforeUD()
    public var mentionedDisclaimer = MentionedDisclaimerUD()
    public var siteIndex = SiteIndexUD()
    public var theme = PDThemeUD()

    // MARK: - initializer
    
    init(state: PDState, handler: PDDefaultsStorageHandler) {
        self.state = state
        self.handler = handler
        handler.load(&deliveryMethod)
            .load(&expirationInterval)
            .load(&quantity)
            .load(&notifications)
            .load(&notificationsMinutesBefore)
            .load(&mentionedDisclaimer)
            .load(&theme)
    }
    
    public func reset(defaultSiteCount: Int=4) {
        replaceStoredDeliveryMethod(to: .Patches)
        replaceStoredQuantity(to: 3)
        replaceStoredExpirationInterval(to: .TwiceAWeek)
        replaceStoredNotifications(to: true)
        replaceStoredSiteIndex(to: 3, siteCount: defaultSiteCount)
        replaceStoredNotificationsMinutesBefore(to: 0)
        replaceStoredMentionedDisclaimer(to: false)
        replaceStoredTheme(to: .Light)
    }
    
    public func replaceStoredDeliveryMethod(to method: DeliveryMethod) {
        handler.replace(&deliveryMethod, to: method)
        let q = method == .Injections ? Quantity.One : Quantity.Three
        handler.replace(&quantity, to: q)
        state.deliveryMethodChanged = true
    }
    
    @objc public func replaceStoredQuantity(to newQuantity: Int) {
        if let q = Quantity(rawValue: newQuantity) {
            handler.replace(&quantity, to: q)
        }
    }
     
    public func replaceStoredExpirationInterval(to i: ExpirationInterval) {
        handler.replace(&expirationInterval, to: i)
    }
    
    public func replaceStoredNotifications(to b: Bool) {
        handler.replace(&notifications, to: b)
    }
    
    public func replaceStoredNotificationsMinutesBefore(to i: Int) {
        handler.replace(&notificationsMinutesBefore, to: i)
    }
    
    public func replaceStoredMentionedDisclaimer(to b: Bool) {
        handler.replace(&mentionedDisclaimer, to: b)
    }
    
    @discardableResult public func replaceStoredSiteIndex(to i: Index, siteCount: Int) -> Index {
        if i < siteCount && i >= 0 {
            handler.replace(&siteIndex, to: i)
            return i
        }
        return 0
    }
    
    public func replaceStoredTheme(to t: PDTheme) {
        handler.replace(&theme, to: t)
    }
}
