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
    public static let addPatch: UIImage = { return UIImage(named: "Add Patch") }()!
    public static let addPatch_d: UIImage = { return UIImage(named: "Add Patch Dark")! }()
    public static var addInjection: UIImage = { return UIImage(named: "Add Injection")! }()
    public static var addInjection_d: UIImage = { return UIImage(named: "Add Injection Dark")! }()
    
    // Patch site images
    public static let rGlute_p: UIImage = { return UIImage(named: "Right Glute")! }()
    public static let rGlute_p_d: UIImage = { return UIImage(named: "Right Glute Dark")! }()
    public static let lGlute_p: UIImage = { return UIImage(named: "Left Glute")! }()
    public static let lGlute_p_d: UIImage = { return UIImage(named: "Left Glute Dark")! }()
    public static let rAbdomen_p: UIImage = { return UIImage(named: "Right Abdomen")! }()
    public static let rAbdomen_p_d: UIImage = { return UIImage(named: "Right Abdomen Dark")! }()
    public static let lAbdomen_p: UIImage = { return UIImage(named: "Left Abdomen")! }()
    public static let lAbdomen_p_d: UIImage = { return UIImage(named: "Left Abdomen Dark")! }()
    public static let custom_p: UIImage = { return UIImage(named: "Custom Patch")! }()
    public static let custom_p_d: UIImage = { return UIImage(named: "Custom Patch Darl")! }()
    
    // Injection site images
    public static let lQuad_i: UIImage = { return UIImage(named: "Left Quad")! }()
    public static let lQuad_i_d: UIImage = { return UIImage(named: "Left Quad Dark")! }()
    public static let rQuad_i: UIImage = { return UIImage(named: "Right Quad")! }()
    public static let rQuad_i_d: UIImage = { return UIImage(named: "Right Quad Dark")! }()
    public static let lGlute_i: UIImage = { return UIImage(named: "Left Injection Glute")! }()
    public static let lGlute_i_d: UIImage = { return UIImage(named: "Left Injection Glute Dark")! }()
    public static let rGlute_i: UIImage = { return UIImage(named: "Right Injection Glute")! }()
    public static let rGlute_i_d: UIImage = { return UIImage(named: "Right Injection Glute Dark")! }()
    public static let lDelt_i: UIImage = { return UIImage(named: "Left Delt")! } ()
    public static let lDelt_i_d: UIImage = { return UIImage(named: "Left Delt Dark")! } ()
    public static let rDelt_i: UIImage = { return UIImage(named: "Right Delt")! }()
    public static let rDelt_i_d: UIImage = { return UIImage(named: "Right Delt Dark")! }()
    public static let custom_i: UIImage = { return UIImage(named: "Custom Injection")! }()
    public static let custom_i_d: UIImage = { return UIImage(named: "Custom Injection Dark")! }()
    
    // Pills
    public static let pill: UIImage = { return #imageLiteral(resourceName: "Pill") }()
    
    public static func siteImages(theme: PDTheme, deliveryMethod: DeliveryMethod) -> [UIImage] {
        switch (theme, deliveryMethod) {
        case (.Light, .Patches):
            return [rGlute_p, lGlute_p, rAbdomen_p, lAbdomen_p, custom_p]
        case (.Dark, .Patches):
            return [rGlute_p_d, lGlute_p_d, rAbdomen_p_d, lAbdomen_p_d, custom_p_d]
        case (.Light, .Injections):
            return [rQuad_i, lQuad_i, lGlute_i, rGlute_i, lDelt_i, rDelt_i, custom_i]
        case (.Dark, .Injections):
            return [rQuad_i_d, lQuad_i_d, lGlute_i_d, rGlute_i_d, lDelt_i_d, rDelt_i_d, custom_i_d]
        }
    }
    
    public static func custom(theme: PDTheme, deliveryMethod: DeliveryMethod) -> UIImage {
        switch (theme, deliveryMethod) {
        case (.Light, .Patches):
            return custom_p
        case (.Dark, .Patches):
            return custom_p_d
        case (.Light, .Injections):
            return custom_i
        case (.Dark, .Injections):
            return custom_i_d
        }
    }
    
    // -------------------------------------------------------------------------------
    
    // MARK: - Functions
    
    public static func newSiteImage(theme: PDTheme, deliveryMethod: DeliveryMethod) -> UIImage {
        switch (theme, deliveryMethod) {
        case (.Dark, .Patches):
            return addPatch_d
        case(.Light, .Patches):
            return addPatch
        case (.Light, .Injections):
            return addInjection
        case (.Dark, .Injections):
            return addInjection_d
        }
    }
    
    public static func isSiteless(_ img: UIImage) -> Bool {
        return img == addPatch || img == addInjection
    }
    
    /// Coverts SiteName a.k.a String to corresponding patch image.
    public static func siteNameToImage(_ siteName: SiteName, theme: PDTheme, deliveryMethod: DeliveryMethod) -> UIImage {
        let stringToImageDict = getStringToImageDict(theme: theme, deliveryMethod: deliveryMethod)
        let siteNames = PDStrings.SiteNames.patchSiteNames
        if (siteNames.contains(siteName)) {
            return stringToImageDict[siteName]!
        } else if siteName != PDStrings.PlaceholderStrings.unplaced {
            return custom(theme: theme, deliveryMethod: deliveryMethod)
        }
        return newSiteImage(theme: theme, deliveryMethod: deliveryMethod)
    }
    
    /// Converts patch image to SiteName a.k.a String
    public static func imageToSiteName(_ image: UIImage) -> String {
        let imageToStringDict = [rGlute_p : PDStrings.SiteNames.rightGlute,
                                 rGlute_p_d : PDStrings.SiteNames.rightGlute,
                                 lGlute_p : PDStrings.SiteNames.leftGlute,
                                 lGlute_p_d : PDStrings.SiteNames.leftGlute,
                                 rAbdomen_p : PDStrings.SiteNames.rightAbdomen,
                                 rAbdomen_p_d : PDStrings.SiteNames.rightAbdomen,
                                 lAbdomen_p : PDStrings.SiteNames.leftAbdomen,
                                 lAbdomen_p_d : PDStrings.SiteNames.leftAbdomen,
                                 rGlute_i : PDStrings.SiteNames.rightGlute,
                                 rGlute_i_d : PDStrings.SiteNames.rightGlute,
                                 lGlute_i : PDStrings.SiteNames.leftGlute,
                                 lGlute_i_d : PDStrings.SiteNames.leftGlute,
                                 rQuad_i : PDStrings.SiteNames.rightQuad,
                                 rQuad_i_d : PDStrings.SiteNames.rightQuad,
                                 lQuad_i : PDStrings.SiteNames.leftQuad,
                                 lQuad_i_d : PDStrings.SiteNames.leftQuad,
                                 rDelt_i : PDStrings.SiteNames.rightDelt,
                                 rDelt_i_d : PDStrings.SiteNames.rightDelt,
                                 lDelt_i : PDStrings.SiteNames.leftDelt,
                                 lDelt_i_d : PDStrings.SiteNames.leftDelt]
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
            let w = size.width * heightRatio
            let h = size.height * heightRatio
            newSize = CGSize(width: w, height: h)
        } else {
            let w = size.width * widthRatio
            let h = size.height * widthRatio
            newSize = CGSize(width: w,  height: h)
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
    

    // MARK: - Private
    
    private static func getStringToImageDict(theme: PDTheme, deliveryMethod: DeliveryMethod) -> Dictionary<String, UIImage> {
        let newImg = newSiteImage(theme: theme, deliveryMethod: .Patches);
        switch (theme, deliveryMethod) {
        case (.Light, .Patches):
            return [PDStrings.PlaceholderStrings.unplaced : newImg,
                    PDStrings.SiteNames.rightGlute : rGlute_p,
                    PDStrings.SiteNames.leftGlute : lGlute_p,
                    PDStrings.SiteNames.rightAbdomen : rAbdomen_p,
                    PDStrings.SiteNames.leftAbdomen : lAbdomen_p]
        case (.Dark, .Patches):
            return [PDStrings.PlaceholderStrings.unplaced : newImg,
                    PDStrings.SiteNames.rightGlute : rGlute_p_d,
                    PDStrings.SiteNames.leftGlute : lGlute_p_d,
                    PDStrings.SiteNames.rightAbdomen : rAbdomen_p_d,
                    PDStrings.SiteNames.leftAbdomen : lAbdomen_p_d]
        case (.Light, .Injections):
            return [PDStrings.PlaceholderStrings.unplaced : newImg,
                    PDStrings.SiteNames.rightGlute : rGlute_i,
                    PDStrings.SiteNames.leftGlute : lGlute_i,
                    PDStrings.SiteNames.leftDelt : lDelt_i,
                    PDStrings.SiteNames.rightDelt : rDelt_i,
                    PDStrings.SiteNames.leftQuad : lQuad_i,
                    PDStrings.SiteNames.rightQuad : rQuad_i]
        case (.Dark, .Injections):
            return [PDStrings.PlaceholderStrings.unplaced : newImg,
                    PDStrings.SiteNames.rightGlute : rGlute_i_d,
                    PDStrings.SiteNames.leftGlute : lGlute_i_d,
                    PDStrings.SiteNames.leftDelt : lDelt_i_d,
                    PDStrings.SiteNames.rightDelt : rDelt_i_d,
                    PDStrings.SiteNames.leftQuad : lQuad_i_d,
                    PDStrings.SiteNames.rightQuad : rQuad_i_d]
        }
    }
}
