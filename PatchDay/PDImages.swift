//
//  PDImages.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/3/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

public class PDImages {
    
    // Blank
    public static var addPatch: UIImage = { return #imageLiteral(resourceName: "Add Patch") }()
    public static var addInjection: UIImage = { return #imageLiteral(resourceName: "Add Injection")}()
    
    // Patch site images
    public static var rGlute_p: UIImage = { return #imageLiteral(resourceName: "Right Glute") }()
    public static var lGlute_p: UIImage = { return #imageLiteral(resourceName: "Left Glute") }()
    public static var rAbdomen_p: UIImage = { return #imageLiteral(resourceName: "Right Abdomen") }()
    public static var lAbdomen_p: UIImage = { return #imageLiteral(resourceName: "Left Abdomen") }()
    
    // Custom patch
    public static var custom_p: UIImage = { return #imageLiteral(resourceName: "Custom Patch") }()
    public static var custom_i: UIImage = { return #imageLiteral(resourceName: "Custom Injection") }()
    
    // Injection site images
    public static var lQuad_i: UIImage = { return #imageLiteral(resourceName: "Left Quad")}()
    public static var rQuad_i: UIImage = { return #imageLiteral(resourceName: "Right Quad")}()
    public static var lGlute_i: UIImage = { return #imageLiteral(resourceName: "Left Injection Glute")}()
    public static var rGlute_i: UIImage = { return #imageLiteral(resourceName: "Right Injection Glute") }()
    public static var lDelt_i: UIImage = { return #imageLiteral(resourceName: "Left Delt") }()
    public static var rDelt_i: UIImage = { return #imageLiteral(resourceName: "Right Delt") }()
    
    // Pills
    public static var pill: UIImage = { return #imageLiteral(resourceName: "Pill") }()
    public static var pillDone: UIImage = { return #imageLiteral(resourceName: "Pill Done") }()
    
    public static func stringToPatchImage(imageString: String) -> UIImage {
        var r: UIImage = addPatch
        let stringToImageDict = [PDStrings.PlaceholderStrings.unplaced: addPatch, PDStrings.SiteNames.rightGlute: rGlute_p, PDStrings.SiteNames.leftGlute: lGlute_p, PDStrings.SiteNames.rightAbdomen: rAbdomen_p, PDStrings.SiteNames.leftAbdomen: lAbdomen_p]
        let locs = PDStrings.SiteNames.patchSiteNames
        if (locs.contains(imageString)) {
            r = stringToImageDict[imageString]!
        }
        else if imageString != PDStrings.PlaceholderStrings.unplaced {
            r = custom_p
        }
        return r
    }
    
    public static func stringToInjectionImage(imageString: String) -> UIImage {
        var r: UIImage = addInjection
        let stringToImageDict = [PDStrings.PlaceholderStrings.unplaced: addInjection, PDStrings.SiteNames.rightQuad: rQuad_i, PDStrings.SiteNames.leftQuad: lQuad_i, PDStrings.SiteNames.rightGlute: rGlute_i, PDStrings.SiteNames.leftGlute: lGlute_i, PDStrings.SiteNames.rightDelt: rDelt_i, PDStrings.SiteNames.leftDelt: lDelt_i]
        let locs = PDStrings.SiteNames.injectionSiteNames
        if (locs.contains(imageString)) {
            r = stringToImageDict[imageString]!
        }
        else if imageString !=  PDStrings.PlaceholderStrings.unplaced {
            r = custom_i
        }
        return r
    }

}
