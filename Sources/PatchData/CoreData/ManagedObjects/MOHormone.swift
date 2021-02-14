//
//  MOHormones.swift
//  PatchData
//
//  Created by Juliya Smith on 7/4/18.
//  
//
//

import Foundation
import CoreData
import PDKit

@objc(MOHormone)
public class MOHormone: NSManagedObject {
    @NSManaged var siteRelationship: MOSite?
    @NSManaged var id: UUID?
    @NSManaged var date: NSDate?
    @NSManaged var siteNameBackUp: String?
}
