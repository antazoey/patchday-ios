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
    
    // Description: The PDDefaults is the controller for the User Defaults that are unique to the user and their schedule.  There are schedule defaults and there are notification defaults.  The schedule defaults included the patch expiration interval (timeInterval) and the quantity of estrogen in patches or shorts in the schedule.  The notification defaults includes a bool indicatinng whether the user wants a reminder and the time before expiration that the user would wish to receive the reminder.
    
    // App
    private static var defaults = UserDefaults(suiteName: "group.com.patchday.todaydata")!
    private static var std_defaults = UserDefaults.standard
    
    // Schedule defaults:
    private static var deliveryMethod: String = PDStrings.PickerData.deliveryMethods[0]
    private static var timeInterval: String = PDStrings.PickerData.expirationIntervals[0]
    internal static var quantity: Int = 4
    
    // Notification defaults:
    private static var notifications = false
    private static var reminderTime: Int = 0
    
    // Rememberance
    private static var mentionedAppDisclaimer = false
    private static var needsDataMigration = true
    private static var siteIndex = 0
    
    // Side effects
    private static var estrogenSchedule: EstrogenSchedule? = nil
    private static var siteSchedule: SiteSchedule? = nil
    private static var scheduleState: ScheduleState? = nil

    // MARK: - a static initializer
    
    public static func setUp() {
        loadDeliveryMethod()
        loadTimeInterval()
        loadQuantity()
        loadNotificationMinutesBefore()
        loadRemindUpon()
        loadMentionedDisclaimer()
        loadSiteIndex()
        loadNeedsMigration()
    }
    
    public static func setEstrogenSchedule(_ schedule: EstrogenSchedule) {
        estrogenSchedule = schedule
    }
    
    public static func setSiteSchedule(_ schedule: SiteSchedule) {
        siteSchedule = schedule
    }
    
    public static func setScheduleState(_ state: ScheduleState) {
        scheduleState = state
    }
    
    // MARK: - Getters
    
    public static func getDeliveryMethod() -> String {
        return deliveryMethod
    }
    
    public static func getTimeInterval() -> String {
        return timeInterval
    }

    public static func getQuantity() -> Int {
        return quantity
    }
    
    public static func getNotificationMinutesBefore() -> Int {
        return reminderTime
    }
    
    public static func notify() -> Bool {
        return notifications
    }

    public static func mentionedDisclaimer() -> Bool {
        return mentionedAppDisclaimer
    }
    
    public static func getSiteIndex() -> Index {
        return siteIndex
    }

    // MARK: - Setters
    
    public static func setDeliveryMethod(to method: String) {
        typealias Methods = PDStrings.DeliveryMethods
        let methods = [Methods.injections, Methods.patches]
        let oldMethod = PDDefaults.getDeliveryMethod()
        if method != oldMethod && methods.contains(method) {
            deliveryMethod = method
            defaults.set(method, forKey: PDStrings.SettingsKey.deliv.rawValue)
            let usingPatches = method == Methods.patches
            if let c = (usingPatches) ?
                Int(PDStrings.PickerData.counts[2]) :
                Int(PDStrings.PickerData.counts[0]) {
                PDDefaults.setQuantityWithoutWarning(to: c)
            }
            if let state = scheduleState {
                state.deliveryMethodChanged = true
            }
            if let schedule = siteSchedule {
                schedule.reset()
            }
        }
    }
    
    public static func setTimeInterval(to interval: String) {
        let intervals = PDStrings.PickerData.expirationIntervals
        if intervals.contains(interval) {
            let key = PDStrings.SettingsKey.interval.rawValue
            timeInterval = interval
            defaults.set(interval, forKey: key)
        }
    }
    
    /**
    Warns the user if they are about to delete delivery data.  It is necessary to reset MOs that are no longer in the schedule, which happens when the user decreases the count in a full schedule. Resetting unused MOs makes sorting the schedule less error prone and more comprehensive.
    */
    public static func setQuantityWithWarning(to newCount: Int, oldCount: Int, countButton: UIButton, navController: UINavigationController? = nil, reset: @escaping (_ newQuantity: Int) -> ()) {
        let max = maxSites()
        if let fx = scheduleState {
            fx.oldDeliveryCount = oldCount
        }
        if isAcceptable(count: newCount, max: max) {
            if newCount < oldCount {
                if let fx = scheduleState {
                    fx.decreasedCount = true
                }
                // Erases data
                let q = PDDefaults.getQuantity()
                let last_i = q - 1
                if let estroSchedule = estrogenSchedule,
                    !estroSchedule.isEmpty(fromThisIndexOnward: newCount,
                                         lastIndex: last_i) {
                    PatchDataAlert.alertForChangingCount(oldCount: oldCount,
                                                         newCount: newCount,
                                                         countButton: countButton,
                                                         navController: navController) {
                        newCount in reset(newCount)
                    }
                } else {
                    // Resets notifications but does not erase any data
                    setQuantityWithoutWarning(to: newCount)
                    reset(newCount)
                }
            } else {
                // Incr. count
                setQuantityWithoutWarning(to: newCount)
                if let fx = scheduleState {
                    fx.increasedCount = true
                }
            }
        }
    }
    
    public static func setQuantityWithoutWarning(to quantity: Int) {
        // sets if greater than 0 and less than 5 first.
        let max = maxSites()
        if isAcceptable(count: quantity, max: max) {
            self.quantity = quantity
            defaults.set(quantity, forKey: PDStrings.SettingsKey.count.rawValue)
            if let estroSchedule = estrogenSchedule {
                estroSchedule.delete(after: quantity)
            }
        }
    }
    
    public static func setNotificationMinutesBefore(to minutes: Int) {
        let key = PDStrings.SettingsKey.notif.rawValue
        reminderTime = minutes
        defaults.set(minutes, forKey: key)
    }
    
    public static func setNotify(to notify: Bool) {
        let key = PDStrings.SettingsKey.remind.rawValue
        notifications = notify
        defaults.set(notify, forKey: key)
    }

    public static func setMentionedDisclaimer(to disclaimer: Bool) {
        let key = PDStrings.SettingsKey.setup.rawValue
        mentionedAppDisclaimer = disclaimer
        std_defaults.set(disclaimer, forKey: key)
    }
    
    public static func setSiteIndex(to i: Index) {
        if let siteSchedule = siteSchedule {
            let c = siteSchedule.count()
            if i < c && i >= 0 {
                let key = PDStrings.SettingsKey.site_index.rawValue
                defaults.set(siteIndex, forKey: key)
            }
        }
    }

    //MARK: - Other public
    
    public static func usingPatches() -> Bool {
        let method = PDDefaults.getDeliveryMethod()
        let patches = PDStrings.PickerData.deliveryMethods[0]
        return method == patches
    }

    /// Checks to see if count is reasonable for PatchDay
    public static func isAcceptable(count: Int, max: Int) -> Bool {
        return (count > 0) && (count <= max)
    }
    
    // MARK: - loaders
    
    private static func loadDeliveryMethod() {
        let key = PDStrings.SettingsKey.deliv.rawValue
        if let dm = defaults.object(forKey: key) as? String {
            deliveryMethod = dm
        } else if let dm = std_defaults.object(forKey: key) as? String {
            // set in the primary defaults
            setDeliveryMethod(to: dm)
        } else {
            setDeliveryMethod(to: PDStrings.PickerData.deliveryMethods[0])
        }
    }
    
    private static func loadTimeIntervalHelper(to interval: String) {
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
    
    private static func loadTimeInterval() {
        if let interval = defaults.object(forKey: PDStrings.SettingsKey.interval.rawValue) as? String {
            loadTimeIntervalHelper(to: interval)
        } else if let interval = std_defaults.object(forKey: PDStrings.SettingsKey.interval.rawValue) as? String {
            setTimeInterval(to: interval)
        } else {
            setTimeInterval(to: PDStrings.PickerData.expirationIntervals[0])
        }
    }
    
    private static func loadQuantityHelper(count: Int) {
        if count >= 1 || count <= 4 {
            quantity = count
        } else if let c = Int(PDStrings.PickerData.counts[2]) {
            setQuantityWithoutWarning(to: c)
        }
    }
    
    private static func loadQuantity() {
        let key = PDStrings.SettingsKey.count.rawValue
        if let count = defaults.object(forKey: key) as? Int {
            loadQuantityHelper(count: count)
        } else if let count = std_defaults.object(forKey: key) as? Int {
            loadQuantityHelper(count: count)
            setQuantityWithoutWarning(to: count)
        } else if let count = Int(PDStrings.PickerData.counts[2]) {
            setQuantityWithoutWarning(to: count)
        }
    }
    
    private static func loadNotificationMinutesBefore() {
        let key = PDStrings.SettingsKey.notif.rawValue
        if let notifyTime = defaults.object(forKey: key) as? Int {
            reminderTime = notifyTime
        } else if let notifyTime = std_defaults.object(forKey: key) as? Int {
            setNotificationMinutesBefore(to: notifyTime)
        } else {
            setNotificationMinutesBefore(to: 0)
        }
    }
    
    private static func loadRemindUpon() {
        let key = PDStrings.SettingsKey.remind.rawValue
        if let notifyMe = defaults.object(forKey: key) as? Bool {
            notifications = notifyMe
        } else if let notifyMe = std_defaults.object(forKey: key) as? Bool {
            setNotify(to: notifyMe)
        } else {
            setNotify(to: true)
        }
    }

    // Note:  non-shared.
    private static func loadMentionedDisclaimer() {
        let key = PDStrings.SettingsKey.setup.rawValue
        if let mentioned = std_defaults.object(forKey: key) as? Bool {
            mentionedAppDisclaimer = mentioned
        }
    }
    
    private static func loadSiteIndex() {
        let key = PDStrings.SettingsKey.site_index.rawValue
        if let site_i = defaults.object(forKey: key) as? Int {
            siteIndex = site_i
        } else if let site_i = std_defaults.object(forKey: key) as? Int {
            setSiteIndex(to: site_i)
        } else {
            setSiteIndex(to: 0)
        }
    }

    // MARK: - helpers
    
    /// Removes the word "minutes" from the notification option
    private static func cutNotificationMinutes(of: String) -> String {
        var builder = ""
        for c in of {
            if c == " " {
                return builder
            }
            builder += "\(c)"
        }
        return builder
    }
    
    private static func maxSites() -> Int {
        if let schedule = siteSchedule {
            return schedule.count()
        }
        return 4
    }
}
