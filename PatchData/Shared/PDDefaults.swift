//
//  PDDefaults.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/25/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

public class PDDefaults: NSObject {
    
    override public var description: String {
        return """
        The PDDefaults makes calls to User Defaults
        that are unique to the user and their schedule.
        The data stored here is simple enough that PatchDay
        stores it as key-value pairs.
        """
    }
    
    // App
    private let std_defaults = UserDefaults.standard
    private var shared: PDSharedData? = nil
    
    // Schedule defaults:
    private var deliveryMethod: String = PDStrings.PickerData.deliveryMethods[0]
    private var timeInterval: String = PDStrings.PickerData.expirationIntervals[0]
    internal var quantity: Int = 4
    
    // Notification defaults:
    private var notifications = false
    private var reminderTime: Int = 0
    
    // Rememberance
    private var mentionedAppDisclaimer = false
    private var needsDataMigration = true
    private var siteIndex = 0
    
    // Side effects
    private var estrogenSchedule: EstrogenSchedule
    private var siteSchedule: SiteSchedule
    private var state: PDState
    private var alerter: PatchDataAlert?

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
        loadDeliveryMethod()
        loadTimeInterval()
        loadQuantity()
        loadNotificationMinutesBefore()
        loadRemindUpon()
        loadMentionedDisclaimer()
        loadSiteIndex()
    }
    
    // MARK: - Getters
    
    public func getDeliveryMethod() -> String {
        return deliveryMethod
    }
    
    public func getTimeInterval() -> String {
        return timeInterval
    }

    public func getQuantity() -> Int {
        return quantity
    }
    
    public func getNotificationMinutesBefore() -> Int {
        return reminderTime
    }
    
    public func notify() -> Bool {
        return notifications
    }

    public func mentionedDisclaimer() -> Bool {
        return mentionedAppDisclaimer
    }
    
    public func getSiteIndex() -> Index {
        return siteIndex
    }

    // MARK: - Setters
    
    public func setDeliveryMethod(to method: String, shouldReset: Bool = true) {
        typealias Methods = PDStrings.DeliveryMethods
        let methods = [Methods.injections, Methods.patches]
        let usingPatches = (method == PDStrings.DeliveryMethods.patches)
        let key = PDStrings.SettingsKey.deliv.rawValue
        if methods.contains(method) {
            if (self.deliveryMethod != method) {
                self.deliveryMethod = method
                shared?.defaults?.set(method, forKey: key)
            }
            siteSchedule.usingPatches = usingPatches
            estrogenSchedule.usingPatches = usingPatches
            let setCount: () -> () = {
                let c = usingPatches ? 3 : 1
                self.setQuantityWithoutWarning(to: c)
            }
            if shouldReset {
                siteSchedule.reset(completion: setCount)
                estrogenSchedule.reset(completion: setCount)
            }
            state.deliveryMethodChanged = true
        }
    }
    
    public func setTimeInterval(to interval: String) {
        let intervals = PDStrings.PickerData.expirationIntervals
        if intervals.contains(interval) {
            let key = PDStrings.SettingsKey.interval.rawValue
            timeInterval = interval
            shared?.defaults?.set(interval, forKey: key)
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
                let q = getQuantity()
                let last_i = q - 1
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
    
    @objc public func setQuantityWithoutWarning(to quantity: Int) {
        let oldQuantity = self.quantity
        let counts = PDStrings.PickerData.counts
        if let last = counts.last,
            let max = Int(last),
            isAcceptable(count: quantity, max: max) {
            self.quantity = quantity
            shared?.defaults?.set(quantity, forKey: PDStrings.SettingsKey.count.rawValue)
            let increasing = oldQuantity < quantity
            if increasing {
                // Fill in new estros
                for _ in oldQuantity..<quantity {
                    let _ = estrogenSchedule.insert()
                }
            } else {
                estrogenSchedule.delete(after: quantity - 1)
            }
        }
    }
    
    public func setNotificationMinutesBefore(to minutes: Int) {
        let key = PDStrings.SettingsKey.notif.rawValue
        reminderTime = minutes
        shared?.defaults?.set(minutes, forKey: key)
    }
    
    public func setNotify(to notify: Bool) {
        let key = PDStrings.SettingsKey.remind.rawValue
        notifications = notify
        shared?.defaults?.set(notify, forKey: key)
    }

    public func setMentionedDisclaimer(to disclaimer: Bool) {
        let key = PDStrings.SettingsKey.setup.rawValue
        mentionedAppDisclaimer = disclaimer
        std_defaults.set(disclaimer, forKey: key)
    }
    
    public func setSiteIndex(to i: Index) {
        let c = siteSchedule.count()
        if i < c && i >= 0 {
            let key = PDStrings.SettingsKey.site_index.rawValue
            siteIndex = i
            shared?.defaults?.set(i, forKey: key)
            siteSchedule.next = i
        }
    }

    //MARK: - Other public
    
    public func usingPatches() -> Bool {
        let method = getDeliveryMethod()
        let patches = PDStrings.PickerData.deliveryMethods[0]
        return method == patches
    }

    /// Checks to see if count is reasonable for PatchDay
    public func isAcceptable(count: Int, max: Int) -> Bool {
        return (count > 0) && (count <= max)
    }
    
    // MARK: - loaders
    
    private func loadDeliveryMethod() {
        let key = PDStrings.SettingsKey.deliv.rawValue
        if let dm = shared?.defaults?.object(forKey: key) as? String {
            deliveryMethod = dm
        } else if let dm = std_defaults.object(forKey: key) as? String {
            // set in the primary defaults
            setDeliveryMethod(to: dm, shouldReset: false)
        } else {
            setDeliveryMethod(to: PDStrings.PickerData.deliveryMethods[0], shouldReset: false)
        }
    }
    
    private func loadTimeIntervalHelper(to interval: String) {
        switch interval {
        case "One half-week":
            timeInterval = PDStrings.PickerData.expirationIntervals[0]
        case "One week":
            timeInterval = PDStrings.PickerData.expirationIntervals[1]
        case "Two weeks":
            timeInterval = PDStrings.PickerData.expirationIntervals[2]
        default:
            timeInterval = interval
        }
    }
    
    private func loadTimeInterval() {
        let key = PDStrings.SettingsKey.interval.rawValue
        if let interval = shared?.defaults?.object(forKey: key) as? String {
            loadTimeIntervalHelper(to: interval)
        } else if let interval = std_defaults.object(forKey: key) as? String {
            setTimeInterval(to: interval)
        } else {
            setTimeInterval(to: PDStrings.PickerData.expirationIntervals[0])
        }
    }
    
    private func loadQuantityHelper(count: Int) {
        if count >= 1 || count <= 4 {
            quantity = count
        } else if let c = Int(PDStrings.PickerData.counts[2]) {
            setQuantityWithoutWarning(to: c)
        }
    }
    
    private func loadQuantity() {
        let key = PDStrings.SettingsKey.count.rawValue
        if let count = shared?.defaults?.object(forKey: key) as? Int {
            loadQuantityHelper(count: count)
        } else if let count = std_defaults.object(forKey: key) as? Int {
            loadQuantityHelper(count: count)
            setQuantityWithoutWarning(to: count)
        } else if let count = Int(PDStrings.PickerData.counts[2]) {
            setQuantityWithoutWarning(to: count)
        }
    }
    
    private func loadNotificationMinutesBefore() {
        let key = PDStrings.SettingsKey.notif.rawValue
        if let notifyTime = shared?.defaults?.object(forKey: key) as? Int {
            reminderTime = notifyTime
        } else if let notifyTime = std_defaults.object(forKey: key) as? Int {
            setNotificationMinutesBefore(to: notifyTime)
        } else {
            setNotificationMinutesBefore(to: 0)
        }
    }
    
    private func loadRemindUpon() {
        let key = PDStrings.SettingsKey.remind.rawValue
        if let notifyMe = shared?.defaults?.object(forKey: key) as? Bool {
            notifications = notifyMe
        } else if let notifyMe = std_defaults.object(forKey: key) as? Bool {
            setNotify(to: notifyMe)
        } else {
            setNotify(to: true)
        }
    }

    // Note:  non-shared.
    private func loadMentionedDisclaimer() {
        let key = PDStrings.SettingsKey.setup.rawValue
        if let mentioned = std_defaults.object(forKey: key) as? Bool {
            mentionedAppDisclaimer = mentioned
        } else if let mentioned = shared?.defaults?.object(forKey: key) as? Bool {
            mentionedAppDisclaimer = mentioned
        }
    }
    
    private func loadSiteIndex() {
        let key = PDStrings.SettingsKey.site_index.rawValue
        if let site_i = shared?.defaults?.object(forKey: key) as? Int {
            siteIndex = site_i
        } else if let site_i = std_defaults.object(forKey: key) as? Int {
            setSiteIndex(to: site_i)
        } else {
            setSiteIndex(to: 0)
        }
    }
}
