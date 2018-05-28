//
//  PDImages.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/3/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import UIKit

class PDImages {
    
    // blank
    static internal var addPatch: UIImage = { return #imageLiteral(resourceName: "Add Patch") }()
    static internal var addInjection: UIImage = { return #imageLiteral(resourceName: "Add Injection")}()
    
    // patch location images
    static internal var rButt: UIImage = { return #imageLiteral(resourceName: "Right Buttock") }()
    static internal var lButt: UIImage = { return #imageLiteral(resourceName: "Left Buttock") }()
    static internal var rStom: UIImage = { return #imageLiteral(resourceName: "Right Stomach") }()
    static internal var lStom: UIImage = { return #imageLiteral(resourceName: "Left Stomach") }()
    
    // patch locations with notification
    static internal var rButt_notified: UIImage = { return #imageLiteral(resourceName: "Right Buttock Notified") }()
    static internal var lButt_notified: UIImage = { return #imageLiteral(resourceName: "Left Buttock Notified") }()
    static internal var rStom_notified: UIImage = { return #imageLiteral(resourceName: "Right Stomach Notified") }()
    static internal var lStom_notified: UIImage = { return #imageLiteral(resourceName: "Left Stomach Notified") }()
    
    // custom patch
    static internal var custom_patch: UIImage = { return #imageLiteral(resourceName: "Custom Patch") }()
    static internal var custom_patch_notified: UIImage = { return #imageLiteral(resourceName: "Custom Patch Notified") }()
    
    // injection location images
    static internal var lThigh: UIImage = { return #imageLiteral(resourceName: "Left Thigh")}()
    static internal var rThigh: UIImage = { return #imageLiteral(resourceName: "Right Thigh")}()
    
    // injection locations with notification
    static internal var rThigh_notified: UIImage = { return #imageLiteral(resourceName: "Right Thigh Notified")}()
    static internal var lThigh_notified: UIImage = { return #imageLiteral(resourceName: "Left Thigh Notified")}()
    
    // custom injection
    static internal var custom_injection: UIImage = { return #imageLiteral(resourceName: "Custom Injection")}()
    static internal var custom_injection_notified: UIImage = { return #imageLiteral(resourceName: "Custom Injection Notified")}()
    
    static internal func stringToImage(imageString: String) -> UIImage {
        let stringToImageDict = [PDStrings.unplaced_string: addPatch, PDStrings.rightButt(): rButt, PDStrings.leftButt(): lButt, PDStrings.rightStom(): rStom, PDStrings.leftStom(): lStom,  PDStrings.leftThigh(): lThigh, PDStrings.rightThigh(): rThigh]
        return stringToImageDict[imageString]!
    }
    
    static internal func stringToNotifiedImage(imageString: String) -> UIImage {
        let stringToImageDict = [PDStrings.unplaced_string: addPatch, PDStrings.rightButt(): rButt_notified, PDStrings.leftButt(): lButt_notified, PDStrings.rightStom(): rStom_notified, PDStrings.leftStom(): lStom_notified, PDStrings.rightThigh(): rThigh_notified, PDStrings.leftThigh(): lThigh_notified]
        return stringToImageDict[imageString]!
    }
}
