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
    
    var mo: NSManagedObject
    
    public func delete() {
         PatchData.getContext().delete(mo)
    }
}
