//
//  ScheduleController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/13/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData
import UIKit

// MARK: Strings

public class ScheduleController: NSObject {
    
    // ScheduleController is the public accessor class for controlling the app's managed objects.  A PatchDay Managed Object is known as a "Patch" or an "Injection", an abstraction of a patch on the physical body or an injection into the physical body.  The ScheduleController is how the user changes any of their patches or re-injects.  The user may also use the ScheduleController to edit a MOEstrogen object's attributes.  This static class uses a "Schedule" object to work with all of the MOEstrogens together in an array.  Schedule objects are for querying an array of MOEstrogens.
    
    static internal var coreDataController: CoreDataController = CoreDataController()
    
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
    
    public static func estrogenSchedule() -> EstrogenSchedule {
        return EstrogenSchedule(estrogens: coreDataController.estro_array)
    }
    
    public static func siteSchedule() -> SiteSchedule {
        return SiteSchedule(siteScheduleArray: coreDataController.loc_array)
    }
    
    /*
    public static func calculateNextSiteIndex(previousIndex: Int) -> Int {
        return (previousIndex + 1) % ScheduleController.siteSchedule().count
    }
     */
    
    /* Note that if there are duplicate sites in the site schedule,
        this will choose the earlier one. This is meant to be used as an initializer
        when there exist estrogen MOs in the estrogen schedule but UserDefaultController.site_i
        has not been set yet. */
    /*public static func indexOfGreatestCurrentSiteInScheduleSites() -> Int {
        let estroSchedule = self.estrogenSchedule()
        let siteSchedule = self.siteSchedule()
        var index = 0
        for i in 0...(estroSchedule.count-1) {
            
            // If the index of the estro's location in the siteArray is greater
            if i < siteSchedule.count, let estro = coreDataController.getEstrogenDeliveryMO(forIndex: i), let site_i = siteSchedule.siteIndex(forSiteName: estro.getLocation()), site_i > index {
                index = site_i
            }
        }
        return index
    }
 */
 
    /* 1.) Loop throug the Estrogen Delivery MOs
       2.) Get the site index for each Estrogen Delivery getLocation()
       3.) Make sure i is a valid index for the Site Schedule Array
       4.) If site index from step 2 is not equal to i, that means
              we should readjust.
    
    */
    
    /*************************************************************
     ANIMATION ALGORITHM
     *************************************************************/
    public static func shouldAnimate(scheduleIndex: Int, newBG: UIImage) -> Bool {
        
        /* -- Reasons to Animate -- */
        
        var hasDateAndItMatters: Bool = true
        if let mo = coreDataController.getEstrogenDeliveryMO(forIndex: scheduleIndex), mo.hasNoDate() {
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
