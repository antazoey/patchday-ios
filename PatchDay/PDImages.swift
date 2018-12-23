//
//  PDImages.swift
//  PDKit
//
//  Created by Juliya Smith on 6/3/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit
import PatchData

public class PDImages: NSObject {
    
    override public var description: String {
        return "Read-only PatchDay image class."
    }
    
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
    
    // Estrogen arrays
    public static var patchImages: [UIImage] =
        { return [rGlute_p, lGlute_p, rAbdomen_p, lAbdomen_p, custom_p] }()
    public static var injectionImages: [UIImage] =
        { return [rQuad_i, lQuad_i, lGlute_i, rGlute_i, lDelt_i, rDelt_i, custom_i] }()
    
    // -------------------------------------------------------------------------------
    
    // MARK: - Functions
    
    /// Coverts SiteName a.k.a String to corresponding patch image.
    public static func siteNameToPatchImage(_ siteName: SiteName) -> UIImage {
        var r: UIImage = addPatch
        let stringToImageDict = [PDStrings.PlaceholderStrings.unplaced : addPatch,
                                 PDStrings.SiteNames.rightGlute : rGlute_p,
                                 PDStrings.SiteNames.leftGlute : lGlute_p,
                                 PDStrings.SiteNames.rightAbdomen : rAbdomen_p,
                                 PDStrings.SiteNames.leftAbdomen : lAbdomen_p]
        let siteNames = PDStrings.SiteNames.patchSiteNames
        if (siteNames.contains(siteName)) {
            r = stringToImageDict[siteName]!
        }
        else if siteName != PDStrings.PlaceholderStrings.unplaced {
            r = custom_p
        }
        return r
    }
    
    /// Converts patch image to SiteName a.k.a String
    public static func patchImageToSiteName(_ image: UIImage) -> String {
        let imageToStringDict = [rGlute_p : PDStrings.SiteNames.rightGlute,
                                 lGlute_p : PDStrings.SiteNames.leftGlute,
                                 rAbdomen_p : PDStrings.SiteNames.rightAbdomen,
                                 lAbdomen_p : PDStrings.SiteNames.leftAbdomen]
        if let name = imageToStringDict[image] {
            return name
        }
        else {
            return PDStrings.PlaceholderStrings.new_site
        }
    }
    
    /// Converts SiteName a.k.a String to injection image.
    public static func siteNameToInjectionImage(_ siteName: String) -> UIImage {
        var r: UIImage = addInjection
        let stringToImageDict = [PDStrings.PlaceholderStrings.unplaced : addInjection,
                                 PDStrings.SiteNames.rightQuad : rQuad_i,
                                 PDStrings.SiteNames.leftQuad : lQuad_i,
                                 PDStrings.SiteNames.rightGlute : rGlute_i,
                                 PDStrings.SiteNames.leftGlute : lGlute_i,
                                 PDStrings.SiteNames.rightDelt : rDelt_i,
                                 PDStrings.SiteNames.leftDelt : lDelt_i]
        let siteNames = PDStrings.SiteNames.injectionSiteNames
        if (siteNames.contains(siteName)) {
            r = stringToImageDict[siteName]!
        }
        else if siteName !=  PDStrings.PlaceholderStrings.unplaced {
            r = custom_i
        }
        return r
    }
    
    /// Convert injection image to SiteName a.k. String.
    public static func injectionImageToSiteName(_ image: UIImage) -> String {
        let imageToStringDict = [rQuad_i : PDStrings.SiteNames.rightQuad,
                                 lQuad_i : PDStrings.SiteNames.leftQuad,
                                 rGlute_i : PDStrings.SiteNames.rightGlute,
                                 lGlute_i : PDStrings.SiteNames.leftGlute,
                                 rDelt_i : PDStrings.SiteNames.rightDelt,
                                 lDelt_i : PDStrings.SiteNames.leftDelt]
        if let name = imageToStringDict[image] {
            return name
        }
        else {
            return PDStrings.PlaceholderStrings.new_site
        }
    }
    
    /// Returns icons for SitesVC based on site index.
    public static func getSiteIcon(at index: Index) -> UIImage {
        let icons = [#imageLiteral(resourceName: "ES Icon 1"), #imageLiteral(resourceName: "ES Icon 2"), #imageLiteral(resourceName: "ES Icon 3"), #imageLiteral(resourceName: "ES Icon 4")]
        if index >= 0 && index < icons.count {
            return icons[index]
        }
        else { return #imageLiteral(resourceName: "Calendar Icon") }
    }
    
    // Original code by Kirit Modi
    // https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift
    /// Resizes an image to the target size.
    public static func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    

}
