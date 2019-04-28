//
//  PDDefaults.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/25/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

open class PDDefaults: PDDefaultsBaseClass {
    
    // App
    private var shared: PDSharedData? = nil
    private var estrogenSchedule: EstrogenSchedule
    private var siteSchedule: SiteSchedule
    private var state: PDState
    private var alerter: PatchDataAlert?
    
    // Defaults
    public var deliveryMethod: String = PDStrings.PickerData.deliveryMethods[0]
    public var timeInterval: String = PDStrings.PickerData.expirationIntervals[0]
    public var quantity: Int = 4
    public var notifications = false
    public var notificationsMinutesBefore: Int = 0
    public var mentionedDisclaimer = false
    public var siteIndex = 0
    public var theme = PDStrings.PickerData.themes[0]

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
        self.load(&deliveryMethod, for: .DeliveryMethod)
        self.load(&timeInterval, for: .TimeInterval) {
            (v: String) in self.mapKeyToInterval(intervalKey: v)
        }
        self.load(&quantity, for: .Quantity)
        self.load(&notifications, for: .Notifications)
        self.load(&notificationsMinutesBefore, for: .NotificationMinutesBefore)
        self.load(&mentionedDisclaimer, for: .MentionedDisclaimer)
        self.load(&theme, for: .Theme)
    }

    // MARK: - Setters
    
    public func setDeliveryMethod(to method: String, shouldReset: Bool = true) {
        typealias Methods = PDStrings.DeliveryMethods
        let methods = [Methods.injections, Methods.patches]
        let usingPatches = (method == PDStrings.DeliveryMethods.patches)
        if methods.contains(method) {
            self.set(&self.deliveryMethod, to: method, for: .DeliveryMethod)
            siteSchedule.deliveryMethod = getDeliveryMethod()
            estrogenSchedule.usingPatches = usingPatches
            let setCount: () -> () = {
                let c = usingPatches ? 3 : 1
                self.set(&self.quantity, to: c, for: .Quantity)
            }
            if shouldReset {
                siteSchedule.reset(completion: setCount)
                estrogenSchedule.reset(completion: setCount)
            }
            state.deliveryMethodChanged = true
        }
    }
    
    public func setTimeInterval(to i: String) {
        let intervals = PDStrings.PickerData.expirationIntervals
        if intervals.contains(i) {
            self.set(&self.timeInterval, to: i, for: .TimeInterval)
        }
    }
    
    /**
    Warns the user if they are about to delete delivery data.
     It is necessary to reset MOs that are no longer in the schedule,
     which happens when the user decreases the count in a full schedule.
     Resetting unused MOs makes sorting the schedule less error prone and more comprehensive.
    */
    public func setQuantityWithWarning(to newCount: Int, oldCount: Int,
                                       reset: @escaping (_ newQuantity: Int) -> (),
                                       cancel: @escaping (_ oldQuantity: Int) -> ()) {
        let max = siteSchedule.count()
        state.oldDeliveryCount = oldCount
        if isAcceptable(count: newCount, max: max) {
            if newCount < oldCount {
                state.decreasedCount = true
                // Erases data
                let last_i = self.quantity - 1
                if !estrogenSchedule.isEmpty(fromThisIndexOnward: newCount,
                                             lastIndex: last_i),
                    let alerter = alerter {
                        let res = { (newCount) in reset(newCount) }
                        let setQ = setQuantityWithoutWarning
                        alerter.alertForChangingCount(oldCount: oldCount,
                                                      newCount: newCount,
                                                      simpleSetQuantity: setQ,
                                                      reset: res,
                                                      cancel: cancel)
                } else {
                    // Resets notifications but does not erase any data
                    setQuantityWithoutWarning(to: newCount)
                    reset(newCount)
                }
            } else {
                // Incr. count
                setQuantityWithoutWarning(to: newCount)
                state.increasedCount = true
            }
        }
    }
    
    @objc public func setQuantityWithoutWarning(to q: Int) {
        let oldQuantity = self.quantity
        let counts = PDStrings.PickerData.counts
        if let last = counts.last,
            let max = Int(last),
            isAcceptable(count: q, max: max) {
            self.set(&self.quantity, to: q, for: .Quantity)
            let increasing = oldQuantity < quantity
            if increasing {
                // Fill in new estros
                for _ in oldQuantity..<q {
                    let _ = estrogenSchedule.insert()
                }
            } else {
                estrogenSchedule.delete(after: q - 1)
            }
        }
    }
    
    public func setSiteIndex(to i: Index) {
        let c = siteSchedule.count()
        if i < c && i >= 0 {
            self.set(&siteIndex, to: i, for: .SiteIndex)
        }
    }
    
    public func getDeliveryMethod() -> DeliveryMethod {
        switch deliveryMethod {
        case PDStrings.PickerData.deliveryMethods[1]:
            return .Injections
        default:
            return .Patches
        }
    }
    
    public func getTheme() -> PDTheme {
        switch theme {
        case PDStrings.PickerData.themes[1]:
            return .Dark
        default:
            return .Light
        }
    }
    
    /// Checks to see if count is reasonable for PatchDay
    public func isAcceptable(count: Int, max: Int) -> Bool {
        return (count > 0) && (count <= max)
    }
    
    // MARK: - Private
    
    private func mapKeyToInterval(intervalKey: String) -> String {
        switch intervalKey {
        case "One half-week":
            return PDStrings.PickerData.expirationIntervals[0]
        case "One week":
            return PDStrings.PickerData.expirationIntervals[1]
        case "Two weeks":
            return PDStrings.PickerData.expirationIntervals[2]
        default:
            return intervalKey
        }
    }
}
