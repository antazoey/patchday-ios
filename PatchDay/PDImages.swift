//
//  PDImages.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/3/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation
import UIKit

class PDImages {
    
    static internal var logo: UIImage = { return #imageLiteral(resourceName: "Logo") }()
    static internal var addPatch: UIImage = { return #imageLiteral(resourceName: "Add Patch") }()
    
    // location images
    static internal var rButt: UIImage = { return #imageLiteral(resourceName: "Right Buttock") }()
    static internal var lButt: UIImage = { return #imageLiteral(resourceName: "Left Buttock") }()
    static internal var rStom: UIImage = { return #imageLiteral(resourceName: "Right Stomach") }()
    static internal var lStom: UIImage = { return #imageLiteral(resourceName: "Left Stomach") }()
    
    // locations with notification
    static internal var rButt_notified: UIImage = { return #imageLiteral(resourceName: "Right Buttock Notified") }()
    static internal var lButt_notified: UIImage = { return #imageLiteral(resourceName: "Left Buttock Notified") }()
    static internal var rStom_notified: UIImage = { return #imageLiteral(resourceName: "Right Stomach Notified") }()
    static internal var lStom_notified: UIImage = { return #imageLiteral(resourceName: "Left Stomach Notified") }()
    
    // custom
    static internal var custom: UIImage = { return #imageLiteral(resourceName: "Custom") }()
    static internal var custom_notified: UIImage = { return #imageLiteral(resourceName: "Custom Notified") }()
    
    static internal func stringToImage(imageString: String) -> UIImage {
        let stringToImageDict = [PDStrings.unplaced_string: addPatch, PDStrings.rightButt(): rButt, PDStrings.leftButt(): lButt, PDStrings.rightStom(): rStom, PDStrings.leftStom(): lStom]
        return stringToImageDict[imageString]!
    }
    
    static internal func stringToNotifiedImage(imageString: String) -> UIImage {
        let stringToImageDict = [PDStrings.unplaced_string: addPatch, PDStrings.rightButt(): rButt_notified, PDStrings.leftButt(): lButt_notified, PDStrings.rightStom(): rStom_notified, PDStrings.leftStom(): lStom_notified]
        return stringToImageDict[imageString]!
    }
}
