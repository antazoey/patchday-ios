//
//  SettingsDefaultsController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/25/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

public class SettingsDefaultsController: NSObject {
    
    // Description: The SettingsDefaultsController is the controller for the User Defaults that are unique to the user and their schedule.  There are schedule defaults and there are notification defaults.  The schedule defaults included the patch expiration interval (timeInterval) and the quantity of estrogen in patches or shorts in the schedule.  The notification defaults includes a bool indicatinng whether the user wants a reminder and the time before expiration that the user would wish to receive the reminder.  It also includes a bool for the Suggest Location Functionality.
    
    // Schedule defaults:
    static private var timeInterval: String = "Half-Week"
    static internal var quantity: String =  "4"
    static private var slf: Bool = true
    
    // Pill defaults:
    static private var includeTB: Bool = true
    static private var includePG: Bool = false
    static private var tb1_time: Date = Date()
    static private var pg1_time: Date = Date()
    static private var tb_timesaday: Int = 1
    static private var pg_timesaday: Int = 1
    static private var tb2_time: Date = Date()
    static private var pg2_time: Date = Date()
    
    // Pill timestamps
    static private var tb1_stamp: Date = Date()
    static private var tb2_stamp: Date = Date()
    static private var pg1_stamp: Date = Date()
    static private var pg2_stamp: Date = Date()
    
    // non-UserDefault objects
    static public var tb1_stamped: Bool = false
    static public var tb2_stamped: Bool = false
    static public var pg1_stamped: Bool = false
    static public var pg2_stamped: Bool = false
    
    // Notification defaults:
    static private var remindMeUpon: Bool = true
    static private var remindMeBefore: Bool = false
    static private var notificationOption: String = "30"
    
    // Rememberance
    static private var mentionedDisclaimer: Bool = false
    
    // App
    static private var defaults = UserDefaults.standard

    // MARK: - a static initializer
    
    public static func setUp() {
        self.loadTimeInterval()
        self.loadQuantity()
        self.loadIncludeTB()
        self.loadIncludePG()
        self.loadTB1Time()
        self.loadPG1Time()
        self.loadTBTimesaday()
        self.loadPGTimesaday()
        self.loadTB2time()
        self.loadPG2time()
        self.loadTB1Stamp()
        self.loadTB2Stamp()
        self.loadPG1Stamp()
        self.loadPG2Stamp()
        
        self.loadNotificationOption()
        self.loadSLF()
        self.loadRemindMeUpon()
        self.loadRemindMeBefore()
        self.loadMentionedDisclaimer()
    }
    
    // MARK: - Getters
    
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
    
    public static func getIncludeTB() -> Bool {
        return self.includeTB
    }
    
    public static func getIncludePG() -> Bool {
        return self.includePG
    }
    
    public static func getTB1Time() -> Date {
        return self.tb1_time
    }
    
    public static func getPG1Time() -> Date {
        return self.pg1_time
    }
    
    public static func getTBtimesadayInt() -> Int {
        return self.tb_timesaday
    }
    
    public static func getTBtimesadayString() -> String {
        return String(self.tb_timesaday)
    }
    
    public static func getPGtimesadayInt() -> Int {
        return self.pg_timesaday
    }
    
    public static func getPGtimesadayString() -> String {
        return String(self.pg_timesaday)
    }
    
    public static func getTB2Time() -> Date {
        return self.tb2_time
    }
    
    public static func getPG2Time() -> Date {
        return self.pg2_time
    }
    
    public static func getTB1TimeStamp() -> Date {
        return self.tb1_stamp
    }
    
    public static func getTB2TimeStamp() -> Date {
        return self.tb2_stamp
    }
    
    public static func getPG1TimeStamp() -> Date {
        return self.pg1_stamp
    }
    
    public static func getPG2TimeStamp() -> Date {
        return self.pg2_stamp
    }
    
    public static func getNotificationTimeString() -> String {
        return self.notificationOption
    }
    
    public static func getNotificationTimeInt() -> Int {
        // remove word "minutes"
        let min: String = self.cutNotificationMinutes(of: self.notificationOption)
        if let int = Int(min) {
            return int
        }
        else {
            return -1
        }
    }
    
