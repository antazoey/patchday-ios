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

    // App
    private var shared: PDSharedData? = nil
    private var estrogenSchedule: EstrogenSchedule
    private var siteSchedule: SiteSchedule
    private var state: PDState

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
    
    init(estrogenSchedule: EstrogenSchedule,
         siteSchedule: SiteSchedule,
         state: PDState,
         sharedData: PDSharedData?) {
        self.estrogenSchedule = estrogenSchedule
        self.siteSchedule = siteSchedule
        self.state = state
        self.shared = sharedData
        super.init()
        self.load(&deliveryMethod)
        self.load(&expirationInterval)
        self.load(&quantity)
        self.load(&notifications)
        self.load(&notificationsMinutesBefore)
        self.load(&mentionedDisclaimer)
        self.load(&theme)
    }

    // MARK: - Setters
    
    public func setDeliveryMethod(to method: DeliveryMethod) {
        set(&deliveryMethod, to: method)
        siteSchedule.deliveryMethod = method
        estrogenSchedule.deliveryMethod = method
        let setCount: () -> () = {
            var c: Quantity
            switch method {
            case .Injections:
                c = Quantity.One
            default:
                c = Quantity.Four
            }
            self.set(&self.quantity, to: c)
        }
        state.deliveryMethodChanged = true
    }
    
    public func setExpirationInterval(to i: ExpirationInterval) {
        set(&expirationInterval, to: i)
    }

    @objc public func setQuantity(to q: Int) {
        let oldQuantity = quantity.value.rawValue
        if let q = Quantity(rawValue: q) {
            self.set(&quantity, to: q)
            if oldQuantity < q.rawValue {
                // Fill in new estros
                for _ in oldQuantity..<q.rawValue {
                    let _ = estrogenSchedule.insert()
                }
            } else {
                estrogenSchedule.delete(after: q.rawValue - 1)
            }
        }
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
    
    public func setSiteIndex(to i: Index) {
        let c = siteSchedule.count()
        if i < c && i >= 0 {
            set(&siteIndex, to: i)
        }
    }
    
    public func setTheme(to t: PDTheme) {
        set(&theme, to: t)
    }
}
