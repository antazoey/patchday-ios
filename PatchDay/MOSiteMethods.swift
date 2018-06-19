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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MOSite> {
        return NSFetchRequest<MOSite>(entityName: "Site")
    }

    public func setOrder(to: Int16) {
        self.order = to
    }
    
    public func getOrder() -> Int16 {
        return order
    }
    
    public func setName(to: String) {
        self.name = to
    }
    
    public func getName() -> String? {
        return self.name
    }
    
    public func decrement() {
        if self.order > 0 {
            self.order -= 1
        }
    }
    
    public func reset() {
        self.order = Int16(-1)
        self.name = ""
    }
    
    
    @NSManaged public var name: String?
    @NSManaged public var order: Int16

}
