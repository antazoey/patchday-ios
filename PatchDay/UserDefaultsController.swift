//
//  UserDefaultsController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/25/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

public class UserDefaultsController: NSObject {
    
    // Description: The UserDefaultsController is the controller for the User Defaults that are unique to the user and their schedule.  There are schedule defaults and there are notification defaults.  The schedule defaults included the patch expiration interval (timeInterval) and the quantity of estrogen in patches or shorts in the schedule.  The notification defaults includes a bool indicatinng whether the user wants a reminder and the time before expiration that the user would wish to receive the reminder.
    
    // App
    private static var defaults = UserDefaults(suiteName: "group.com.patchday.todaydata")!
    private static var std_defaults = UserDefaults.standard
    
    // Schedule defaults:
    private static var deliveryMethod: String = PDStrings.PickerData.deliveryMethods[0]
    private static var timeInterval: String = PDStrings.PickerData.expirationIntervals[0]
    internal static var quantity: String =  PDStrings.PickerData.counts[3]
    
    // Notification defaults:
    private static var notifications = false
    private static var reminderTime: String = PDStrings.PickerData.notificationTimes[0]
    
    // Rememberance
    private static var mentionedAppDisclaimer = false
    private static var needsDataMigration = true
    private static var siteIndex = 0

    // MARK: - a static initializer
    
    public static func setUp() {
        loadDeliveryMethod()
        loadTimeInterval()
        loadQuantity()
        loadNotificationOption()
        loadRemindUpon()
        loadMentionedDisclaimer()
        loadSiteIndex()
        loadNeedsMigration()
    }
    
    // MARK: - Getters
    
    public static func getDeliveryMethod() -> String {
        return deliveryMethod
    }
    
    public static func getTimeIntervalString() -> String {
        return timeInterval
    }
    
    public static func getQuantityString() -> String {
        return quantity
    }
    
    public static func getQuantityInt() -> Int {
        if let int = Int(quantity) {
            return int
        }
        else {
            return -1
        }
    }
    
    public static func getNotificationTimeString() -> String {
        return reminderTime
    }
    
    public static func getNotificationTimeInt() -> Int {
        // Remove word "minutes"
        let min: String = cutNotificationMinutes(of: reminderTime)
        if let int = Int(min) {
            return int
        }
        else {
            return -1
        }
    }
    
    public static func getNotificationTimeDouble() -> Double {
        // Remove word "minutes"
        let min: String = cutNotificationMinutes(of: reminderTime)
        if let double = Double(min) {
            return double
        }
        else {
            return -1
        }
    }
    
    public static func getRemindMeUpon() -> Bool {
        return notifications
    }

    public static func mentionedDisclaimer() -> Bool {
        return mentionedAppDisclaimer
    }
    
    public static func getSiteIndex() -> Int {
        return siteIndex
    }
    
    public static func needsMigration() -> Bool {
        return needsDataMigration
    }
    
    // MARK: - Setters
    
    public static func setDeliveryMethod(to: String) {
        if to != getDeliveryMethod() {
            deliveryMethod = to
            defaults.set(to, forKey: PDStrings.SettingsKey.deliv.rawValue)
            let c = (UserDefaultsController.usingPatches()) ? PDStrings.PickerData.counts[2] : PDStrings.PickerData.counts[0]
            UserDefaultsController.setQuantityWithoutWarning(to: c)
            ScheduleController.deliveryMethodChanged = true
            SiteDataController.switchDefaultSites(deliveryMethod: to, sites: &ScheduleController.siteController.siteArray, into: ScheduleController.persistentContainer.viewContext)
            
        }
    }
    
    public static func setTimeInterval(to: String) {
        timeInterval = to
        defaults.set(to, forKey: PDStrings.SettingsKey.interval.rawValue)
    }
    
    /**
    Warns the user if they are about to delete delivery data.  It is necessary to reset MOs that are no longer in the schedule, which happens when the user has is decreasing the count in a full schedule. Resetting unused MOs makes sorting the schedule less error prone and more comprehensive.
    */
    public static func setQuantityWithWarning(to newQuantity: String, oldCount: Int, countButton: UIButton, navController: UINavigationController?) {
        ScheduleController.oldDeliveryCount = oldCount
        if let newCount = Int(newQuantity), isAcceptable(count: newCount) {
            // startAndNewCount : represents two things.
            //  1.) It is the start index for reseting patches that need to be reset from decreasing a full schedule, and
            //  2.), it is the Int form of the new count
                // DECREASING COUNT
            if newCount < oldCount {
                ScheduleController.decreasedCount = true
                // alert
                let lastIndexToCheck = UserDefaultsController.getQuantityInt() - 1
                if !PDEstrogenHelper.isEmpty(ScheduleController.estrogenController.estrogenArray, fromThisIndexOnward: newCount, lastIndex: lastIndexToCheck) {
                    PDAlertController.alertForChangingCount(oldCount: oldCount, newCount: newQuantity, countButton: countButton, navController: navController)
                    return
                }
                else {
                    setQuantityWithoutWarning(to: newQuantity)
                }
            }
            // INCREASING COUNT
            else {
                setQuantityWithoutWarning(to: newQuantity)
                ScheduleController.increasedCount = true
            }
        
        }
    }
    
    public static func setQuantityWithoutWarning(to quantityStr: String) {
        // sets if greater than 0 and less than 5 first.
        if let newCount = Int(quantityStr), isAcceptable(count: newCount) {
            quantity = quantityStr
            defaults.set(quantityStr, forKey: PDStrings.SettingsKey.count.rawValue)
        }
    }
    
