//
//  MOEstrogenDelivery.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/2/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData

@objc(MOEstrogenDelivery)
public class MOEstrogenDelivery: NSManagedObject {
    
    // Description: MOEstrogenDelivery is a managed object class that represents either a Patch or an Injection.  MOEstrogenDelivery objects are abstractions of patches on the physical body or injections into the body.  They have two attributes: 1.) the date/time placed or injected, and 2.), the site placed or injected.  MOEstrogenDelivery.expirationDate() or MOEstrogenDelivery.expirationDateAsString() are useful in the Schedule.

    @NSManaged internal var datePlaced: Date?
    @NSManaged internal var location: String?

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    // Note:  nil dates are > non-nil dates than in this scheme
    
    public static func < (lhs: MOEstrogenDelivery, rhs: MOEstrogenDelivery) -> Bool {
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
    
    public static func > (lhs: MOEstrogenDelivery, rhs: MOEstrogenDelivery) -> Bool {
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
    
    public static func == (lhs: MOEstrogenDelivery, rhs: MOEstrogenDelivery) -> Bool {
        if let l_date = lhs.datePlaced, let r_date = rhs.datePlaced {
            return l_date == r_date
        }
        return false
    }
    

}
