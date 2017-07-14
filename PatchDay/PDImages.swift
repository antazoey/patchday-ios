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
    
    static func stringToImage(imageString: String) -> UIImage {
        let stringToImageDict = [PDStrings.unplaced_string: addPatch, PDStrings.rightButt(): rButt, PDStrings.leftButt(): lButt, PDStrings.rightStom(): rStom, PDStrings.leftStom(): lStom]
        return stringToImageDict[imageString]!
    }
    
    static func stringToNotifiedImage(imageString: String) -> UIImage {
        let stringToImageDict = [PDStrings.unplaced_string: addPatch, PDStrings.rightButt(): rButt_notified, PDStrings.leftButt(): lButt_notified, PDStrings.rightStom(): rStom_notified, PDStrings.leftStom(): lStom_notified]
        return stringToImageDict[imageString]!
    }
}
