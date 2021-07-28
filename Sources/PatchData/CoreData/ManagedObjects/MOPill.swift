//
//  MOPill.swift
//  PatchData
//
//  Created by Juliya Smith on 7/4/18.

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
    @NSManaged var id: UUID?
    @NSManaged var timesTakenTodayList: String?
    @NSManaged var lastWakeUp: NSDate?

    // Deprecated - only for migration
    @NSManaged var timesaday: Int16
    @NSManaged var time1: NSDate?
    @NSManaged var time2: NSDate?
    @NSManaged var timesTakenToday: Int16
}
