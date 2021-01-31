//
//  MOPill.swift
//  PatchData
//
//  Created by Juliya Smith on 7/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//
//

import Foundation
import CoreData
import PDKit

@objc(MOPill)
public class MOPill: NSManagedObject {
    @NSManaged var expirationInterval: String?
    @NSManaged var lastTaken: NSDate?
    @NSManaged var name: String?
    @NSManaged var notify: Bool
    @NSManaged var xDays: String?
    @NSManaged var times: String?
    @NSManaged var timesaday: Int16
    @NSManaged var timesTakenToday: Int16
    @NSManaged var id: UUID?

    // Deprecated
    @NSManaged var time1: NSDate?
    @NSManaged var time2: NSDate?
}
