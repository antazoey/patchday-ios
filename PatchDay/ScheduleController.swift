//
//  ScheduleController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/13/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData
import UIKit

// MARK: Strings

public class ScheduleController: NSObject {
    
    // ScheduleController is the public accessor class for controlling the app's managed objects.  A PatchDay Managed Object is known as a "Patch" or an "Injection", an abstraction of a patch on the physical body or an injection into the physical body.  The ScheduleController is how the user changes any of their patches or re-injects.  The user may also use the ScheduleController to edit a MOEstrogenDelivery object's attributes.  This static class uses a "Schedule" object to work with all of the MOEstrogenDeliverys together in an array.  Schedule objects are for querying an array of MOEstrogenDeliverys.
    
    static internal var coreData: CoreData = CoreData()
    
    // MARK: - Public
    
    public static func schedule() -> EstrogenSchedule {
        return EstrogenSchedule(estrogens: coreData.mo_array)
    }
    
    public static func getMO(index: Int) -> MOEstrogenDelivery? {
        return coreData.getMO(forIndex: index)
    }
    
    public static func setLocation(scheduleIndex: Int, with: String) {
        coreData.setLocation(scheduleIndex: scheduleIndex, with: with)
        coreData.sortSchedule()
    }
    
    public static func setDate(scheduleIndex: Int, with: Date) {
        coreData.setDate(scheduleIndex: scheduleIndex, with: with)
        coreData.sortSchedule()
    }
    
    public static func setMO(scheduleIndex: Int, date: Date, location: String) {
        coreData.setMO(scheduleIndex: scheduleIndex, date: date, location: location)
        coreData.sortSchedule()
    }
    
    public static func setMO(with: MOEstrogenDelivery, scheduleIndex: Int) {
        coreData.setMO(with: with, scheduleIndex: scheduleIndex)
        coreData.sortSchedule()
    }
    
    public static func resetMO(forIndex: Int) {
        if let mo = getMO(index: forIndex) {
            mo.reset()
        }
    }
    
    public static func resetData() {
        coreData.resetData()
    }

}
