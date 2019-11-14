//
//  MOEstrogen.swift
//  PDKit
//
//  Created by Juliya Smith on 7/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//
//

import Foundation
import CoreData
import PDKit

@objc(MOEstrogen)
public class MOHormone: NSManagedObject {
    @NSManaged var siteRelationship: MOSite?
    @NSManaged var id: UUID?
    @NSManaged var date: NSDate?
    @NSManaged var siteNameBackUp: String?
}
