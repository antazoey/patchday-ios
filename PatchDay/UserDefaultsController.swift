//
//  UserDefaultsController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/25/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit

public class UserDefaultsController: NSObject {
    
    // Description: The UserDefaultsController is the controller for the User Defaults that are unique to the user and their schedule.  There are schedule defaults and there are notification defaults.  The schedule defaults included the patch expiration interval (timeInterval) and the quantity of estrogen in patches or shorts in the schedule.  The notification defaults includes a bool indicatinng whether the user wants a reminder and the time before expiration that the user would wish to receive the reminder.  It also includes a bool for the Autofill Site Functionality.
    
    // App
    static private var defaults = UserDefaults.standard
    
    // Schedule defaults:
    static private var deliveryMethod: String = PDStrings.pickerData.deliveryMethods[0]
    static private var timeInterval: String = PDStrings.pickerData.expirationIntervals[0]
    static internal var quantity: String =  PDStrings.pickerData.counts[3]
    
    // Notification defaults:
    static private var remindMeUpon: Bool = false
    static private var reminderTime: String = PDStrings.pickerData.notificationTimes[0]
    
    // Rememberance
    static private var mentionedDisclaimer: Bool = false

    // MARK: - a static initializer
    
    public static func setUp() {
        self.loadDeliveryMethod()
        self.loadTimeInterval()
        self.loadQuantity()
        self.loadNotificationOption()
        self.loadRemindUpon()
        self.loadMentionedDisclaimer()
    }
    
    // MARK: - Getters
    
    public static func getDeliveryMethod() -> String {
        return self.deliveryMethod
    }
    
    public static func getTimeInterval() -> String {
        return self.timeInterval
    }
    
    public static func getQuantityString() -> String {
        return self.quantity
    }
    
    public static func getQuantityInt() -> Int {
        if let int = Int(self.quantity) {
            return int
        }
        else {
            return -1
        }
    }
    
    public static func getNotificationTimeString() -> String {
        return self.reminderTime
    }
    
    public static func getNotificationTimeInt() -> Int {
        // remove word "minutes"
        let min: String = self.cutNotificationMinutes(of: self.reminderTime)
        if let int = Int(min) {
            return int
        }
        else {
            return -1
        }
    }
    
    public static func getNotificationTimeDouble() -> Double {
        // remove word "minutes"
        let min: String = self.cutNotificationMinutes(of: self.reminderTime)
        if let double = Double(min) {
            return double
        }
        else {
            return -1
        }
    }
    
    public static func getRemindMeUpon() -> Bool {
        return self.remindMeUpon
    }

    public static func getMentionedDisclaimer() -> Bool {
        return self.mentionedDisclaimer
    }
    
    // MARK: - Setters
    
    public static func setDeliveryMethod(to: String) {
        if to != self.getDeliveryMethod() {
            self.deliveryMethod = to
            self.defaults.set(to, forKey: PDStrings.userDefaultKeys.deliv)
            defaults.synchronize()
            let c = (UserDefaultsController.usingPatches()) ? PDStrings.pickerData.counts[2] : PDStrings.pickerData.counts[0]
            UserDefaultsController.setQuantityWithoutWarning(to: c)
            CoreDataController.deliveryMethodChanged = true
            CoreData.switchDefaultSites(deliveryMethod: to, sites: &CoreDataController.coreData.loc_array)
            
        }
    }
    
    public static func setTimeInterval(to: String) {
        self.timeInterval = to
        self.defaults.set(to, forKey: PDStrings.userDefaultKeys.interval)
        defaults.synchronize()
    }
    
    /******************************************************************
    setQuantityWithWarning(to, oldCount, countButton) : Will warn the user if they are about to delete delivery data.  It is necessary to reset MOs that are no longer in the schedule, which happens when the user has is decreasing the count in a full schedule. Resetting unused MOs makes sorting the schedule less error prone and more comprehensive.
    *****************************************************************/
    public static func setQuantityWithWarning(to: String, oldCount: Int, countButton: UIButton) {
        CoreDataController.oldDeliveryCount = oldCount
        if let newCount = Int(to), self.isAcceptable(count: newCount) {
            // startAndNewCount : represents two things.  1.) It is the start index for reseting patches that need to be reset from decreasing a full schedule, and 2.), it is the Int form of the new count
            if let startAndNewCount = Int(to) {
                // DECREASING COUNT
                if startAndNewCount < oldCount {
                    CoreDataController.decreasedCount = true        // animate schedule
                    // alert
                    if !CoreDataController.schedule().isEmpty(fromThisIndexOnward:
                        startAndNewCount) {
                        PDAlertController.alertForChangingCount(oldCount: oldCount, newCount: to, countButton: countButton)
                        return
                    }
                    else {
                        self.setQuantityWithoutWarning(to: to)  // don't alert
                    }
                }
                // INCREASING COUNT
                else {                                          // don't alert
                    self.setQuantityWithoutWarning(to: to)
                    CoreDataController.increasedCount = true        // animate schedule
                }
            }
        }
    }
    
