//
//  MOPill.swift
//  PDKit
//
//  Created by Juliya Smith on 7/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//
//

import Foundation
import CoreData

@objc(MOPill)
public class MOPill: NSManagedObject {
    
    public static func < (lhs: MOPill, rhs: MOPill) -> Bool {
        if let l_dueDate = lhs.getDueDate() as Date?, let r_dueDate = rhs.getDueDate() as Date? {
            return l_dueDate < r_dueDate
        }
        return lhs.getLastTaken() != nil
    }
    
    public static func > (lhs: MOPill, rhs: MOPill) -> Bool {
        if let l_dueDate = lhs.getDueDate() as Date?, let r_dueDate = rhs.getDueDate() as Date? {
            return l_dueDate > r_dueDate
        }
        return lhs.getDueDate() == nil
    }
    
    public static func == (lhs: MOPill, rhs: MOPill) -> Bool {
        if let l_dueDate = lhs.getDueDate() as Date?, let r_dueDate = rhs.getDueDate() as Date? {
            return l_dueDate == r_dueDate
        }
        return false
    }
}
