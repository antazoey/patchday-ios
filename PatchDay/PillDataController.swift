//
//  PillDataController.swift
//  PatchDay
//
//  Created by Juliya Smith on 12/28/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation

public typealias Time = Date
public typealias Stamp = Date
public typealias Stamps = [Stamp?]?

public class PillDataController: NSObject {
    
    // App
    static private var defaults = UserDefaults.standard
    
    // TB data
    static private var includeTB: Bool = true       // include t-blocker
    static private var tb_daily: Int = 1            // taken (1 or 2)
    static private var tb1_time: Time = Time()      // 1st time should take
    static private var tb2_time: Time = Time()      // 2nd time should take
    static private var remindTB: Bool = true        // notification?
    
    static public var tb_stamps: Stamps             // last time taken
    
    // PG data
    static private var includePG: Bool = false      // include progesterone
    static private var pg_daily: Int = 1            // taken (1 or 2)
    static private var pg1_time: Time = Time()      // 1st time should take
    static private var pg2_time: Time = Time()      // 2nd time should take
    static private var remindPG: Bool = true        // notification?
    
    static public var pg_stamps: Stamps             // last time taken
    
    public static func setUp() {
        
        // Load TB Data
        self.loadIncludeTB()
        self.loadTBDaily()
        self.loadTB1Time()
        self.loadTB2time()
        self.loadTBTaken()
        self.loadRemindTB()
        
        // Load PGData
        self.loadIncludePG()
        self.loadPGTimesaday()
        self.loadPG1Time()
        self.loadPG2time()
        self.loadPGTaken()
        self.loadRemindPG()
    }
    
    // MARK: - Getters TB
    
    public static func includingTB() -> Bool {
        return self.includeTB
    }
    
    public static func getTBDailyInt() -> Int {
        return self.tb_daily
    }
    
    public static func getTBDailyString() -> String {
        return String(self.tb_daily)
    }
    
    public static func getTB1Time() -> Time {
        return self.tb1_time
    }
    
    public static func getTB2Time() -> Time {
        return self.tb2_time
    }

    public static func getRemindTB() -> Bool {
        return self.remindTB
    }

    // MARK: - Getters PG
    
    public static func includingPG() -> Bool {
        return self.includePG
    }
    
    public static func getPGDailyInt() -> Int {
        return self.pg_daily
    }
    
    public static func getPGDailyString() -> String {
        return String(self.pg_daily)
    }

    public static func getPG1Time() -> Time {
        return self.pg1_time
    }
    
    public static func getPG2Time() -> Time {
        return self.pg2_time
    }
    
    public static func getRemindPG() -> Bool {
        return self.remindPG
    }
    
    // MARK: - TB Setters
    
    public static func setIncludeTB(to: Bool) {
        self.includeTB = to
        self.defaults.set(to, forKey: PDStrings.userDefaultKeys.includeTB)
        self.synchonize()
    }
    
    public static func setTBDaily(to: Int) {
        self.tb_daily = to
        self.defaults.set(to, forKey: PDStrings.userDefaultKeys.tbDaily)
        self.synchonize()
    }
    
    public static func setTB1Time(to: Time) {
        self.tb1_time = to
        self.defaults.set(to, forKey: PDStrings.userDefaultKeys.tbTime1)
        self.synchonize()
    }
    
    public static func setTB2Time(to: Time) {
        self.tb2_time = to
        self.defaults.set(to, forKey: PDStrings.userDefaultKeys.tbTime2)
        self.synchonize()
    }
    
    static func setRemindTB(to: Bool) {
        self.remindTB = to
        self.defaults.set(to, forKey: PDStrings.userDefaultKeys.remindTB)
        self.synchonize()
    }

    // MARK: - PG Setters
    
    public static func setIncludePG(to: Bool) {
        self.includePG = to
        self.defaults.set(to, forKey: PDStrings.userDefaultKeys.includePG)
        self.synchonize()
    }
    
    public static func setPGDaily(to: Int) {
        self.pg_daily = to
        self.defaults.set(to, forKey: PDStrings.userDefaultKeys.pgDaily)
        self.synchonize()
    }
    
