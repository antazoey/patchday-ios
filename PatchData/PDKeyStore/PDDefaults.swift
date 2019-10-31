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

public class PDDefaults: PDDefaultsBaseClass, PDDefaultManaging {

    // Dependencies
    private var state: PDStateManaging

    // Defaults
    public var deliveryMethod = DeliveryMethodUD(with: DeliveryMethod.Patches)
    public var expirationInterval = ExpirationIntervalUD(with: ExpirationInterval.TwiceAWeek)
    public var quantity = QuantityUD(with: 4)
    public var notifications = NotificationsUD(with: false)
    public var notificationsMinutesBefore = NotificationsMinutesBeforeUD(with: 0)
    public var mentionedDisclaimer = MentionedDisclaimerUD(with: false)
    public var siteIndex = SiteIndexUD(with: 0)
    public var theme = PDThemeUD(with: PDTheme.Light)

    // MARK: - initializer
    
    init(stateManager: PDStateManaging, meter: PDDataMeting) {
        self.state = stateManager
        super.init(meter: meter)
        self.load(&deliveryMethod)
        self.load(&expirationInterval)
        self.load(&quantity)
        self.load(&notifications)
        self.load(&notificationsMinutesBefore)
        self.load(&mentionedDisclaimer)
        self.load(&theme)
    }
    
    public func reset(defaultSiteCount: Int=4) {
        setDeliveryMethod(to: .Patches)
        setQuantity(to: 3)
        setExpirationInterval(to: .TwiceAWeek)
        setNotifications(to: true)
        setSiteIndex(to: 3, siteCount: defaultSiteCount)
        setNotificationsMinutesBefore(to: 0)
        setMentionedDisclaimer(to: false)
        setTheme(to: .Light)
    }
    
    public func setDeliveryMethod(to method: DeliveryMethod) {
        set(&deliveryMethod, to: method)
        let q = method == .Injections ? Quantity.One : Quantity.Three
        self.set(&self.quantity, to: q)
        state.deliveryMethodChanged = true
    }
    
    @objc public func setQuantity(to newQuantity: Int) {
        if let q = Quantity(rawValue: newQuantity) {
            self.set(&quantity, to: q)
        }
    }
    
    public func setExpirationInterval(to i: ExpirationInterval) {
        set(&expirationInterval, to: i)
    }
    
    public func setNotifications(to b: Bool) {
        set(&notifications, to: b)
    }
    
    public func setNotificationsMinutesBefore(to i: Int) {
        set(&notificationsMinutesBefore, to: i)
    }
    
    public func setMentionedDisclaimer(to b: Bool) {
        set(&mentionedDisclaimer, to: b)
    }
    
    @discardableResult public func setSiteIndex(to i: Index, siteCount: Int) -> Index {
        if i < siteCount && i >= 0 {
            set(&siteIndex, to: i)
            return i
        }
        return 0
    }
    
    public func setTheme(to t: PDTheme) {
        set(&theme, to: t)
    }
}
