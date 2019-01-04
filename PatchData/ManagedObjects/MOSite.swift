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
public class MOSite: NSManagedObject {
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        if let context = context {
            super.init(entity: entity, insertInto: context)
        } else {
            fatalError("No Managed Object Context")
        }
    }
    
    public static func < (lhs: MOSite, rhs: MOSite) -> Bool {
        return lhs.order < rhs.order
    }
    
    public static func > (lhs: MOSite, rhs: MOSite) -> Bool {
        return lhs.order > rhs.order
    }
    
    public static func == (lhs: MOSite, rhs: MOSite) -> Bool {
        return lhs.order == rhs.order
    }
    
}