    public static func setPG1Time(to: Time) {
        self.pg1_time = to
        self.defaults.set(to, forKey: PDStrings.userDefaultKeys.pgTime1)
        self.synchonize()
    }
    
    public static func setPG2Time(to: Time) {
        self.pg2_time = to
        self.defaults.set(to, forKey: PDStrings.userDefaultKeys.pgTime2)
        self.synchonize()
    }
    
    public static func setRemindPG(to: Bool) {
        self.remindPG = to
        self.defaults.set(to, forKey: PDStrings.userDefaultKeys.remindPG)
        self.synchonize()
    }
    
    // MARK: - Other public
    
    public static func synchonize() {
        defaults.synchronize()
    }
    
    // The newer stamp is always the last element.
    public static func getLaterStamp(stamps: Stamps) -> Stamp? {
        if let stamps = stamps, stamps.count > 0 {
            return stamps[stamps.count-1]
        }
        return nil
    }
    
    // The older stamp is always at the 0 index.
    public static func getOlderStamp(stamps: Stamps) -> Stamp? {
        if let stamps = stamps, stamps.count > 0 {
            return stamps[0]
        }
        return nil
    }
    
    // Returns number of stamps in stamps that were taken today.
    public static func takenTodayCount(stamps: Stamps) -> Int {
        var takenToday: Int = 0
        if let stamps = stamps {
            for i in 0...(stamps.count-1) {
                if let stamp = stamps[i], Calendar.current.isDateInToday(stamp) {
                    takenToday += 1
                }
            }
        }
        return takenToday
    }
    
    public static func getFrac(mode: String) -> String? {
        let including = (mode == "TB") ? PillDataController.includingTB() : PillDataController.includingPG()
        if !including { return nil }
        else {
            let stamps = (mode == "TB") ? PillDataController.tb_stamps : PillDataController.pg_stamps
            let count = (mode == "TB") ? PillDataController.getTBDailyInt() : PillDataController.getPGDailyInt()
            let takenToday = PillDataController.takenTodayCount(stamps: stamps)
            let done = count == takenToday
            let twoPills = count == 2
            var frac = ""
            if done && twoPills {
                frac = PDStrings.fractionStrings.twoOutOfTwo
            }
            else if done && !twoPills {
                frac = PDStrings.fractionStrings.oneOutOfOne
            }
            else if !done && twoPills && takenToday == 1 {
                frac = PDStrings.fractionStrings.oneOutOfTwo
            }
            else if !done && twoPills && takenToday == 0 {
                frac = PDStrings.fractionStrings.zeroOutOfTwo
            }
            else {
                frac = PDStrings.fractionStrings.zeroOutOfOne
            }
            return frac
        }
    }
    
    // take(this, at) : Translates to takePG(at) or takeTB(at) (legacy)
    // Stamps is a stack - the older stamp is always at the index 0.
    public static func take(this: inout Stamps, at: Date, timesaday: Int, key: String) {
        /*----------------------------------------
         if...
            1.) taken pills at some point OR
            2.) scheduled two pills a day
        ----------------------------------------*/
        if this != nil, timesaday > 1 {             // two-a-day
            if (this?.count)! < 2 {                 // Only one on record so far
                this?.append(at)                    // append (places at index 1)
            }
            else {
                let movedVal = this?[1]
                this?[0] = movedVal                 // move the old Late stamp down
                this?[1] = at                       // append new Late stamp
            }
        }
        /*----------------------------------------
         if...
            1.) have yet to take any pills
            2.) scheduled one pill a day
        ----------------------------------------*/
        
        else {
            this = [at]                         // one-a-day or never before
        }
        
        //**********************************
        // ** Saving should always happen **
        //**********************************
        self.defaults.set(this, forKey: key)
        self.synchonize()
    }
    