    public static func setNotificationOption(to option: String) {
        reminderTime = option
        defaults.set(option, forKey: PDStrings.SettingsKey.notif.rawValue)
    }
    
    public static func setNotify(to notify: Bool) {
        notifications = notify
        defaults.set(notify, forKey: PDStrings.SettingsKey.remind.rawValue)
    }

    public static func setMentionedDisclaimer(to disclaimer: Bool) {
        mentionedAppDisclaimer = disclaimer
        defaults.set(disclaimer, forKey: PDStrings.SettingsKey.setup.rawValue)
    }
    
    public static func setSiteIndex(to: Int) {
        siteIndex = to
        defaults.set(to, forKey: PDStrings.SettingsKey.site_index.rawValue)
    }
    
    public static func migrated() {
        needsDataMigration = false
        defaults.set(false, forKey: PDStrings.SettingsKey.needs_migrate.rawValue)
    }
    
    public static func incrementSiteIndex() {
        siteIndex = (siteIndex + 1) % ScheduleController.siteController.siteArray.count
        defaults.set(siteIndex, forKey: PDStrings.SettingsKey.site_index.rawValue)
    }

    //MARK: - Other public
    
    public static func usingPatches() -> Bool {
        return UserDefaultsController.getDeliveryMethod() == PDStrings.PickerData.deliveryMethods[0]
    }
    
    // MARK: - loaders
    
    private static func loadDeliveryMethod() {
        if let dm = defaults.object(forKey: PDStrings.SettingsKey.deliv.rawValue) as? String {
            deliveryMethod = dm
        }
        else if let dm = std_defaults.object(forKey: PDStrings.SettingsKey.deliv.rawValue) as? String {
            deliveryMethod = dm
        }
        else {
            setDeliveryMethod(to: PDStrings.PickerData.deliveryMethods[0])
        }
    }
    
    private static func loadTimeIntervalHelper(to interval: String) {
        switch interval {
        case "One half-week": timeInterval = PDStrings.PickerData.expirationIntervals[0]
        case "One week": timeInterval = PDStrings.PickerData.expirationIntervals[1]
        case "Two weeks": timeInterval = PDStrings.PickerData.expirationIntervals[2]
        default: timeInterval = interval
        }
    }
    
    private static func loadTimeInterval() {
        if let interval = defaults.object(forKey: PDStrings.SettingsKey.interval.rawValue) as? String {
            loadTimeIntervalHelper(to: interval)
        }
        else if let interval = std_defaults.object(forKey: PDStrings.SettingsKey.interval.rawValue) as? String {
            loadTimeIntervalHelper(to: interval)
        }
        else {
            setTimeInterval(to: PDStrings.PickerData.expirationIntervals[0])
        }
    }
    
    private static func loadQuantityHelper(countStr: String) {
        if let countInt = Int(countStr), (countInt >= 1 || countInt <= 4) {
            quantity = countStr
        }
        else {
            setQuantityWithoutWarning(to: PDStrings.PickerData.counts[2])
        }
    }
    
    private static func loadQuantity() {
        if let countStr = defaults.object(forKey: PDStrings.SettingsKey.count.rawValue) as? String {
            loadQuantityHelper(countStr: countStr)
        }
        else if let countStr = std_defaults.object(forKey: PDStrings.SettingsKey.count.rawValue) as? String {
            loadQuantityHelper(countStr: countStr)
        }
        else {
            setQuantityWithoutWarning(to: PDStrings.PickerData.counts[2])
        }
    }
    
    private static func loadNotificationOption() {
        if let notifyTime = defaults.object(forKey: PDStrings.SettingsKey.notif.rawValue) as? String {
            reminderTime = notifyTime
        }
        else if let notifyTime = std_defaults.object(forKey: PDStrings.SettingsKey.notif.rawValue) as? String {
            reminderTime = notifyTime
        }
        else {
            setNotificationOption(to: PDStrings.PickerData.notificationTimes[0])
        }
    }
    
    private static func loadRemindUpon() {
        if let notifyMe = defaults.object(forKey: PDStrings.SettingsKey.remind.rawValue) as? Bool {
            notifications = notifyMe
        }
        else if let notifyMe = std_defaults.object(forKey: PDStrings.SettingsKey.remind.rawValue) as? Bool {
            notifications = notifyMe
        }
        else {
            setNotify(to: true)
        }
    }

    // Note:  non-shared.
    private static func loadMentionedDisclaimer() {
        if let mentioned = std_defaults.object(forKey: PDStrings.SettingsKey.setup.rawValue) as? Bool {
            mentionedAppDisclaimer = mentioned
        }
    }
    
    private static func loadSiteIndex() {
        if let site_i = defaults.object(forKey: PDStrings.SettingsKey.site_index.rawValue) as? Int {
            siteIndex = site_i
        }
        else if let site_i = std_defaults.object(forKey: PDStrings.SettingsKey.site_index.rawValue) as? Int {
            siteIndex = site_i
        }
        else {
            setSiteIndex(to: 0)
        }
    }
    
    // Note: non-shared.
    private static func loadNeedsMigration() {
        if let needs = std_defaults.object(forKey: PDStrings.SettingsKey.needs_migrate.rawValue) as? Bool {
            needsDataMigration = needs
        }
    }
    
    // MARK: - helpers
    
    /// Checks to see if count is reasonable for PatchDay
    private static func isAcceptable(count: Int) -> Bool {
        return (count > 0) && (count <= 4)
    }
    
    /// Removes the word "minutes" from the notification option
    private static func cutNotificationMinutes(of: String) -> String {
        var builder = ""
        for c in of {
            if c == " " {
                return builder
            }
            builder += String(c)
        }
        return builder
    }
    
}