    public static func getNotificationTimeDouble() -> Double {
        // remove word "minutes"
        let min: String = self.cutNotificationMinutes(of: self.notificationOption)
        if let double = Double(min) {
            return double
        }
        else {
            return -1
        }
    }
    
    public static func getSLF() -> Bool {
        return self.slf
    }
    
    public static func getRemindMeUpon() -> Bool {
        return self.remindMeUpon
    }
    
    public static func getRemindMeBefore() -> Bool {
        return self.remindMeBefore
    }
    
    public static func getMentionedDisclaimer() -> Bool {
        return self.mentionedDisclaimer
    }
    
    // MARK: - Setters
    
    public static func setTimeInterval(to: String) {
        self.timeInterval = to
        self.defaults.set(to, forKey: PDStrings.interval_key())
        self.synchonize()
    }
    
    public static func setQuantityWithWarning(to: String, oldCount: Int, countButton: UIButton) {
        print ("old patch count: " + String(describing: oldCount))
        if let newPatchCount = Int(to), isAcceptable(patchCount: newPatchCount) {
        
         //This method will warn the user if they are about to delete patch data.
         
         //It is necessary to reset patches that are no longer in the schedule, which happens when the user has is decreasing the count in a full schedule.  Resetting unused patches makes sorting the schedule less error prone and more comprehensive.
        
         //The variable "startAndNewCount" represents two things.  1.) It is the start index for reseting patches that need to be reset from decreasing a full schedule, and 2.), it is the Int form of the new count
        
            if let startAndNewCount = Int(to) {
                // delete old patch data for easy sorting
                if startAndNewCount < oldCount {
                    // if the schedule is not empty from this start index onward...
                    // meaning if at least one patch location or date attribute is set...
                    // than we are going to delete data and should alert the user.
                    if !ScheduleController.schedule().scheduleIsEmpty(fromThisIndexOnward:
                        startAndNewCount) {
                        PDAlertController.alertForChangingPatchCount(startIndexForReset: startAndNewCount, endIndexForReset: oldCount, newPatchCount: to, countButton: countButton)
                        self.synchonize()
                        return
                    }
                    else {
                        self.setQuantityWithoutWarning(to: to)
                    }
                }
                else {
                    self.setQuantityWithoutWarning(to: to)
                }
            }
        }
    }
    
    public static func setQuantityWithoutWarning(to: String) {
        // sets if greater than 0 and less than 5 first.
        if let newPatchCount = Int(to), self.isAcceptable(patchCount: newPatchCount) {
            self.quantity = to
            self.defaults.set(to, forKey: PDStrings.count_key())
            self.synchonize()
        }
    }
    
    public static func setIncludeTB(to: Bool) {
        self.includeTB = to
        self.defaults.set(to, forKey: PDStrings.includeTB_key())
        self.resetTimeStamps()      // reset timeStamps
        self.synchonize()
    }
    
    public static func setIncludePG(to: Bool) {
        self.includePG = to
        self.defaults.set(to, forKey: PDStrings.includePG_key())
        self.resetTimeStamps()      // reset timeStamps
        self.synchonize()
    }
    
    public static func setTB1Time(to: Date) {
        self.tb1_time = to
        self.defaults.set(to, forKey: PDStrings.tbTime_key())
        self.synchonize()
    }
    
    public static func setPG1Time(to: Date) {
        self.pg1_time = to
        self.defaults.set(to, forKey: PDStrings.pgTime_key())
        self.synchonize()
    }
    
    public static func setTBtimesaday(to: Int) {
        self.tb_timesaday = to
        self.defaults.set(to, forKey: PDStrings.tb_timesaday_key())
        self.synchonize()
    }
    
    public static func setPGtimesaday(to: Int) {
        self.pg_timesaday = to
        self.defaults.set(to, forKey: PDStrings.pg_timesaday_key())
        self.synchonize()
    }
    
    public static func setTB2time(to: Date) {
        self.tb2_time = to
        self.defaults.set(to, forKey: PDStrings.tb2Time_key())
        self.synchonize()
    }
    
    public static func setPG2time(to: Date) {
        self.pg2_time = to
        self.defaults.set(to, forKey: PDStrings.pg2Time_key())
        self.synchonize()
    }
    
    public static func setTB1TimeStamp(to: Date) {
        self.tb1_stamp = to
        self.defaults.set(to, forKey: PDStrings.tb1Stamp_key())
        self.synchonize()
    }

