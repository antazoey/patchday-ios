//
//  PDDefaults.swift
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
    public var deliveryMethod = DeliveryMethodUD()
    public var expirationInterval = ExpirationIntervalUD()
    public var quantity = QuantityUD()
    public var notifications = NotificationsUD()
    public var notificationsMinutesBefore = NotificationsMinutesBeforeUD()
    public var mentionedDisclaimer = MentionedDisclaimerUD()
    public var siteIndex = SiteIndexUD()
    public var theme = PDThemeUD()
    
    public var getSiteCount: (() -> Int)?
    
    init(state: PDState, handler: UserDefaultsWriteHandler) {
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
        replaceStoredNotificationsMinutesBefore(to: 0)
        replaceStoredMentionedDisclaimer(to: false)
        replaceStoredTheme(to: .Light)
    }
    
    public func replaceStoredDeliveryMethod(to method: DeliveryMethod) {
        handler.replace(&deliveryMethod, to: method)
        let q = method == .Injections ? Quantity.One : Quantity.Three
        handler.replace(&quantity, to: q)
        state.theDeliveryMethodHasMutated = true
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
    
    @discardableResult
    public func replaceStoredSiteIndex(to i: Index) -> Index {
        handler.replace(&siteIndex, to: i)
        return i
    }
    
    @discardableResult
    public func incrementStoredSiteIndex() -> Index {
        let currentIndex = siteIndex.value
        let siteCount = getSiteCount?() ?? getDefaultQuantity()
        let newIndex = (currentIndex + 1) % siteCount
        handler.replace(&siteIndex, to: newIndex)
        return newIndex
    }
    
    public func replaceStoredTheme(to t: PDTheme) {
        handler.replace(&theme, to: t)
    }
    
    private func getDefaultQuantity() -> Int {
        KeyStorableHelper.defaultSiteCount(for: deliveryMethod.value)
    }
}
