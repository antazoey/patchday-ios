//
//  Patch+CoreDataClass.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/2/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData

@objc(Patch)
public class Patch: NSManagedObject {
    
    // Patch: NSManagedObject is a class for the Managed Object "Patch".  Patch objects are abstractions of patches on the physical body.  They have two attributes: 1.) the date/time when the patch was placed, and 2.), the location where the patch was placed at.  The expiration date of a patch is also important, which is accessible through a Patch.expirationDate() or Patch.expirationDateAsString()

    @NSManaged internal var datePlaced: Date?
    @NSManaged internal var location: String?

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    // Note:  nil dates are > non-nil dates than in this scheme
    
    public static func < (lhs: Patch, rhs: Patch) -> Bool {
        if let l_date = lhs.datePlaced, let r_date = rhs.datePlaced {
            return l_date < r_date
        }
        else if lhs.datePlaced == nil {
            return false
        }
        else {
            return true
        }
    }
    
    public static func > (lhs: Patch, rhs: Patch) -> Bool {
        if let l_date = lhs.datePlaced, let r_date = rhs.datePlaced {
            return l_date > r_date
        }
        else if lhs.datePlaced == nil {
            return true
        }
        else {
            return false
        }
    }
    
    public static func == (lhs: Patch, rhs: Patch) -> Bool {
        if let l_date = lhs.datePlaced, let r_date = rhs.datePlaced {
            return l_date == r_date
        }
        return false
    }
    

}
