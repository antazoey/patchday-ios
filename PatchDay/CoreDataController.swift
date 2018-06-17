//
//  CoreDataController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/13/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData
import UIKit

// MARK: Strings

public class CoreDataController: NSObject {
    
    // CoreDataController is the public accessor class for controlling the app's managed objects.  A PatchDay Managed Object is known as a "Patch" or an "Injection", an abstraction of a patch on the physical body or an injection into the physical body.  The CoreDataController is how the user changes any of their patches or re-injects.  The user may also use the CoreDataController to edit a MOEstrogenDelivery object's attributes.  This static class uses a "Schedule" object to work with all of the MOEstrogenDeliverys together in an array.  Schedule objects are for querying an array of MOEstrogenDeliverys.
    
    static internal var coreData: CoreData = CoreData()
    
    /***********************************************************
    for button animation algorithm : knowing which buttons to animate when loading ScheduleVC
    ***********************************************************/
    static internal var animateScheduleFromChangeDelivery: Bool = false
    static internal var increasedCount: Bool = false
    static internal var decreasedCount: Bool = false
    static internal var onlySiteChanged: Bool = false
    static internal var deliveryMethodChanged: Bool = false
    static internal var oldDeliveryCount: Int = 1
    static internal var indexOfChangedDelivery: Int = -1
    
    // MARK: - Public
    
    public static func schedule() -> EstrogenSchedule {
        return EstrogenSchedule(estrogens: coreData.estro_array)
    }
    
    public static func sites() -> SiteSchedule {
        return SiteSchedule(siteScheduleArray: coreData.loc_array)
    }
    
    /*************************************************************
     ANIMATION ALGORITHM
     *************************************************************/
    public static func shouldAnimate(scheduleIndex: Int, newBG: UIImage) -> Bool {
        
        /* -- Reasons to Animate -- */
        
        var hasDateAndItMatters: Bool = true
        if let mo = coreData.getEstrogenDeliveryMO(forIndex: scheduleIndex), mo.hasNoDate() {
            hasDateAndItMatters = false
        }
        
        // 1.) from DETAILS: animate affected non-empty MO dates from changing
        let moreThanSiteChangedFromDetails: Bool = animateScheduleFromChangeDelivery && newBG != PDImages.addPatch  && !onlySiteChanged && indexOfChangedDelivery <= scheduleIndex && hasDateAndItMatters
        
        // 2.) from DETAILS: animate the newly changed site and none else (date didn't change)
        let isChangedSiteFromDetails: Bool = onlySiteChanged && scheduleIndex == indexOfChangedDelivery
        
        // 3.) from SETTINGS: animate new empty MOs when loading from the changing count
        let indexLessThanOldCountFromSettings: Bool = (increasedCount && scheduleIndex >= oldDeliveryCount)

        return (moreThanSiteChangedFromDetails || isChangedSiteFromDetails || indexLessThanOldCountFromSettings || deliveryMethodChanged)
        
    }


}
