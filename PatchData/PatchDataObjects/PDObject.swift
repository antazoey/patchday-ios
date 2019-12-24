//
//  PDObject.swift
//  PatchData
//
//  Created by Juliya Smith on 9/5/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData


public class PDObject {
    
    init(mo: NSManagedObject) {
        self.mo = mo
    }
    
    /// Managed object for Core Data
    var mo: NSManagedObject
    
    /// Delete the object from Core Date.
    public func delete() {
         CoreDataStack.context.delete(mo)
    }
}