    public static func setTB2TimeStamp(to: Date) {
        self.tb2_stamp = to
        self.defaults.set(to, forKey: PDStrings.tb2Stamp_key())
        self.synchonize()
    }
    
    public static func setPG1TimeStamp(to: Date) {
        self.pg1_stamp = to
        self.defaults.set(to, forKey: PDStrings.pg1Stamp_key())
        self.synchonize()
    }
    
    public static func setPG2TimeStamp(to: Date) {
        self.pg2_stamp = to
        self.defaults.set(to, forKey: PDStrings.pg2Stamp_key())
        self.synchonize()
    }
    
    public static func setNotificationOption(to: String) {
        self.notificationOption = to
        self.defaults.set(to, forKey: PDStrings.notif_key())
        self.synchonize()
    }
    
    public static func setSLF(to: Bool) {
        self.slf = to
        self.defaults.set(to, forKey: PDStrings.slf_key())
        self.synchonize()
    }
    
    static func setRemindMeUpon(to: Bool) {
        self.remindMeUpon = to
        self.defaults.set(to, forKey: PDStrings.rMeUpon_key())
    }
    
    static func setRemindMeBefore(to: Bool) {
        self.remindMeBefore = to
        self.defaults.set(to, forKey: PDStrings.rMeBefore_key())
        self.synchonize()
    }

    public static func setMentionedDisclaimer(to: Bool) {
        self.mentionedDisclaimer = to
        self.defaults.set(to, forKey: PDStrings.mentionedDisc_key())
        self.synchonize()
    }
    
    //MARK: - Other public
    
    public static func synchonize() {
        defaults.synchronize()
    }
    
