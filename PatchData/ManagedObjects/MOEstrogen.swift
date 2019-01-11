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

    // Note: nil is greater than all for MOEstrogens
    
    public static func < (lhs: MOEstrogen, rhs: MOEstrogen) -> Bool {
        switch(lhs.date, rhs.date) {
        case (nil, nil) : return false
        case (nil, _) : return false
        case (_, nil) : return true
        default : return (lhs.date as Date?)! < (rhs.date as Date?)!
        }
    }
    
    public static func > (lhs: MOEstrogen, rhs: MOEstrogen) -> Bool {
        switch(lhs.date, rhs.date) {
        case (nil, nil) : return false
        case (nil, _) : return true
        case (_, nil) : return false
        default : return (lhs.date as Date?)! > (rhs.date as Date?)!
        }
    }
    
    public static func == (lhs: MOEstrogen, rhs: MOEstrogen) -> Bool {
        switch(lhs.date, rhs.date) {
        case (nil, nil) : return true
        case (nil, _) : return false
        case (_, nil) : return false
        default : return (lhs.date as Date?)! == (rhs.date as Date?)!
        }
    }
    
    public static func != (lhs: MOEstrogen, rhs: MOEstrogen) -> Bool {
        switch(lhs.date, rhs.date) {
        case (nil, nil) : return false
        case (nil, _) : return true
        case (_, nil) : return true
        default : return (lhs.date as Date?)! != (rhs.date as Date?)!
        }
    }
}
