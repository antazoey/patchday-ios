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
        let siteNames = PDSiteStrings.getSiteNames(for: deliveryMethod)
        if (siteNames.contains(siteName)) {
            return stringToImageDict[siteName]!
        } else if siteName != PDSiteStrings.unplaced {
            return custom(theme: theme, deliveryMethod: deliveryMethod)
        }
        return newSiteImage(theme: theme, deliveryMethod: deliveryMethod)
    }
    
    /// Converts patch image to SiteName a.k.a String
    public static func imageToSiteName(_ image: UIImage) -> String {
        let imageToStringDict = [rGlute_p : PDSiteStrings.SiteNames.rightGlute,
                                 rGlute_p_d : PDSiteStrings.SiteNames.rightGlute,
                                 lGlute_p : PDSiteStrings.SiteNames.leftGlute,
                                 lGlute_p_d : PDSiteStrings.SiteNames.leftGlute,
                                 rAbdomen_p : PDSiteStrings.SiteNames.rightAbdomen,
                                 rAbdomen_p_d : PDSiteStrings.SiteNames.rightAbdomen,
                                 lAbdomen_p : PDSiteStrings.SiteNames.leftAbdomen,
                                 lAbdomen_p_d : PDSiteStrings.SiteNames.leftAbdomen,
                                 rGlute_i : PDSiteStrings.SiteNames.rightGlute,
                                 rGlute_i_d : PDSiteStrings.SiteNames.rightGlute,
                                 lGlute_i : PDSiteStrings.SiteNames.leftGlute,
                                 lGlute_i_d : PDSiteStrings.SiteNames.leftGlute,
                                 rQuad_i : PDSiteStrings.SiteNames.rightQuad,
                                 rQuad_i_d : PDSiteStrings.SiteNames.rightQuad,
                                 lQuad_i : PDSiteStrings.SiteNames.leftQuad,
                                 lQuad_i_d : PDSiteStrings.SiteNames.leftQuad,
                                 rDelt_i : PDSiteStrings.SiteNames.rightDelt,
                                 rDelt_i_d : PDSiteStrings.SiteNames.rightDelt,
                                 lDelt_i : PDSiteStrings.SiteNames.leftDelt,
                                 lDelt_i_d : PDSiteStrings.SiteNames.leftDelt]
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

    // MARK: - Private
    
    private static func getStringToImageDict(theme: PDTheme, deliveryMethod: DeliveryMethod) -> Dictionary<String, UIImage> {
        let newImg = newSiteImage(theme: theme, deliveryMethod: .Patches);
        switch (theme, deliveryMethod) {
        case (.Light, .Patches):
            return [PDSiteStrings.unplaced: newImg,
                    PDSiteStrings.SiteNames.rightGlute : rGlute_p,
                    PDSiteStrings.SiteNames.leftGlute : lGlute_p,
                    PDSiteStrings.SiteNames.rightAbdomen : rAbdomen_p,
                    PDSiteStrings.SiteNames.leftAbdomen : lAbdomen_p]
        case (.Dark, .Patches):
            return [PDSiteStrings.unplaced : newImg,
                    PDSiteStrings.SiteNames.rightGlute : rGlute_p_d,
                    PDSiteStrings.SiteNames.leftGlute : lGlute_p_d,
                    PDSiteStrings.SiteNames.rightAbdomen : rAbdomen_p_d,
                    PDSiteStrings.SiteNames.leftAbdomen : lAbdomen_p_d]
        case (.Light, .Injections):
            return [PDSiteStrings.unplaced : newImg,
                    PDSiteStrings.SiteNames.rightGlute : rGlute_i,
                    PDSiteStrings.SiteNames.leftGlute : lGlute_i,
                    PDSiteStrings.SiteNames.leftDelt : lDelt_i,
                    PDSiteStrings.SiteNames.rightDelt : rDelt_i,
                    PDSiteStrings.SiteNames.leftQuad : lQuad_i,
                    PDSiteStrings.SiteNames.rightQuad : rQuad_i]
        case (.Dark, .Injections):
            return [PDSiteStrings.unplaced : newImg,
                    PDSiteStrings.SiteNames.rightGlute : rGlute_i_d,
                    PDSiteStrings.SiteNames.leftGlute : lGlute_i_d,
                    PDSiteStrings.SiteNames.leftDelt : lDelt_i_d,
                    PDSiteStrings.SiteNames.rightDelt : rDelt_i_d,
                    PDSiteStrings.SiteNames.leftQuad : lQuad_i_d,
                    PDSiteStrings.SiteNames.rightQuad : rQuad_i_d]
        }
    }
}