    // formatTime(time) : input pill time, output its string
    static public func formatTime(time: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: time)
    }
    
    static public func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy, h:mm a"
        return dateFormatter.string(from: date)
    }
    
    // threeAM(afterDate) : returns the 3am of the next date after the inputted
    static public func threeAM(afterDate: Date) -> Date? {
        let cal = Calendar.current
        if let tday_3 = cal.date(bySettingHour: 3, minute: 0, second: 0, of: afterDate), let tmr_3 = cal.date(byAdding: .hour, value: 24, to: tday_3) {
            return tmr_3
        }
        return nil
    }
    
    // isAfterNow(time) : if the inputted time is after now, true
    // helpful for comparing the pill times to see if they need to be taken
    // if isAfterNow, then the pill does not necessarilly need to be taken yet
    public static func isAfterNow(time: Date) -> Bool {
        // let both input and now be strings...
        let t_str = self.formatTime(time: time)
        let now_str = self.formatTime(time: Date())
        // formatter will make new dates from strings that are comparable
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            formatter.timeZone = TimeZone.current
            return formatter
        } ()
        // compare new dates
        if let time_i = dateFormatter.date(from: t_str), let now = dateFormatter.date(from: now_str) {
            if time_i > now {
                return true
            }
            return false
        }
        return false            // should not get here
    }
    
    // isPillTime() : returns true if user should attend to one or more pills
    public static func isPillTime() -> Bool {
        let hasPills: Bool = self.includeTB || self.includePG
        if hasPills && (self.isAfterNow(time: self.getTB1Time()) || self.isAfterNow(time: self.getTB2Time()) || self.isAfterNow(time: self.getPG1Time()) || self.isAfterNow(time: self.getPG2Time())) {
            return true
        }
        return false
    }
    
    // MARK: - loaders
    
    static private func loadTimeInterval() {
        if let interval = self.defaults.object(forKey: PDStrings.interval_key()) as? String {
            self.timeInterval = interval
        }
    }
    
    static private func loadQuantity() {
        if let countStr = self.defaults.object(forKey: PDStrings.count_key()) as? String {
            // contrain patch count
            if let countInt = Int(countStr), countInt < 1 {
                if countInt >= 1 || countInt <= 4 {             // range constrain: 1...4
                    self.quantity = countStr
                }
            }
        }
    }
    
    static private func loadIncludeTB() {
        if let i_tb = self.defaults.object(forKey: PDStrings.includeTB_key()) as? Bool {
            self.includeTB = i_tb
        }
    }
    
    static private func loadIncludePG() {
        if let i_pg = self.defaults.object(forKey: PDStrings.includePG_key()) as? Bool {
            self.includePG = i_pg
        }
    }
    
    static private func loadTB1Time() {
        if let tb_t = self.defaults.object(forKey: PDStrings.tbTime_key()) as? Date {
            self.tb1_time = tb_t
        }
    }
    
    static private func loadPG1Time() {
        if let pg_t = self.defaults.object(forKey: PDStrings.pgTime_key()) as? Date {
            self.pg1_time = pg_t
        }
    }
    
    static private func loadTB2time() {
        if let tb_t2 = self.defaults.object(forKey: PDStrings.tb2Time_key()) as? Date {
            self.tb2_time = tb_t2
        }
    }
    
    static private func loadPG2time() {
        if let pg_t2 = self.defaults.object(forKey: PDStrings.pg2Time_key()) as? Date {
            self.pg2_time = pg_t2
        }
    }
    
    static private func loadTBTimesaday() {
        if let tb_x = self.defaults.object(forKey: PDStrings.tb_timesaday_key()) as? Int {
            self.tb_timesaday = tb_x
        }
    }
    
    static private func loadPGTimesaday() {
        if let pg_x = self.defaults.object(forKey: PDStrings.pg_timesaday_key()) as? Int {
            self.pg_timesaday = pg_x
        }
    }
    
    static private func loadTB1Stamp() {
        let now = Date()
        if let tb_s = self.defaults.object(forKey: PDStrings.tb1Stamp_key()) as? Date, let three_am = self.threeAM(afterDate: tb_s), now < three_am {
            self.tb1_stamp = tb_s
            self.tb1_stamped = true
        }
    }
    
    static private func loadTB2Stamp() {
        let now = Date()
        if let tb_s = self.defaults.object(forKey: PDStrings.tb2Stamp_key()) as? Date, let three_am = self.threeAM(afterDate: tb_s), now < three_am {
            self.tb2_stamp = tb_s
            self.tb2_stamped = true
        }
    }
    
    static private func loadPG1Stamp() {
        let now = Date()
        if let pg_s = self.defaults.object(forKey: PDStrings.pg1Stamp_key()) as? Date, let three_am = self.threeAM(afterDate: pg_s), now < three_am {
            self.pg1_stamp = pg_s
            self.pg1_stamped = true
        }
    }
    
    static private func loadPG2Stamp() {
        let now = Date()
        if let pg_s = self.defaults.object(forKey: PDStrings.pg2Stamp_key()) as? Date, let three_am = self.threeAM(afterDate: pg_s), now < three_am {
            self.pg2_stamp = pg_s
            self.pg2_stamped = true
        }
    }
    
    static private func loadNotificationOption() {
        if let notifyTime = defaults.object(forKey: PDStrings.notif_key()) as? String {
            self.notificationOption = notifyTime
        }
    }
    
    static private func loadSLF() {
        if let suggest = defaults.object(forKey: PDStrings.slf_key()) as? Bool {
            self.slf = suggest
        }
    }
    
    static private func loadRemindMeUpon() {
        if let notifyMe = defaults.object(forKey: PDStrings.rMeUpon_key()) as? Bool {
            self.remindMeUpon = notifyMe
        }
    }
    
    static private func loadRemindMeBefore() {
        if let notifyMe = defaults.object(forKey: PDStrings.rMeBefore_key()) as? Bool {
            self.remindMeBefore = notifyMe
        }
    }
    
    static private func loadMentionedDisclaimer() {
        if let mentioned = defaults.object(forKey: PDStrings.mentionedDisc_key()) as? Bool {
            self.mentionedDisclaimer = mentioned
        }
    }
    
    // MARK: - helpers
    
    static private func resetTimeStamps() {
        self.setTB1TimeStamp(to: Date())
        self.setTB2TimeStamp(to: Date())
        self.tb1_stamped = false
        self.tb2_stamped = false
        self.synchonize()
    }
    
    static private func isAcceptable(patchCount: Int) -> Bool {
        // checks to see if patchCount is reasonable for PatchDay
        if patchCount > 0 && patchCount <= 4 {
            return true
        }
        else {
            return false
        }
    }
    
    // cutNotificationMinutes remove the word "minutes" from the notification option
    static private func cutNotificationMinutes(of: String) -> String {
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
