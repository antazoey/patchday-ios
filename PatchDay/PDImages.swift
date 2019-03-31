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
    public static let addPatch: UIImage = { return #imageLiteral(resourceName: "Add Patch") }()
    public static let addInjection: UIImage = { return #imageLiteral(resourceName: "Add Injection")}()
    
    // Patch site images
    public static let rGlute_p: UIImage = { return #imageLiteral(resourceName: "Right Glute") }()
    public static let lGlute_p: UIImage = { return #imageLiteral(resourceName: "Left Glute") }()
    public static let rAbdomen_p: UIImage = { return #imageLiteral(resourceName: "Right Abdomen") }()
    public static let lAbdomen_p: UIImage = { return #imageLiteral(resourceName: "Left Abdomen") }()
    
    // Custom patch
    public static let custom_p: UIImage = { return #imageLiteral(resourceName: "Custom Patch") }()
    public static let custom_i: UIImage = { return #imageLiteral(resourceName: "Custom Injection") }()
    
    // Injection site images
    public static let lQuad_i: UIImage = { return #imageLiteral(resourceName: "Left Quad")}()
    public static let rQuad_i: UIImage = { return #imageLiteral(resourceName: "Right Quad")}()
    public static let lGlute_i: UIImage = { return #imageLiteral(resourceName: "Left Injection Glute")}()
    public static let rGlute_i: UIImage = { return #imageLiteral(resourceName: "Right Injection Glute") }()
    public static let lDelt_i: UIImage = { return #imageLiteral(resourceName: "Left Delt") }()
    public static let rDelt_i: UIImage = { return #imageLiteral(resourceName: "Right Delt") }()
    
    // Pills
    public static let pill: UIImage = { return #imageLiteral(resourceName: "Pill") }()
    
    // Estrogen arrays
    public static let patchImages: [UIImage] =
        { return [rGlute_p, lGlute_p, rAbdomen_p, lAbdomen_p, custom_p] }()
    public static let injectionImages: [UIImage] =
        { return [rQuad_i, lQuad_i, lGlute_i, rGlute_i, lDelt_i, rDelt_i, custom_i] }()
    
    // -------------------------------------------------------------------------------
    
    // MARK: - Functions
    
    public static func isSiteless(_ img: UIImage) -> Bool {
        return img == addPatch || img == addInjection
    }
    
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
        } else if siteName != PDStrings.PlaceholderStrings.unplaced {
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
        } else {
            return PDStrings.PlaceholderStrings.new_site
        }
    }
    
    /// Converts SiteName a.k.a String to injection image.
    public static func siteNameToInjectionImage(_ siteName: String) -> UIImage {
        var r: UIImage = addInjection
        typealias Names = PDStrings.SiteNames
        let unplaced = PDStrings.PlaceholderStrings.unplaced
        let stringToImageDict = [unplaced : addInjection,
                                 Names.rightQuad : rQuad_i,
                                 Names.leftQuad : lQuad_i,
                                 Names.rightGlute : rGlute_i,
                                 Names.leftGlute : lGlute_i,
                                 Names.rightDelt : rDelt_i,
                                 Names.leftDelt : lDelt_i]
        let siteNames = Names.injectionSiteNames
        if (siteNames.contains(siteName)) {
            r = stringToImageDict[siteName]!
        } else if siteName != unplaced {
            r = custom_i
        }
        return r
    }
    
    /// Convert injection image to SiteName a.k. String.
    public static func injectionImageToSiteName(_ image: UIImage) -> String {
        typealias Names = PDStrings.SiteNames
        let imageToStringDict = [rQuad_i : Names.rightQuad,
                                 lQuad_i : Names.leftQuad,
                                 rGlute_i : Names.rightGlute,
                                 lGlute_i : Names.leftGlute,
                                 rDelt_i : Names.rightDelt,
                                 lDelt_i : Names.leftDelt]
        if let name = imageToStringDict[image] {
            return name
        } else {
            return PDStrings.PlaceholderStrings.new_site
        }
    }
    
    /// Returns icons for SitesVC based on site index.
    public static func getSiteIcon(at index: Index) -> UIImage {
        let icons = [#imageLiteral(resourceName: "ES Icon 1"), #imageLiteral(resourceName: "ES Icon 2"), #imageLiteral(resourceName: "ES Icon 3"), #imageLiteral(resourceName: "ES Icon 4")]
        if index >= 0 && index < icons.count {
            return icons[index]
        } else {
            return #imageLiteral(resourceName: "Calendar Icon")
        }
    }
    
    // Original code by Kirit Modi
    // https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift
    /// Resizes an image to the target size.
    public static func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        let newSize: CGSize
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

        return newImage ?? UIImage()
    }
}
