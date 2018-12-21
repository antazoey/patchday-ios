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
public class MOEstrogen: NSManagedObject {
    public static func < (lhs: MOEstrogen, rhs: MOEstrogen) -> Bool {
        if let l_date = lhs.date as Date?, let r_date = rhs.date as Date? {
            return l_date < r_date
        }
        return lhs.date != nil
    }
    
    public static func > (lhs: MOEstrogen, rhs: MOEstrogen) -> Bool {
        if let l_date = lhs.date as Date?, let r_date = rhs.date as Date? {
            return l_date > r_date
        }
        return lhs.date == nil
    }
    
    public static func == (lhs: MOEstrogen, rhs: MOEstrogen) -> Bool {
        if let l_date = lhs.date as Date?, let r_date = rhs.date as Date? {
            return l_date == r_date
        }
        return false
    }
}
