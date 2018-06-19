//
//  MOEstrogen.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/2/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData

@objc(MOEstrogen)
public class MOEstrogen: NSManagedObject {
    
    // Description: MOEstrogen is a managed object class that represents either a Patch or an Injection.  MOEstrogen objects are abstractions of patches on the physical body or injections into the body.  They have two attributes: 1.) the date/time placed or injected, and 2.), the site placed or injected.  MOEstrogen.expirationDate() or MOEstrogen.expirationDateAsString() are useful in the Schedule.

    @NSManaged internal var datePlaced: Date?
    @NSManaged internal var location: String?

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    // Note:  nil dates are > non-nil dates than in this scheme
    
    public static func < (lhs: MOEstrogen, rhs: MOEstrogen) -> Bool {
        if let l_date = lhs.datePlaced, let r_date = rhs.datePlaced {
            return l_date < r_date
        }
        return lhs.datePlaced != nil
    }
    
    public static func > (lhs: MOEstrogen, rhs: MOEstrogen) -> Bool {
        if let l_date = lhs.datePlaced, let r_date = rhs.datePlaced {
            return l_date > r_date
        }
        return lhs.datePlaced == nil
    }
    
    public static func == (lhs: MOEstrogen, rhs: MOEstrogen) -> Bool {
        if let l_date = lhs.datePlaced, let r_date = rhs.datePlaced {
            return l_date == r_date
        }
        return false
    }
    

}
