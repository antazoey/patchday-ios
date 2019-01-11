//
//  MOEstrogen.swift
//  PDKit
//
//  Created by Juliya Smith on 7/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//
//

import Foundation
import CoreData

@objc(MOEstrogen)
public class MOEstrogen: NSManagedObject, Comparable {

    public static func < (lhs: MOEstrogen, rhs: MOEstrogen) -> Bool {
        if let l_date = lhs.date as Date? {
            if let r_date = rhs.date as Date? {
                return l_date < r_date
            } else {
                // lhs date is not nil, rhs date is nil
                return false
            }
        } else if let _ = rhs.date {
            // lhs date is nil, rhs date is not nil
            return true
        }
        // both dates nil
        return false
    }
    
    public static func > (lhs: MOEstrogen, rhs: MOEstrogen) -> Bool {
        if let l_date = lhs.date as Date? {
            if let r_date = rhs.date as Date? {
                return l_date > r_date
            } else {
                // lhs date is not nil, rhs date is nil
                return true
            }
        } else if let _ = rhs.date {
            // lhs date is nil, rhs date is not nil
            return false
        }
        // both dates nil
        return false
    }
    
    public static func == (lhs: MOEstrogen, rhs: MOEstrogen) -> Bool {
        if let l_date = lhs.date as Date? {
            if let r_date = rhs.date as Date? {
                return l_date == r_date
            } else {
                // lhs date is not nil
                return false
            }
        } else if let _ = rhs.date {
            // lhs date is nil, rhs date is not nil
            return false
        }
        // both dates nil
        return true
    }
    
    public static func != (lhs: MOEstrogen, rhs: MOEstrogen) -> Bool {
        if let l_date = lhs.date as Date? {
            if let r_date = rhs.date as Date? {
                return l_date != r_date
            } else {
                // lhs date is not nil
                return true
            }
        } else if let _ = rhs.date {
            // lhs date is nil, rhs date is not nil
            return true
        }
        // both dates nil
        return false
    }
}
