//
//  Patch+CoreDataClass.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/2/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData

@objc(Patch)
public class Patch: NSManagedObject {
    
    @NSManaged public var datePlaced: Date?
    @NSManaged public var location: String?

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

}
