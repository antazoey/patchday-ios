//
//  PatchDataStringsMO+CoreDataProperties.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/14/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData


extension PatchDataStringsMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PatchDataStringsMO> {
        return NSFetchRequest<PatchDataStringsMO>(entityName: "PatchDataStrings")
    }

    @NSManaged public var patch_a: String?
    @NSManaged public var patch_b: String?
    @NSManaged public var patch_c: String?
    @NSManaged public var patch_d: String?
    
    func getAllData() -> [String] {
        var patchDataStrings = [String]()
        if patch_a != nil {
            patchDataStrings.append(patch_a!)
        }
        if patch_b != nil {
            patchDataStrings.append(patch_b!)
        }
        if patch_c != nil {
            patchDataStrings.append(patch_c!)
        }
        if patch_d != nil {
            patchDataStrings.append(patch_d!)
        }
        return patchDataStrings
    }
}
