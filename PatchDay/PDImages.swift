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
    static internal var rButt: UIImage = { return #imageLiteral(resourceName: "Right Glute") }()
    static internal var lButt: UIImage = { return #imageLiteral(resourceName: "Left Glute") }()
    static internal var rStom: UIImage = { return #imageLiteral(resourceName: "Right Abdomen") }()
    static internal var lStom: UIImage = { return #imageLiteral(resourceName: "Left Abdomen") }()
    
    // patch locations with notification
    static internal var rButt_notified: UIImage = { return #imageLiteral(resourceName: "Right Glute Notified") }()
    static internal var lButt_notified: UIImage = { return #imageLiteral(resourceName: "Left Glute Notified") }()
    static internal var rStom_notified: UIImage = { return #imageLiteral(resourceName: "Right Abdomen Notified") }()
    static internal var lStom_notified: UIImage = { return #imageLiteral(resourceName: "Left Abdomen Notified") }()
    
    // custom patch
    static internal var custom_patch: UIImage = { return #imageLiteral(resourceName: "Custom Patch") }()
    static internal var custom_patch_notified: UIImage = { return #imageLiteral(resourceName: "Custom Patch Notified") }()
    
    // injection location images
    static internal var lQuad: UIImage = { return #imageLiteral(resourceName: "Left Quad")}()
    static internal var rQuad: UIImage = { return #imageLiteral(resourceName: "Right Quad")}()
    
    // injection locations with notification
    static internal var rQuad_notified: UIImage = { return #imageLiteral(resourceName: "Right Quad Notified")}()
    static internal var lQuad_notified: UIImage = { return #imageLiteral(resourceName: "Left Quad Notified")}()
    
    // custom injection
    static internal var custom_injection: UIImage = { return #imageLiteral(resourceName: "Custom Injection")}()
    static internal var custom_injection_notified: UIImage = { return #imageLiteral(resourceName: "Custom Injection Notified")}()
    
    static internal func stringToImage(imageString: String) -> UIImage {
        var r: UIImage = (UserDefaultsController.getDeliveryMethod() == PDStrings.deliveryMethods[0]) ? self.addPatch : self.addInjection
        let stringToImageDict = [PDStrings.unplaced_string: addPatch, PDStrings.rightButt(): rButt, PDStrings.leftButt(): lButt, PDStrings.rightStom(): rStom, PDStrings.leftStom(): lStom,  PDStrings.leftQuad(): lQuad, PDStrings.rightQuad(): rQuad]
        let locs = (UserDefaultsController.getDeliveryMethod() == PDStrings.deliveryMethods[0]) ? PDStrings.patchLocationNames : PDStrings.injectionLocationNames
        if (locs.contains(imageString)) {
            r = stringToImageDict[imageString]!
        }
        else {
            if (imageString != "unplaced") {
                if r == self.addPatch {
                    return self.custom_patch
                }
                return self.custom_injection
            }
        }
        return r
    }
    
    static internal func stringToNotifiedImage(imageString: String) -> UIImage {
        var r: UIImage = (UserDefaultsController.getDeliveryMethod() == PDStrings.deliveryMethods[0]) ? self.addPatch : self.addInjection
        let stringToImageDict = [PDStrings.unplaced_string: addPatch, PDStrings.rightButt(): rButt_notified, PDStrings.leftButt(): lButt_notified, PDStrings.rightStom(): rStom_notified, PDStrings.leftStom(): lStom_notified, PDStrings.rightQuad(): rQuad_notified, PDStrings.leftQuad(): lQuad_notified]
        let locs = (UserDefaultsController.getDeliveryMethod() == PDStrings.deliveryMethods[0]) ? PDStrings.patchLocationNames : PDStrings.injectionLocationNames
        if (locs.contains(imageString)) {
            r = stringToImageDict[imageString]!
        }
        else {
            if (imageString != "unplaced") {
                if r == self.addPatch {
                    return self.custom_patch
                }
                return self.custom_injection
            }
        }
        return r
    }
}
