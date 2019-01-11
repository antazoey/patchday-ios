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
public class MOPill: NSManagedObject, Comparable {
    
    // Note: For pills, the logic favors not nil.
    // true: due() > nil
    // true: due () < nil
    // false: nil > due()
    // false: nil < due()
    // this way, nils are always at the end of an array
    
    public static func < (lhs: MOPill, rhs: MOPill) -> Bool {
        let ld = lhs.due()
        let rd = rhs.due()
        switch (ld, rd) {
        case (nil, nil) : return false
        case (nil, _) : return false
        case (_, nil) : return true
        default : return ld! < rd!
        }
    }
    
    public static func > (lhs: MOPill, rhs: MOPill) -> Bool {
        let ld = lhs.due()
        let rd = rhs.due()
        switch (ld, rd) {
        case (nil, nil) : return false
        case (nil, _) : return false
        case (_, nil) : return true
        default : return ld! > rd!
        }
    }
    
    public static func == (lhs: MOPill, rhs: MOPill) -> Bool {
        let ld = lhs.due()
        let rd = rhs.due()
        switch (ld, rd) {
        case (nil, nil) : return true
        case (nil, _) : return false
        case (_, nil) : return false
        default : return ld! == rd!
        }
    }
    public static func != (lhs: MOPill, rhs: MOPill) -> Bool {
        let ld = lhs.due()
        let rd = rhs.due()
        switch (ld, rd) {
        case (nil, nil) : return false
        case (nil, _) : return true
        case (_, nil) : return true
        default : return ld! != rd!
        }
    }
}
