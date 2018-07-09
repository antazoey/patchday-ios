//
//  MOOldEstro+CoreDataProperties.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/8/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//
//

import Foundation
import CoreData


extension MOOldEstro {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MOOldEstro> {
        return NSFetchRequest<MOOldEstro>(entityName: "PatchA")
    }

    @NSManaged public var datePlaced: NSDate?
    @NSManaged public var location: String?

}
