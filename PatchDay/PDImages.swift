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
    
    // patch site images
    static internal var rGlute_p: UIImage = { return #imageLiteral(resourceName: "Right Glute") }()
    static internal var lGlute_p: UIImage = { return #imageLiteral(resourceName: "Left Glute") }()
    static internal var rAbdomen_p: UIImage = { return #imageLiteral(resourceName: "Right Abdomen") }()
    static internal var lAbdomen_p: UIImage = { return #imageLiteral(resourceName: "Left Abdomen") }()
    
    // patch sites with notification
    static internal var rGlute_notified_p: UIImage = { return #imageLiteral(resourceName: "Right Glute Notified") }()
    static internal var lGlute_notified_p: UIImage = { return #imageLiteral(resourceName: "Left Glute Notified") }()
    static internal var rAbdomen_notified_p: UIImage = { return #imageLiteral(resourceName: "Right Abdomen Notified") }()
    static internal var lAbdomen_notified_p: UIImage = { return #imageLiteral(resourceName: "Left Abdomen Notified") }()
    
    // custom patch
    static internal var custom_p: UIImage = { return #imageLiteral(resourceName: "Custom Patch") }()
    static internal var custom_notified_p: UIImage = { return #imageLiteral(resourceName: "Custom Patch Notified") }()
    
    // injection site images
    static internal var lQuad_i: UIImage = { return #imageLiteral(resourceName: "Left Quad")}()
    static internal var rQuad_i: UIImage = { return #imageLiteral(resourceName: "Right Quad")}()
    static internal var lGlute_i: UIImage = { return #imageLiteral(resourceName: "Left Injection Glute")}()
    static internal var rGlute_i: UIImage = { return #imageLiteral(resourceName: "Right Injection Glute") }()
    
    // injection sites with notification
    static internal var rQuad_notified_i: UIImage = { return #imageLiteral(resourceName: "Right Quad Notified")}()
    static internal var lQuad_notified_i: UIImage = { return #imageLiteral(resourceName: "Left Quad Notified")}()
    
    // custom injection
    static internal var custom_i: UIImage = { return #imageLiteral(resourceName: "Custom Injection")}()
    static internal var custom_notified_i: UIImage = { return #imageLiteral(resourceName: "Custom Injection Notified")}()
    
    static internal func stringToPatchImage(imageString: String) -> UIImage {
        var r: UIImage = self.addPatch
        let stringToImageDict = [PDStrings.placeholderStrings.unplaced: addPatch, PDStrings.siteNames.rightGlute: rGlute_p, PDStrings.siteNames.leftGlute: lGlute_p, PDStrings.siteNames.rightAbdomen: rAbdomen_p, PDStrings.siteNames.leftAbdomen: lAbdomen_p]
        let locs = PDStrings.siteNames.patchSiteNames
        if (locs.contains(imageString)) {
            r = stringToImageDict[imageString]!
        }
        else if imageString != "unplaced" {
            r = self.custom_p
        }
        return r
    }
    
    static internal func stringToNotifiedPatchImage(imageString: String) -> UIImage {
        var r: UIImage = self.addPatch
        let stringToImageDict = [PDStrings.placeholderStrings.unplaced: addPatch, PDStrings.siteNames.rightGlute: rGlute_notified_p, PDStrings.siteNames.leftGlute: lGlute_notified_p, PDStrings.siteNames.rightAbdomen: rAbdomen_notified_p, PDStrings.siteNames.leftAbdomen: lAbdomen_notified_p]
        let locs = PDStrings.siteNames.patchSiteNames
        if (locs.contains(imageString)) {
            r = stringToImageDict[imageString]!
        }
        else if imageString != "unplaced" {
            r = self.custom_notified_p
        }
        return r
    }
    
    static internal func stringToInjectionImage(imageString: String) -> UIImage {
        var r: UIImage = self.addInjection
        let stringToImageDict = [PDStrings.placeholderStrings.unplaced: addInjection, PDStrings.siteNames.rightQuad: rQuad_i, PDStrings.siteNames.leftQuad: lQuad_i, PDStrings.siteNames.rightGlute: self.rGlute_i, PDStrings.siteNames.leftGlute: self.lGlute_i]
        let locs = PDStrings.siteNames.injectionSiteNames
        if (locs.contains(imageString)) {
            r = stringToImageDict[imageString]!
        }
        else if imageString != "unplaced" {
            r = self.custom_i
        }
        return r
    }
    
    static internal func stringToNotifiedInjectionImage(imageString: String) -> UIImage {
        var r: UIImage = self.addInjection
        let stringToImageDict = [PDStrings.placeholderStrings.unplaced: addInjection, PDStrings.siteNames.rightQuad: rQuad_notified_i, PDStrings.siteNames.leftQuad: lQuad_notified_i]
        let locs = PDStrings.siteNames.injectionSiteNames
        if (locs.contains(imageString)) {
            r = stringToImageDict[imageString]!
        }
        else if imageString != "unplaced" {
            r = self.custom_notified_i
        }
        return r
    }
}