    public static func setQuantityWithoutWarning(to: String) {
        // sets if greater than 0 and less than 5 first.
        if let newCount = Int(to), self.isAcceptable(count: newCount) {
            self.quantity = to
            self.defaults.set(to, forKey: PDStrings.userDefaultKeys.count)
            defaults.synchronize()
        }
    }
    
    public static func setNotificationOption(to: String) {
        self.reminderTime = to
        self.defaults.set(to, forKey: PDStrings.userDefaultKeys.notif)
        defaults.synchronize()
    }
    
    public static func setRemindMeUpon(to: Bool) {
        self.remindMeUpon = to
        self.defaults.set(to, forKey: PDStrings.userDefaultKeys.remind)
        defaults.synchronize()
    }

    public static func setMentionedDisclaimer(to: Bool) {
        self.mentionedDisclaimer = to
        self.defaults.set(to, forKey: PDStrings.userDefaultKeys.setup)
        defaults.synchronize()
    }
    
    //MARK: - Other public
    
    public static func format(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy, h:mm a"
        return dateFormatter.string(from: date)
    }
    
    public static func usingPatches() -> Bool {
        return UserDefaultsController.getDeliveryMethod() == PDStrings.pickerData.deliveryMethods[0]
    }
    
    // MARK: - loaders
    
    private static func loadDeliveryMethod() {
        if let dm = self.defaults.object(forKey: PDStrings.userDefaultKeys.deliv) as? String {
            self.deliveryMethod = dm
        }
        else {
            self.setDeliveryMethod(to: PDStrings.pickerData.deliveryMethods[0])
        }
    }
    
    private static func loadTimeInterval() {
        if let interval = self.defaults.object(forKey: PDStrings.userDefaultKeys.interval) as? String {
            switch interval {
            case "One half-week": self.timeInterval = PDStrings.pickerData.expirationIntervals[0]
                break
            case "One week": self.timeInterval = PDStrings.pickerData.expirationIntervals[1]
                break
            case "Two weeks": self.timeInterval = PDStrings.pickerData.expirationIntervals[2]
                break
            default: self.timeInterval = interval
            }
        }
        else {
            self.setTimeInterval(to: PDStrings.pickerData.expirationIntervals[0])
        }
    }
    
    private static func loadQuantity() {
        if let countStr = self.defaults.object(forKey: PDStrings.userDefaultKeys.count) as? String {
            // contrain patch count
            if let countInt = Int(countStr), (countInt >= 1 || countInt <= 4) {
                self.quantity = countStr
            }
            else {
                self.setQuantityWithoutWarning(to: PDStrings.pickerData.counts[2])
            }
        }
        else {
            self.setQuantityWithoutWarning(to: PDStrings.pickerData.counts[2])
        }
    }
    
    private static func loadNotificationOption() {
        if let notifyTime = defaults.object(forKey: PDStrings.userDefaultKeys.notif) as? String {
            self.reminderTime = notifyTime
        }
        else {
            self.setNotificationOption(to: PDStrings.pickerData.notificationTimes[0])
        }
    }
    
    private static func loadRemindUpon() {
        if let notifyMe = defaults.object(forKey: PDStrings.userDefaultKeys.remind) as? Bool {
            self.remindMeUpon = notifyMe
        }
        else {
            self.setRemindMeUpon(to: true)
        }
    }

    private static func loadMentionedDisclaimer() {
        if let mentioned = defaults.object(forKey: PDStrings.userDefaultKeys.setup) as? Bool {
            self.mentionedDisclaimer = mentioned
        }
    }
    
    // MARK: - helpers
    
    private static func isAcceptable(count: Int) -> Bool {
        // checks to see if count is reasonable for PatchDay
        if count > 0 && count <= 4 {
            return true
        }
        else {
            return false
        }
    }
    
    // cutNotificationMinutes(of) : remove the word "minutes" from the notification option
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
