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
    
    /***********************************************************
    for button animation algorithm : knowing which buttons to animate when loading ScheduleVC
    ***********************************************************/
    static internal var animateScheduleFromChangeDelivery: Bool = false
    static internal var increasedCount: Bool = false
    static internal var decreasedCount: Bool = false
    static internal var onlyLocationChanged: Bool = false
    static internal var oldDeliveryCount: Int = 1
    static internal var indexOfChangedDelivery: Int = -1
    
    // MARK: - Public
    
    public static func schedule() -> EstrogenSchedule {
        return EstrogenSchedule(estrogens: coreData.mo_array)
    }
    
    /*************************************************************
     ANIMATION ALGORITHM
     *************************************************************/
    public static func shouldAnimateFromCurrentConditions(scheduleIndex: Int, newBG: UIImage) -> Bool {
        
        /* -- Reasons to Animate -- */
        
        var hasDateAndItMatters: Bool = true
        if let mo = coreData.getMO(forIndex: scheduleIndex), mo.hasNoDate() {
            hasDateAndItMatters = false
        }
        
        // 1.) from DETAILS: animate affected non-empty MO dates from changing
        let moreThanLocationChangedFromDetails: Bool = animateScheduleFromChangeDelivery && newBG != PDImages.addPatch  && !onlyLocationChanged && indexOfChangedDelivery <= scheduleIndex && hasDateAndItMatters
        print("animate bool 1: " + String(moreThanLocationChangedFromDetails))
        
        // 2.) from DETAILS: animate the newly changed location and none else (date didn't change)
        let isChangedLocationFromDetails: Bool = onlyLocationChanged && scheduleIndex == indexOfChangedDelivery
        print("animate bool 2: " + String(isChangedLocationFromDetails))
        
        // 3.) from SETTINGS: animate new empty MOs when loading from the changing count
        let indexLessThanOldCountFromSettings: Bool = increasedCount && scheduleIndex >= oldDeliveryCount
        print("animate bool 3: " + String(indexLessThanOldCountFromSettings))

        return (moreThanLocationChangedFromDetails || isChangedLocationFromDetails || indexLessThanOldCountFromSettings)
        
    }


}
