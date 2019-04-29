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

public enum PDDefault: String {
    case DeliveryMethod = "delivMethod"
    case ExpirationInterval = "patchChangeInterval"
    case Quantity = "numberOfPatches"
    case Notifications = "notification"
    case NotiicationsMinutesBefore = "remindMeUpon"
    case MentionedDisclaimer = "mentioned"
    case SiteIndex = "site_i"
    case Theme = "theme"
}

open class PDDefaults: PDDefaultsBaseClass {
    
    // App
    private var shared: PDSharedData? = nil
    private var estrogenSchedule: EstrogenSchedule
    private var siteSchedule: SiteSchedule
    private var state: PDState
    private var alerter: PatchDataAlert?

    // Defaults
    public var deliveryMethod = DeliveryMethodUD(with: DeliveryMethod.Patches)
    public var expirationInterval = ExpirationIntervalUD(with: ExpirationInterval.TwiceAWeek)
    public var quantity = QuantityUD(with: 4)
    public var notifications = NotificationsUD(with: false)
    public var notificationsMinutesBefore = NotificationsMinutesBeforeUD(with: 0)
    public var mentionedDisclaimer = MentionedDisclaimerUD(with: false)
    public var siteIndex = SiteIndexUD(with: 0)
    public var theme = ThemeUD(with: PDTheme.Light)

    // MARK: - initializer
    
    internal init(estrogenSchedule: EstrogenSchedule,
                  siteSchedule: SiteSchedule,
                  state: PDState,
                  sharedData: PDSharedData?,
                  alerter: PatchDataAlert?) {
        self.estrogenSchedule = estrogenSchedule
        self.siteSchedule = siteSchedule
        self.state = state
        if let alertArg = alerter {
            self.alerter = alertArg
        }
        if let sd = sharedData {
            shared = sd
        }
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
    
    public func setDeliveryMethod(to method: DeliveryMethod, shouldReset: Bool = true) {
        self.set(&self.deliveryMethod, to: method)
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
        if shouldReset {
            siteSchedule.reset(completion: setCount)
            estrogenSchedule.reset(completion: setCount)
        }
        state.deliveryMethodChanged = true
    }
    
    /**
    Warns the user if they are about to delete delivery data.
     It is necessary to reset MOs that are no longer in the schedule,
     which happens when the user decreases the count in a full schedule.
     Resetting unused MOs makes sorting the schedule less error prone and more comprehensive.
    */
    public func setQuantityWithWarning(to newQ: Quantity, oldQ: Quantity,
                                       reset: @escaping (_ newQuantity: Int) -> (),
                                       cancel: @escaping (_ oldQuantity: Int) -> ()) {
        state.oldDeliveryCount = oldQ.rawValue
        if newQ.rawValue < oldQ.rawValue {
            state.decreasedCount = true
            // Erases data
            let last_i = self.quantity.value.rawValue - 1
            if !estrogenSchedule.isEmpty(fromThisIndexOnward: newQ.rawValue,
                                         lastIndex: last_i),
                let alerter = alerter {
                    let res = { (newCount) in reset(newCount) }
                    let setQ = setQuantityWithoutWarning
                    alerter.alertForChangingCount(oldCount: oldQ.rawValue,
                                                  newCount: newQ.rawValue,
                                                  simpleSetQuantity: setQ,
                                                  reset: res,
                                                  cancel: cancel)
            } else {
                // Resets notifications but does not erase any data
                setQuantityWithoutWarning(to: newQ.rawValue)
                reset(newQ.rawValue)
            }
        }
    }
    
    @objc public func setQuantityWithoutWarning(to q: Int) {
        let oldQuantity = self.quantity.value.rawValue
        if let q = Quantity(rawValue: q) {
            self.set(&self.quantity, to: q)
            let increasing = oldQuantity < q.rawValue
            if increasing {
                // Fill in new estros
                for _ in oldQuantity..<q.rawValue {
                    let _ = estrogenSchedule.insert()
                }
            } else {
                estrogenSchedule.delete(after: q.rawValue - 1)
            }
        }
    }
    
    public func setSiteIndex(to i: Index) {
        let c = siteSchedule.count()
        if i < c && i >= 0 {
            self.set(&siteIndex, to: i)
        }
    }
}
