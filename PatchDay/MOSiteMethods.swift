//
//  MOSite.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/14/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//
//

import Foundation
import CoreData


extension MOSite {
    
    @NSManaged private var name: String?
    @NSManaged public var order: Int16

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MOSite> {
        return NSFetchRequest<MOSite>(entityName: "Site")
    }

    public func setOrder(to: Int16) {
        order = to
    }
    
    public func getOrder() -> Int16 {
        return order
    }
    
    public func setName(to: String) {
        name = to
    }
    
    public func getName() -> String? {
        return name
    }
    
    public func decrement() {
        if order > 0 {
            order -= 1
        }
    }
    
    public func reset() {
        order = Int16(-1)
        name = ""
    }

}
