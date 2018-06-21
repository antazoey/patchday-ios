//
//  PillDataController.swift
//  PatchDay
//
//  Created by Juliya Smith on 12/28/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class PillDataController: NSObject {
    
    // App
    private static var defaults = UserDefaults.standard
    private static var shareDefaults = UserDefaults.init(suiteName: "group.com.patchday.todaydata")
    
    // TB data
    private static var includeTB: Bool = true       // include t-blocker
    private static var tb_daily: Int = 1            // taken (1 or 2)
    private static var tb1_time: Time = Time()      // 1st time should take
    private static var tb2_time: Time = Time()      // 2nd time should take
    private static var remindTB: Bool = true        // notification?
    
    public static var tb_stamps: Stamps             // last time taken
    
    // PG data
    private static var includePG: Bool = false      // include progesterone
    private static var pg_daily: Int = 1            // taken (1 or 2)
    private static var pg1_time: Time = Time()      // 1st time should take
    private static var pg2_time: Time = Time()      // 2nd time should take
    private static var remindPG: Bool = true        // notification?
    
    public static var pg_stamps: Stamps             // last time taken
    
    public static func setUp() {
        
        // Load TB Data
        loadIncludeTB()
        loadTBDaily()
        loadTB1Time()
        loadTB2time()
        loadTBTaken()
        loadRemindTB()
        
        // Load PGData
        loadIncludePG()
        loadPGTimesaday()
        loadPG1Time()
        loadPG2time()
        loadPGTaken()
        loadRemindPG()
    }
    
    // MARK: - Getters TB
    
    public static func includingTB() -> Bool {
        return includeTB
    }
    
    public static func getTBDailyInt() -> Int {
        return tb_daily
    }
    
    public static func getTBDailyString() -> String {
        return String(tb_daily)
    }
    
    public static func getTB1Time() -> Time {
        return tb1_time
    }
    
    public static func getTB2Time() -> Time {
        return tb2_time
    }

    public static func getRemindTB() -> Bool {
        return remindTB
    }

    // MARK: - Getters PG
    
    public static func includingPG() -> Bool {
        return includePG
    }
    
    public static func getPGDailyInt() -> Int {
        return pg_daily
    }
    
    public static func getPGDailyString() -> String {
        return String(pg_daily)
    }

    public static func getPG1Time() -> Time {
        return pg1_time
    }
    
    public static func getPG2Time() -> Time {
        return pg2_time
    }
    
    public static func getRemindPG() -> Bool {
        return remindPG
    }
    
    // MARK: - TB Setters
    
    public static func setIncludeTB(to: Bool) {
        includeTB = to
        defaults.set(to, forKey: PDStrings.SettingsKey.includeTB.rawValue)
    }
    
    public static func setTBDaily(to: Int) {
        tb_daily = to
        defaults.set(to, forKey: PDStrings.SettingsKey.tbDaily.rawValue)
    }
    
    public static func setTB1Time(to: Time) {
        tb1_time = to
        defaults.set(to, forKey: PDStrings.SettingsKey.tbTime1.rawValue)
    }
    
    public static func setTB2Time(to: Time) {
        tb2_time = to
        defaults.set(to, forKey: PDStrings.SettingsKey.tbTime2.rawValue)
    }
    
    static func setRemindTB(to: Bool) {
        remindTB = to
        defaults.set(to, forKey: PDStrings.SettingsKey.remindTB.rawValue)
    }

    // MARK: - PG Setters
    
    public static func setIncludePG(to: Bool) {
        includePG = to
        defaults.set(to, forKey: PDStrings.SettingsKey.includePG.rawValue)
    }
    
    public static func setPGDaily(to: Int) {
        pg_daily = to
        defaults.set(to, forKey: PDStrings.SettingsKey.pgDaily.rawValue)
    }
    
    public static func setPG1Time(to: Time) {
        pg1_time = to
        defaults.set(to, forKey: PDStrings.SettingsKey.pgTime1.rawValue)
    }
    
    public static func setPG2Time(to: Time) {
        pg2_time = to
        defaults.set(to, forKey: PDStrings.SettingsKey.pgTime2.rawValue)
    }
    
    public static func setRemindPG(to: Bool) {
        remindPG = to
        defaults.set(to, forKey: PDStrings.SettingsKey.remindPG.rawValue)
    }
    
    // MARK: - Other public

    public static func getFrac(mode: String) -> String? {
        let including = (mode == "TB") ? includingTB() : includingPG()
        if !including { return nil }
        else {
            let stamps = (mode == "TB") ? tb_stamps : pg_stamps
            let count = (mode == "TB") ? getTBDailyInt() : getPGDailyInt()
            let takenToday = PDPillsHelper.takenTodayCount(stamps: stamps)
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
        else {
            this = [at]                         // one-a-day or never before
        }
        
        // Saving should always happen
        defaults.set(this, forKey: key)
        
        if key == PDStrings.SettingsKey.tbStamp.rawValue {
            let tbTakenToday = PDPillsHelper.wasTakenToday(stamps: this)
            if let shared = shareDefaults {
                
                shared.set(tbTakenToday, forKey: PDStrings.TodayKeys.tbTaken)
            }
        }
    }
    
    // containsDue() : Returns true if any pill in the schedule needs to be taken (isDue()).
    public static func containsDue() -> Bool {
        return (includeTB && PDPillsHelper.isDue(timesaday: tb_daily, stamps: tb_stamps, time1: tb1_time, time2: tb2_time)) || (includePG && PDPillsHelper.isDue(timesaday: pg_daily, stamps: pg_stamps, time1: pg1_time, time2: pg2_time))
    }
    
    // totalDue() : Returns total number of due pills.
    public static func totalDue() -> Int {
        var total = 0
        if includeTB && PDPillsHelper.isDue(timesaday: tb_daily, stamps: tb_stamps, time1: tb1_time, time2: tb2_time) {
            total += 1
        }
        if includePG && PDPillsHelper.isDue(timesaday: pg_daily, stamps: pg_stamps, time1: pg1_time, time2: pg2_time) {
            total += 1
        }
        return total
    }
    
    public static func resetTB() {
        tb_stamps = nil
        defaults.set(nil, forKey: PDStrings.SettingsKey.tbStamp.rawValue)
    }
    
    public static func resetPG() {
        pg_stamps = nil
        defaults.set(nil, forKey: PDStrings.SettingsKey.pgStamp.rawValue)
    }
    
    public static func resetLaterTB() {
        if var stamps = tb_stamps {
            if tb_daily == 1 || stamps[stamps.count-1] == nil {
                resetTB()
            }
            else {
                if stamps.count == 2 {
                    stamps = [stamps[0]]
                    tb_stamps = stamps
                    defaults.set(stamps as Stamps, forKey: PDStrings.SettingsKey.tbStamp.rawValue)
                }
                else {
                    resetTB()
                }
            }
        }
    }
    
    public static func resetLaterPG() {
        if var stamps = pg_stamps {
            if pg_daily == 1 || stamps[stamps.count-1] == nil {
                resetPG()
            }
            else {
                if stamps.count == 2 {
                    stamps = [stamps[0]]
                    pg_stamps = stamps
                    defaults.set(stamps as Stamps, forKey: PDStrings.SettingsKey.pgStamp.rawValue)
                }
                else {
                    resetPG()
                }
            }
        }
    }

    public static func tbIsDone() -> Bool {
        return PDPillsHelper.allStampedToday(stamps: tb_stamps, timesaday: tb_daily)
    }
    
    public static func pgIsDone() -> Bool {
        return PDPillsHelper.allStampedToday(stamps: pg_stamps, timesaday: pg_daily)
    }
    
    public static func tbTakenToday() -> Bool {
        if let s = PDPillsHelper.getLaterStamp(stamps: tb_stamps) {
            return Calendar.current.isDateInToday(s)
        }
        return false
    }
    
    public static func pgTakenToday() -> Bool {
        if let s = PDPillsHelper.getLaterStamp(stamps: pg_stamps) {
            return Calendar.current.isDateInToday(s)
        }
        return false
    }

    public static func tbIsDue() -> Bool {
        return PDPillsHelper.isDue(timesaday: tb_daily, stamps: tb_stamps, time1: tb1_time, time2: tb2_time)
    }
    
    public static func pgIsDue() -> Bool {
        return PDPillsHelper.isDue(timesaday: pg_daily, stamps: pg_stamps, time1: pg1_time, time2: pg2_time)
    }
    
    // MARK: - TB Loaders
    
    private static func loadIncludeTB() {
        if let i_tb = defaults.object(forKey: PDStrings.SettingsKey.includeTB.rawValue) as? Bool {
            includeTB = i_tb
        }
        else {
            setIncludeTB(to: true)
        }
    }
    
    private static func loadTBDaily() {
        if let tb_x = defaults.object(forKey: PDStrings.SettingsKey.tbDaily.rawValue) as? Int {
            tb_daily = tb_x
        }
        else {
            setTBDaily(to: 1)
        }
    }
    
    private static func loadTB1Time() {
        if let tb_t = defaults.object(forKey: PDStrings.SettingsKey.tbTime1.rawValue) as? Time {
            tb1_time = tb_t
        }
        else {
            setTB1Time(to: Date())
        }
    }
    
    private static func loadTB2time() {
        if let tb_t2 = defaults.object(forKey: PDStrings.SettingsKey.tbTime2.rawValue) as? Time {
            tb2_time = tb_t2
        }
        else {
            setTB2Time(to: Date())
        }
    }
    
    private static func loadTBTaken() {
        if let stamp = defaults.object(forKey: PDStrings.SettingsKey.tbStamp.rawValue) as? [Stamp] {
            tb_stamps = stamp
        }
    }
    
    private static func loadRemindTB() {
        if let r = defaults.object(forKey: PDStrings.SettingsKey.remindTB.rawValue) as? Bool {
            remindTB = r
        }
        else {
            setRemindTB(to: false)
        }
    }
    
    // MARK: - PG Loaders
    
    private static func loadIncludePG() {
        if let i_pg = defaults.object(forKey: PDStrings.SettingsKey.includePG.rawValue) as? Bool {
            includePG = i_pg
        }
        else {
            setIncludePG(to: true)
        }
    }
    
    private static func loadPGTimesaday() {
        if let pg_x = defaults.object(forKey: PDStrings.SettingsKey.pgDaily.rawValue) as? Int {
            pg_daily = pg_x
        }
        else {
            setPGDaily(to: 1)
        }
    }
    
    private static func loadPG1Time() {
        if let pg_t = defaults.object(forKey: PDStrings.SettingsKey.pgTime1.rawValue) as? Time {
            pg1_time = pg_t
        }
        else {
            setPG1Time(to: Date())
        }
    }
    
    private static func loadPG2time() {
        if let pg_t2 = defaults.object(forKey: PDStrings.SettingsKey.pgTime2.rawValue) as? Time {
            pg2_time = pg_t2
        }
        else {
            setPG2Time(to: Date())
        }
    }
    
    private static func loadPGTaken() {
        if let stamp = defaults.object(forKey: PDStrings.SettingsKey.pgStamp.rawValue) as? [Stamp] {
            pg_stamps = stamp
        }
    }
    
    private static func loadRemindPG() {
        if let r = defaults.object(forKey: PDStrings.SettingsKey.remindPG.rawValue) as? Bool {
            remindPG = r
        }
        else {
            setRemindPG(to: false)
        }
    }

}
