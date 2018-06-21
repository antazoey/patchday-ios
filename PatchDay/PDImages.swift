//
//  PDImages.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/3/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import UIKit
import PDKit

class PDImages {
    
    // blank
    internal static var addPatch: UIImage = { return #imageLiteral(resourceName: "Add Patch") }()
    internal static var addInjection: UIImage = { return #imageLiteral(resourceName: "Add Injection")}()
    
    // patch site images
    internal static var rGlute_p: UIImage = { return #imageLiteral(resourceName: "Right Glute") }()
    internal static var lGlute_p: UIImage = { return #imageLiteral(resourceName: "Left Glute") }()
    internal static var rAbdomen_p: UIImage = { return #imageLiteral(resourceName: "Right Abdomen") }()
    internal static var lAbdomen_p: UIImage = { return #imageLiteral(resourceName: "Left Abdomen") }()
    
    // patch sites with notification
    internal static var rGlute_notified_p: UIImage = { return #imageLiteral(resourceName: "Right Glute Notified") }()
    internal static var lGlute_notified_p: UIImage = { return #imageLiteral(resourceName: "Left Glute Notified") }()
    internal static var rAbdomen_notified_p: UIImage = { return #imageLiteral(resourceName: "Right Abdomen Notified") }()
    internal static var lAbdomen_notified_p: UIImage = { return #imageLiteral(resourceName: "Left Abdomen Notified") }()
    
    // custom patch
    internal static var custom_p: UIImage = { return #imageLiteral(resourceName: "Custom Patch") }()
    internal static var custom_notified_p: UIImage = { return #imageLiteral(resourceName: "Custom Patch Notified") }()
    
    // injection site images
    internal static var lQuad_i: UIImage = { return #imageLiteral(resourceName: "Left Quad")}()
    internal static var rQuad_i: UIImage = { return #imageLiteral(resourceName: "Right Quad")}()
    internal static var lGlute_i: UIImage = { return #imageLiteral(resourceName: "Left Injection Glute")}()
    internal static var rGlute_i: UIImage = { return #imageLiteral(resourceName: "Right Injection Glute") }()
    
    // injection sites with notification
    internal static var rQuad_notified_i: UIImage = { return #imageLiteral(resourceName: "Right Quad Notified")}()
    internal static var lQuad_notified_i: UIImage = { return #imageLiteral(resourceName: "Left Quad Notified")}()
    
    // custom injection
    internal static var custom_i: UIImage = { return #imageLiteral(resourceName: "Custom Injection")}()
    internal static var custom_notified_i: UIImage = { return #imageLiteral(resourceName: "Custom Injection Notified")}()
    
    internal static func stringToPatchImage(imageString: String) -> UIImage {
        var r: UIImage = addPatch
        let stringToImageDict = [PDStrings.placeholderStrings.unplaced: addPatch, PDStrings.siteNames.rightGlute: rGlute_p, PDStrings.siteNames.leftGlute: lGlute_p, PDStrings.siteNames.rightAbdomen: rAbdomen_p, PDStrings.siteNames.leftAbdomen: lAbdomen_p]
        let locs = PDStrings.siteNames.patchSiteNames
        if (locs.contains(imageString)) {
            r = stringToImageDict[imageString]!
        }
        else if imageString != "unplaced" {
            r = custom_p
        }
        return r
    }
    
    internal static func stringToNotifiedPatchImage(imageString: String) -> UIImage {
        var r: UIImage = addPatch
        let stringToImageDict = [PDStrings.placeholderStrings.unplaced: addPatch, PDStrings.siteNames.rightGlute: rGlute_notified_p, PDStrings.siteNames.leftGlute: lGlute_notified_p, PDStrings.siteNames.rightAbdomen: rAbdomen_notified_p, PDStrings.siteNames.leftAbdomen: lAbdomen_notified_p]
        let locs = PDStrings.siteNames.patchSiteNames
        if (locs.contains(imageString)) {
            r = stringToImageDict[imageString]!
        }
        else if imageString != "unplaced" {
            r = custom_notified_p
        }
        return r
    }
    
    internal static func stringToInjectionImage(imageString: String) -> UIImage {
        var r: UIImage = addInjection
        let stringToImageDict = [PDStrings.placeholderStrings.unplaced: addInjection, PDStrings.siteNames.rightQuad: rQuad_i, PDStrings.siteNames.leftQuad: lQuad_i, PDStrings.siteNames.rightGlute: rGlute_i, PDStrings.siteNames.leftGlute: lGlute_i]
        let locs = PDStrings.siteNames.injectionSiteNames
        if (locs.contains(imageString)) {
            r = stringToImageDict[imageString]!
        }
        else if imageString != "unplaced" {
            r = custom_i
        }
        return r
    }
    
    internal static func stringToNotifiedInjectionImage(imageString: String) -> UIImage {
        var r: UIImage = addInjection
        let stringToImageDict = [PDStrings.placeholderStrings.unplaced: addInjection, PDStrings.siteNames.rightQuad: rQuad_notified_i, PDStrings.siteNames.leftQuad: lQuad_notified_i]
        let locs = PDStrings.siteNames.injectionSiteNames
        if (locs.contains(imageString)) {
            r = stringToImageDict[imageString]!
        }
        else if imageString != "unplaced" {
            r = custom_notified_i
        }
        return r
    }
}
