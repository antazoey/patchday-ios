//
//  PatchDayImages.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/3/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation
import UIKit

class PatchDayImages {
    
    static public var logo: UIImage = { return #imageLiteral(resourceName: "Logo") }()
    static public var addPatch: UIImage = { return #imageLiteral(resourceName: "Add Patch") }()
    
    // location images
    static public var rButt: UIImage = { return #imageLiteral(resourceName: "Right Buttock") }()
    static public var lButt: UIImage = { return #imageLiteral(resourceName: "Left Buttock") }()
    static public var rStom: UIImage = { return #imageLiteral(resourceName: "Right Stomach") }()
    static public var lStom: UIImage = { return #imageLiteral(resourceName: "Left Stomach") }()
    
    // locations with notification
    static public var rButt_notified: UIImage = { return #imageLiteral(resourceName: "Right Buttock Notified") }()
    static public var lButt_notified: UIImage = { return #imageLiteral(resourceName: "Left Buttock Notified") }()
    static public var rStom_notified: UIImage = { return #imageLiteral(resourceName: "Right Stomach Notified") }()
    static public var lStom_notified: UIImage = { return #imageLiteral(resourceName: "Left Stomach Notified") }()
    
    // custom
    static public var custom: UIImage = { return #imageLiteral(resourceName: "Custom") }()
    static public var custom_notified: UIImage = { return #imageLiteral(resourceName: "Custom Notified") }()
    
    // save
    static public var save: UIImage = { return #imageLiteral(resourceName: "Save") }()
    
    static func stringToImage(imageString: String) -> UIImage {
        let stringToImageDict = [PatchDayStrings.unplaced_string: addPatch, PatchDayStrings.rightButt(): rButt, PatchDayStrings.leftButt(): lButt, PatchDayStrings.rightStom(): rStom, PatchDayStrings.leftStom(): lStom]
        return stringToImageDict[imageString]!
    }
    
    static func stringToNotifiedImage(imageString: String) -> UIImage {
        let stringToImageDict = [PatchDayStrings.unplaced_string: addPatch, PatchDayStrings.rightButt(): rButt_notified, PatchDayStrings.leftButt(): lButt_notified, PatchDayStrings.rightStom(): rStom_notified, PatchDayStrings.leftStom(): lStom_notified]
        return stringToImageDict[imageString]!
    }
}
