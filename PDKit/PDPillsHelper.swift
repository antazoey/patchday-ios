//
//  PillsDelegate.swift
//  PDKit
//
//  Created by Juliya Smith on 6/20/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

public typealias Time = Date
public typealias Stamp = Date
public typealias Stamps = [Stamp?]?

public class PDPillsHelper: NSObject {
    
    // Returns the latest stamp in stamps.
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
    
    // Returns if the pill was taken today.
    public static func wasTakenToday(stamps: Stamps) -> Bool {
        if let s = getLaterStamp(stamps: stamps) {
            return Calendar.current.isDateInToday(s)
        }
        return false
    }
    
    // Returns if the stamps are nil
    public static func noRecords(stamps: Stamps) -> Bool {
        if let stamps = stamps {
            if stamps.count == 0 || stamps[0] == nil {
                return true
            }
            return false
        }
        return true
    }
    
    
    // Returns true if it is time to take a TB or a PG, determined by if the current time is after the time it is due.
    public static func isDue(timesaday: Int, stamps: Stamps, time1: Time, time2: Time) -> Bool {
        
        // **** 1st due time is valid ****
        if let due_t1: Date = PDDateHelper.getTodayDate(at: time1) {
            // *** User took pill at least once historically ***
            if let stamps: [Stamp?] = stamps, stamps.count >= 1, let s1: Stamp = stamps[0] {
                // ** one-a-day **
                if timesaday < 2 {
                    return notTakenAndPastDue(correspondingStamp: s1, dueDate: due_t1)
                }
                    // **** 2nd due time is valid ****
                    // ** two-a-day **
                else if let due_t2: Date = PDDateHelper.getTodayDate(at: time2) {
                    // * Have taken pill at least twice *
                    if stamps.count > 1, let s2: Stamp = stamps[1] {
                        let s1Stamped = Calendar.current.isDate(s1, inSameDayAs: Date())
                        // true if...
                        // 1.) pill 1 was taken and pill 2 has yet to be taken and is past due OR
                        // 2.) pill 1 has yet to be taken and is past due
                        return (s1Stamped && notTakenAndPastDue(correspondingStamp: s2, dueDate: due_t2)) || (!s1Stamped && PDDateHelper.isInPast(this: due_t1))
                    }
                        // * Have yet to taken second pill ever *
                    else {
                        // The first was stamp was today, so it makes sense to look at second
                        if Calendar.current.isDate(s1, inSameDayAs: Date()) {
                            // true if...
                            // 1.) pill time 2 is past due AND
                            // 2.) the second pill
                            return PDDateHelper.isInPast(this: due_t2)
                        }
                        // It's a new day... no second stamp... look at first again.
                        // true if due time 1 is in the past (already know the stamp is invalid)
                        return PDDateHelper.isInPast(this: due_t1)
                    }
                }
                return false            // shouldn't get here
            }
                // *** User has yet to use the pill feature ***
            else {
                // true if it is past the user-set due time 1
                return PDDateHelper.isInPast(this: due_t1)
            }
        }
        // **** Invalid first due time (should never get here) ****
        return false
        
    }
    
    // Returns true if...
    // 1.) timesaday == 2
    // 2.) was already stamped at least once today
    public static func useSecondTime(timesaday: Int, stamp: Stamp?) -> Bool {
        if timesaday == 1 { return false }
        if let s: Stamp = stamp {
            return Calendar.current.isDate(s, inSameDayAs: Date())
        }
        return false
    }
    
    // allStampedToday(stamps) : Returns true of all the stamps were stamped today.
    public static func allStampedToday(stamps: Stamps, timesaday: Int) -> Bool {
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

     /* Returns true if...
     1.) the pill was not taken yet today AND
     2.) it's past due.
     Is called by isDue(...). */
    private static func notTakenAndPastDue(correspondingStamp: Stamp, dueDate: Date) -> Bool {
        return !Calendar.current.isDate(correspondingStamp, inSameDayAs: Date()) && PDDateHelper.isInPast(this: dueDate)
    }
    
}
