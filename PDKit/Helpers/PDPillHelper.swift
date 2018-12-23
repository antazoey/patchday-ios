//
//  PDPillsHelper.swift
//  PDKit
//
//  Created by Juliya Smith on 6/20/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

public typealias Stamp = Date
public typealias Stamps = [Stamp?]?

public class PDPillHelper: NSObject {

    override public var description: String {
        return "Class for doing calculations on MOPill attributes."
    }
    
    /// Return the next time the pill is due.
    public static func nextDueDate(timesTakenToday: Int, timesaday: Int, times: [NSDate?]) -> Date? {
        if times.count > 0, let time1 = times[0] as Time? {
            // One-a-day, either due today or tomorrow
            if timesaday == 1 {
                if timesTakenToday == 0 {
                    return PDDateHelper.getDate(on: Date(), at: time1)
                } else if let todayTime = PDDateHelper.getDate(on: Date(), at: time1) {
                    return PDDateHelper.getDate(at: todayTime, daysToAdd: 1)
                }
            }
            // Two-a-day, figure out if it's time 1 or 2, or if tomorrow
            else if times.count >= 1, let time2 = times[1] as Time? {
                if timesTakenToday == 0 {
                    let minTime = min(time1, time2)
                    return PDDateHelper.getDate(on: Date(), at: minTime)
                } else if timesTakenToday == 1 {
                    let maxTime = max(time1, time2)
                    return PDDateHelper.getDate(on: Date(), at: maxTime)
                } else {
                    let minTime = min(time1, time2)
                    if let todayTime = PDDateHelper.getDate(on: Date(), at: minTime) {
                        return PDDateHelper.getDate(at: todayTime, daysToAdd: 1)
                    }
                }
            }
        }
        return nil
    }
    
    /// Return if the pill has been taken all of its times today.
    public static func isDone(timesTakenToday: Int, timesaday: Int) -> Bool {
        return timesTakenToday >= timesaday
    }

}
