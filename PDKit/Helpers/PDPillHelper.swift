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
    
    public enum NextDueDateError: Error {
        case notEnoughTimes
    }
    
    /// Return the next time the pill is due.
    public static func nextDueDate(timesTakenToday: Int, timesaday: Int, times: [Time]) throws -> Date? {
        // Error with times
        if times.count == 0 || times.count < timesaday {
            throw NextDueDateError.notEnoughTimes
        }
        
        let times_today = min(timesTakenToday, timesaday)
        
        // Not yet taken today
        if times_today == 0 {
            return PDDateHelper.getDate(on: Date(), at: times.sorted()[0])
        }
        
        // Taken completely today
        if times_today == timesaday {
            return PDDateHelper.getDate(at: times.sorted()[0], daysFromNow: 1)
        }
        
        // All other times
        return PDDateHelper.getDate(on: Date(), at: times.sorted()[times_today])
    }
    
    /// Return if the pill has been taken all of its times today.
    public static func isDone(timesTakenToday: Int, timesaday: Int) -> Bool {
        return timesTakenToday >= timesaday
    }

}
