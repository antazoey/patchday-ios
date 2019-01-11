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
    
    public static func < (lhs: MOSite, rhs: MOSite) -> Bool {
        switch(lhs.order, rhs.order) {
        case (nil, nil) : return false
        case (nil, _) : return false
        case (_, nil) : return true
        default : return lhs.order < rhs.order
        }
    }
    
    public static func > (lhs: MOSite, rhs: MOSite) -> Bool {
        switch(lhs.order, rhs.order) {
        case (nil, nil) : return false
        case (nil, _) : return true
        case (_, nil) : return false
        default : return lhs.order > rhs.order
        }
    }
    
    public static func == (lhs: MOSite, rhs: MOSite) -> Bool {
        switch(lhs.order, rhs.order) {
        case (nil, nil) : return true
        case (nil, _) : return false
        case (_, nil) : return false
        default : return lhs.order == rhs.order
        }
    }
    
    public static func != (lhs: MOSite, rhs: MOSite) -> Bool {
        switch(lhs.order, rhs.order) {
        case (nil, nil) : return false
        case (nil, _) : return true
        case (_, nil) : return true
        default : return lhs.order != rhs.order
        }
    }
}