    // format(time) : Input pill time, output time string
    static public func format(time: Time) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: time)
    }
    
    // format(date) : Input pill time, output date string
    static public func format(date: Date) -> String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            dateFormatter.dateFormat = "h:mm a"
            return PDStrings.dayStrings.today + ", " + dateFormatter.string(from: date)
        }
        else if let yesterday: Date = PillDataController.getDate(at: Date(), daysToAdd: -1), calendar.isDate(date, inSameDayAs: yesterday) {
            dateFormatter.dateFormat = "h:mm a"
            return PDStrings.dayStrings.yesterday + ", " + dateFormatter.string(from: date)
        }
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: date)
    }
    
    // containsDue() : Returns true if any pill in the schedule needs to be taken (isDue()).
    static public func containsDue() -> Bool {
        return (self.includeTB && isDue(timesaday: tb_daily, stamps: tb_stamps, time1: tb1_time, time2: tb2_time)) || (self.includePG && isDue(timesaday: pg_daily, stamps: pg_stamps, time1: pg1_time, time2: pg2_time))
    }
    
    // totalDue() : Returns total number of due pills.
    static public func totalDue() -> Int {
        var total = 0
        if self.includeTB && isDue(timesaday: tb_daily, stamps: tb_stamps, time1: tb1_time, time2: tb2_time) {
            total += 1
        }
        if self.includePG && isDue(timesaday: pg_daily, stamps: pg_stamps, time1: pg1_time, time2: pg2_time) {
            total += 1
        }
        return total
    }
    
    // isDue(timesday, stamp, time1, time2) : Returns true if it is time to take a TB or a PG, determined by if the current time is after the time it is due.
    static public func isDue(timesaday: Int, stamps: Stamps, time1: Time, time2: Time) -> Bool {
        
        // **** 1st due time is valid ****
        if let due_t1: Date = self.getTodayDate(at: time1) {
            // *** User took pill at least once historically ***
            if let stamps: [Stamp?] = stamps, stamps.count >= 1, let s1: Stamp = stamps[0] {
                // ** one-a-day **
                if timesaday < 2 {
                    return self.notTakenAndPastDue(correspondingStamp: s1, dueDate: due_t1)
                }
                // **** 2nd due time is valid ****
                // ** two-a-day **
                else if let due_t2: Date = self.getTodayDate(at: time2) {
                    // * Have taken pill at least twice *
                    if stamps.count > 1, let s2: Stamp = stamps[1] {
                        let s1Stamped = Calendar.current.isDate(s1, inSameDayAs: Date())
                        // true if...
                        // 1.) pill 1 was taken and pill 2 has yet to be taken and is past due OR
                        // 2.) pill 1 has yet to be taken and is past due
                        return (s1Stamped && self.notTakenAndPastDue(correspondingStamp: s2, dueDate: due_t2)) || (!s1Stamped && isInPast(this: due_t1))
                    }
                    // * Have yet to taken second pill ever *
                    else {
                        // The first was stamp was today, so it makes sense to look at second
                        if Calendar.current.isDate(s1, inSameDayAs: Date()) {
                            // true if...
                            // 1.) pill time 2 is past due AND
                            // 2.) the second pill
                            return self.isInPast(this: due_t2)
                        }
                        // It's a new day... no second stamp... look at first again.
                        // true if due time 1 is in the past (already know the stamp is invalid)
                        return self.isInPast(this: due_t1)
                    }
                }
                return false            // shouldn't get here
            }
            // *** User has yet to use the pill feature ***
            else {
                // true if it is past the user-set due time 1
                return self.isInPast(this: due_t1)
            }
        }
        // **** Invalid first due time (should never get here) ****
        return false

    }
    
    static public func resetTB() {
        self.tb_stamps = nil
        self.defaults.set(nil, forKey: PDStrings.userDefaultKeys.tbStamp)
        self.synchonize()
    }
    
    static public func resetPG() {
        self.pg_stamps = nil
        self.defaults.set(nil, forKey: PDStrings.userDefaultKeys.pgStamp)
        self.synchonize()
    }
    
    static public func resetLaterTB() {
        if var stamps = self.tb_stamps {
            if self.tb_daily == 1 || stamps[stamps.count-1] == nil {
                self.resetTB()
            }
            else {
                if stamps.count == 2 {
                    stamps = [stamps[0]]
                    self.tb_stamps = stamps
                    self.defaults.set(stamps as Stamps, forKey: PDStrings.userDefaultKeys.tbStamp)
                }
                else {
                    self.resetTB()
                }
                self.synchonize()
            }
        }
    }
    
    static public func resetLaterPG() {
        if var stamps = self.pg_stamps {
            if self.pg_daily == 1 || stamps[stamps.count-1] == nil {
                self.resetPG()
            }
            else {
                if stamps.count == 2 {
                    stamps = [stamps[0]]
                    self.pg_stamps = stamps
                    self.defaults.set(stamps as Stamps, forKey: PDStrings.userDefaultKeys.pgStamp)
                }
                else {
                    self.resetPG()
                }
                self.synchonize()
            }
        }
    }

    // allStampedToday(stamps) : Returns true of all the stamps were stamped today.
    static public func allStampedToday(stamps: Stamps, timesaday: Int) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        if let stamps = stamps, timesaday == stamps.count {
            return (timesaday == 1) ? calendar.isDate(stamps[0]!, inSameDayAs: now) : calendar.isDate(stamps[0]!, inSameDayAs: now) && calendar.isDate(stamps[1]!, inSameDayAs: now)
        }
        // Gets here if...
        // 1.) not stamps on record
        // 2.) times-a-day scheduled is different than what's in the schedule
        return false
    }
    
    static public func tbIsDone() -> Bool {
        return allStampedToday(stamps: tb_stamps, timesaday: tb_daily)
    }
    
    static public func pgIsDone() -> Bool {
        return allStampedToday(stamps: pg_stamps, timesaday: pg_daily)
    }
    
    static public func tbTakenToday() -> Bool {
        if let s = self.getLaterStamp(stamps: self.tb_stamps) {
            return Calendar.current.isDateInToday(s)
        }
        return false
    }
    
    static public func pgTakenToday() -> Bool {
        if let s = self.getLaterStamp(stamps: self.pg_stamps) {
            return Calendar.current.isDateInToday(s)
        }
        return false
    }
    
    static public func takenToday(stamps: Stamps) -> Bool {
        if let s = self.getLaterStamp(stamps: stamps) {
            return Calendar.current.isDateInToday(s)
        }
        return false
    }
    
    public static func noRecords(stamps: Stamps) -> Bool {
        if let stamps = stamps {
            if stamps.count == 0 || stamps[0] == nil {
                return true
            }
            return false
        }
        return true
    }
    
    static public func tbIsDue() -> Bool {
        return self.isDue(timesaday: self.tb_daily, stamps: self.tb_stamps, time1: self.tb1_time, time2: self.tb2_time)
    }
    
    static public func pgIsDue() -> Bool {
        return self.isDue(timesaday: self.pg_daily, stamps: self.pg_stamps, time1: self.pg1_time, time2: self.pg2_time)
    }
    
    // useSecondTime(timesaday, stamp) : Returns true if...
    // 1.) timesaday == 2
    // 2.) was already stamped at least once today
    static public func useSecondTime(timesaday: Int, stamp: Stamp?) -> Bool {
        if timesaday == 1 { return false }
        if let s: Stamp = stamp {
            return Calendar.current.isDate(s, inSameDayAs: Date())
        }
        return false
    }
    
    static public func getDate(at: Time, daysToAdd: Int) -> Date? {
        let calendar = Calendar.current
        var addComponents = DateComponents()
        addComponents.day = daysToAdd
        if let tom = calendar.date(byAdding: addComponents, to: Date()) {
            let year = calendar.component(.year, from: tom)
            let month = calendar.component(.month, from: tom)
            let day = calendar.component(.day, from: tom)
            let hour = calendar.component(.hour, from: at)
            let min = calendar.component(.minute, from: at)
            let components = DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: year, month: month, day: day, hour: hour, minute: min)
            if let d = calendar.date(from: components) {
                return d
            }
        }
        print("ERROR: Undetermined time.")
        return nil
    }
    
    static public func getTodayDate(at: Time) -> Date? {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        let hour = calendar.component(.hour, from: at)
        let min = calendar.component(.minute, from: at)
        let components = DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: year, month: month, day: day, hour: hour, minute: min)
        if let d = calendar.date(from: components) {
            return d
        }
        print("ERROR: Undetermined time.")
        return nil
    }
    
    // MARK: - TB Loaders
    
    static private func loadIncludeTB() {
        if let i_tb = self.defaults.object(forKey: PDStrings.userDefaultKeys.includeTB) as? Bool {
            self.includeTB = i_tb
        }
        else {
            self.setIncludeTB(to: true)
        }
    }
    
    static private func loadTBDaily() {
        if let tb_x = self.defaults.object(forKey: PDStrings.userDefaultKeys.tbDaily) as? Int {
            self.tb_daily = tb_x
        }
        else {
            self.setTBDaily(to: 1)
        }
    }
    
    static private func loadTB1Time() {
        if let tb_t = self.defaults.object(forKey: PDStrings.userDefaultKeys.tbTime1) as? Time {
            self.tb1_time = tb_t
        }
        else {
            self.setTB1Time(to: Date())
        }
    }
    
    static private func loadTB2time() {
        if let tb_t2 = self.defaults.object(forKey: PDStrings.userDefaultKeys.tbTime2) as? Time {
            self.tb2_time = tb_t2
        }
        else {
            self.setTB2Time(to: Date())
        }
    }
    
    static private func loadTBTaken() {
        if let stamp = self.defaults.object(forKey: PDStrings.userDefaultKeys.tbStamp) as? [Stamp] {
            self.tb_stamps = stamp
        }
    }
    
    static private func loadRemindTB() {
        if let r = self.defaults.object(forKey: PDStrings.userDefaultKeys.remindTB) as? Bool {
            self.remindTB = r
        }
        else {
            self.setRemindTB(to: false)
        }
    }
    
    // MARK: - PG Loaders
    
    static private func loadIncludePG() {
        if let i_pg = self.defaults.object(forKey: PDStrings.userDefaultKeys.includePG) as? Bool {
            self.includePG = i_pg
        }
        else {
            self.setIncludePG(to: true)
        }
    }
    
    static private func loadPGTimesaday() {
        if let pg_x = self.defaults.object(forKey: PDStrings.userDefaultKeys.pgDaily) as? Int {
            self.pg_daily = pg_x
        }
        else {
            self.setPGDaily(to: 1)
        }
    }
    
    static private func loadPG1Time() {
        if let pg_t = self.defaults.object(forKey: PDStrings.userDefaultKeys.pgTime1) as? Time {
            self.pg1_time = pg_t
        }
        else {
            self.setPG1Time(to: Date())
        }
    }
    
    static private func loadPG2time() {
        if let pg_t2 = self.defaults.object(forKey: PDStrings.userDefaultKeys.pgTime2) as? Time {
            self.pg2_time = pg_t2
        }
        else {
            self.setPG2Time(to: Date())
        }
    }
    
    static private func loadPGTaken() {
        if let stamp = self.defaults.object(forKey: PDStrings.userDefaultKeys.pgStamp) as? [Stamp] {
            self.pg_stamps = stamp
        }
    }
    
    static private func loadRemindPG() {
        if let r = self.defaults.object(forKey: PDStrings.userDefaultKeys.remindPG) as? Bool {
            self.remindPG = r
        }
        else {
            self.setRemindPG(to: false)
        }
    }
    
    // MARK: - Private / Helpers
    
    static private func isInPast(this: Date) -> Bool {
        return this < Date()
    }
    
    /******************************************************************************
     notTakenAndPastDue(stamp, dueDate) : Returns true if...
     1.) the pill was not taken yet today AND
     2.) it's past due.
     Is called by isDue(...).
     ******************************************************************************/
    static private func notTakenAndPastDue(correspondingStamp: Stamp, dueDate: Date) -> Bool {
        return !Calendar.current.isDate(correspondingStamp, inSameDayAs: Date()) && self.isInPast(this: dueDate)
    }
}
