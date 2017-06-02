//
//  PatchDataStringsMO+CoreDataClass.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/14/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData


public class PatchDataStringsMO: NSManagedObject {
    
    // var context: NSManagedObjectContext?
    
    // Setters
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    func append(patches: [Patch]) {
        let numberOfPatches = patches.count
        if numberOfPatches > 0 {
            self.patch_a = patches[0].string()
        }
        if numberOfPatches > 1 {
            self.patch_b = patches[1].string()
        }
        if numberOfPatches > 2 {
            self.patch_c = patches[2].string()
        }
        if numberOfPatches == 4 {
            self.patch_d = patches[3].string()
        }
    }
    
    func reset() {
        self.patch_a = "no patch"
        self.patch_b = "no patch"
        self.patch_c = "no patch"
        self.patch_d = "no patch"
    }
    
}


