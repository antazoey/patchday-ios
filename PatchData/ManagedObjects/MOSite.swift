//
//  MOSite.swift
//  PDkit
//
//  Created by Juliya Smith on 6/14/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//
//

import Foundation
import CoreData

public typealias SiteName = String

@objc(MOSite)
public class MOSite: NSManagedObject, Comparable {
    
/* Note: In MOSites, we want negative orders and nil orders
        to be at the end of a sort, then negative orders are > positive orders
     and I know that sounds weird, but we are kind of backwards here at PatchDay Inc.
 */
    
    public static func < (lhs: MOSite, rhs: MOSite) -> Bool {
        switch(lhs.order, rhs.order) {
        // both not set
        case (nil, nil) : return false
        case (let neg1, let neg2) where neg1 < 0 && neg2 < 0 : return false
        case (nil, let neg) where neg < 0 : return false
        case (let neg, nil) where neg < 0 : return false
            
        // left field not set
        case (nil, _) : return false
        case (let neg, _) where neg < 0 : return false

        // right field not set
        case (_, nil) : return true
        case (_, let neg) where neg < 0 : return true

        // both fields sets
        default : return lhs.order < rhs.order
        }
    }
    
    public static func > (lhs: MOSite, rhs: MOSite) -> Bool {
        switch(lhs.order, rhs.order) {
        // both not set
        case (nil, nil) : return false
        case (let neg1, let neg2) where neg1 < 0 && neg2 < 0 : return false
        case (nil, let neg) where neg < 0 : return false
        case (let neg, nil) where neg < 0 : return false
            
        // left field not set
        case (nil, _) : return true
        case (let neg, _) where neg < 0 : return true
            
        // right field not set
        case (_, nil) : return false
        case (_, let neg) where neg < 0 : return false
            
        // both fields sets
        default : return lhs.order > rhs.order
        }
    }
    
    public static func == (lhs: MOSite, rhs: MOSite) -> Bool {
        switch(lhs.order, rhs.order) {
        // both not set
        case (nil, nil) : return true
        case (let neg1, let neg2) where neg1 < 0 && neg2 < 0 : return true
        case (nil, let neg) where neg < 0 : return true
        case (let neg, nil) where neg < 0 : return true
            
        // left field not set
        case (nil, _) : return false
        case (let neg, _) where neg < 0 : return false
            
        // right field not set
        case (_, nil) : return false
        case (_, let neg) where neg < 0 : return false
            
        // both fields sets
        default : return lhs.order == rhs.order
        }
    }
    
    public static func != (lhs: MOSite, rhs: MOSite) -> Bool {
        switch(lhs.order, rhs.order) {
        // both not set
        case (nil, nil) : return false
        case (let neg1, let neg2) where neg1 < 0 && neg2 < 0 : return false
        case (nil, let neg) where neg < 0 : return false
        case (let neg, nil) where neg < 0 : return false
            
        // left field not set
        case (nil, _) : return true
        case (let neg, _) where neg < 0 : return true
            
        // right field not set
        case (_, nil) : return true
        case (_, let neg) where neg < 0 : return true
            
        // both fields sets
        default : return lhs.order != rhs.order
        }
    }
}
