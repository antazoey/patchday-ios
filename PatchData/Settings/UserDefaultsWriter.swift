//
//  UserDefaultsWriter.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/25/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


public class UserDefaultsWriter: UserDefaultsWriting {

    // Dependencies
    private let state: PDState
    private let handler: UserDefaultsWriteHandler

    // Defaults
    public var deliveryMethod: DeliveryMethodUD
    public var expirationInterval: ExpirationIntervalUD
    public var quantity: QuantityUD
    public var notifications: NotificationsUD
    public var notificationsMinutesBefore: NotificationsMinutesBeforeUD
    public var mentionedDisclaimer: MentionedDisclaimerUD
    public var siteIndex: SiteIndexUD
    public var theme: ThemeUD

    private var getSiteCount: () -> Int
    
    init(state: PDState, handler: UserDefaultsWriteHandler, getSiteCount: @escaping () -> Int) {
        self.state = state
        self.handler = handler
        self.getSiteCount = getSiteCount
        typealias D = DefaultSettings
        
        let deliveryMethod = handler.load(setting: .DeliveryMethod, defaultValue: D.DeliveryMethodRawValue)
        let expirationInterval = handler.load(
            setting: .ExpirationInterval, defaultValue: D.ExpirationIntervalRawValue
        )
        let quantity = handler.load(setting: .Quantity, defaultValue: D.QuantityRawValue)
        let notifications = handler.load(setting: .Notifications, defaultValue: D.NotificationsRawValue)
        let notificationsMinutesBefore = handler.load(
            setting: .NotificationsMinutesBefore, defaultValue: D.NotificationsMinutesBeforeRawValue
        )
        let mentionedDisclaimer = handler.load(
            setting: .MentionedDisclaimer, defaultValue: D.MentionedDisclaimerRawValue
        )
        let siteIndex = handler.load(setting: .SiteIndex, defaultValue: D.SiteIndexRawValue)
        let theme = handler.load(setting: .Theme, defaultValue: D.ThemeRawValue)
        
        self.deliveryMethod = DeliveryMethodUD(deliveryMethod)
        self.expirationInterval = ExpirationIntervalUD(expirationInterval)
        self.quantity = QuantityUD(quantity)
        self.notifications = NotificationsUD(notifications)
        self.notificationsMinutesBefore = NotificationsMinutesBeforeUD(notificationsMinutesBefore)
        self.mentionedDisclaimer = MentionedDisclaimerUD(mentionedDisclaimer)
        self.siteIndex = SiteIndexUD(siteIndex)
        self.theme = ThemeUD(theme)
    }
    
    public func reset(defaultSiteCount: Int=4) {
        replaceStoredDeliveryMethod(to: DefaultSettings.DeliveryMethodValue)
        replaceStoredQuantity(to: DefaultSettings.QuantityRawValue)
        replaceStoredExpirationInterval(to: DefaultSettings.ExpirationIntervalValue)
        replaceStoredNotifications(to: DefaultSettings.NotificationsRawValue)
        replaceStoredNotificationsMinutesBefore(to: DefaultSettings.NotificationsMinutesBeforeRawValue)
        replaceStoredMentionedDisclaimer(to: DefaultSettings.MentionedDisclaimerRawValue)
        replaceStoredTheme(to: DefaultSettings.ThemeValue)
        replaceStoredSiteIndex(to: DefaultSettings.SiteIndexRawValue)
    }
    
    public func replaceStoredDeliveryMethod(to newValue: DeliveryMethod) {
        let rawValue = DeliveryMethodUD.getRawValue(for: newValue)
        let newQuantity = newValue == .Injections ? Quantity.One.rawValue : Quantity.Three.rawValue
        handler.replace(&deliveryMethod, to: rawValue)
        handler.replace(&quantity, to: newQuantity)
        state.theDeliveryMethodHasMutated = true
    }
    
    @objc public func replaceStoredQuantity(to newValue: Int) {
        handler.replace(&quantity, to: newValue)
    }
     
    public func replaceStoredExpirationInterval(to newValue: ExpirationInterval) {
        let rawValue = ExpirationIntervalUD.getRawValue(for: newValue)
        handler.replace(&expirationInterval, to: rawValue)
    }
    
    public func replaceStoredNotifications(to newValue: Bool) {
        handler.replace(&notifications, to: newValue)
    }
    
    public func replaceStoredNotificationsMinutesBefore(to newValue: Int) {
        handler.replace(&notificationsMinutesBefore, to: newValue)
    }
    
    public func replaceStoredMentionedDisclaimer(to newValue: Bool) {
        handler.replace(&mentionedDisclaimer, to: newValue)
    }
    
    @discardableResult
    public func replaceStoredSiteIndex(to newValue: Index) -> Index {
        handler.replace(&siteIndex, to: newValue)
        return newValue
    }
    
    @discardableResult
    public func incrementStoredSiteIndex() -> Index {
        let currentIndex = siteIndex.value
        let siteCount = getSiteCount()
        if siteCount == 0 {
            return currentIndex
        }
        let newIndex = (currentIndex + 1) % siteCount
        handler.replace(&siteIndex, to: newIndex)
        return newIndex
    }
    
    public func replaceStoredTheme(to newValue: PDTheme) {
        let rawValue = ThemeUD.getRawValue(for: newValue)
        handler.replace(&theme, to: rawValue)
    }
}
