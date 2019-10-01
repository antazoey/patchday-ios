//
//  PDImages.swift
//  PDKit
//
//  Created by Juliya Smith on 6/3/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

public class PDImages: NSObject {
    
    override public var description: String {
        return "Read-only PatchDay image class."
    }
    
    // Cerebral
    public static let cerebralPatch: UIImage = { return UIImage(named: "Add Patch") }()!
    public static let darkCerebralPatch: UIImage = { return UIImage(named: "Add Patch Dark")! }()
    public static var cerebralInjection: UIImage = { return UIImage(named: "Add Injection")! }()
    public static var darkCerebralInjection: UIImage = { return UIImage(named: "Add Injection Dark")! }()
    
    // Patch site images
    public static let patchRightGlute: UIImage = { return UIImage(named: "Right Glute")! }()
    public static let darkPatchRightGlute: UIImage = { return UIImage(named: "Right Glute Dark")! }()
    public static let patchLeftGlute: UIImage = { return UIImage(named: "Left Glute")! }()
    public static let darkPatchLeftGlute: UIImage = { return UIImage(named: "Left Glute Dark")! }()
    public static let patchRightAbdomen: UIImage = { return UIImage(named: "Right Abdomen")! }()
    public static let darkPatchRightAbdomen: UIImage = { return UIImage(named: "Right Abdomen Dark")! }()
    public static let patchLeftAbdomen: UIImage = { return UIImage(named: "Left Abdomen")! }()
    public static let darkPatchLeftAbdomen: UIImage = { return UIImage(named: "Left Abdomen Dark")! }()
    public static let customPatch: UIImage = { return UIImage(named: "Custom Patch")! }()
    public static let darkCustomPatch: UIImage = { return UIImage(named: "Custom Patch Darl")! }()
    
    // Injection site images
    public static let injectionLeftQuad: UIImage = { return UIImage(named: "Left Quad")! }()
    public static let darkInjectionLeftQuad: UIImage = { return UIImage(named: "Left Quad Dark")! }()
    public static let injectionRightQuad: UIImage = { return UIImage(named: "Right Quad")! }()
    public static let darkInjectionRightQuad: UIImage = { return UIImage(named: "Right Quad Dark")! }()
    public static let injectionLeftGlute: UIImage = { return UIImage(named: "Left Injection Glute")! }()
    public static let darkInjectionLeftGlute: UIImage = { return UIImage(named: "Left Injection Glute Dark")! }()
    public static let injectionGluteRight: UIImage = { return UIImage(named: "Right Injection Glute")! }()
    public static let darkInjectionGluteRight: UIImage = { return UIImage(named: "Right Injection Glute Dark")! }()
    public static let injectionLeftDelt: UIImage = { return UIImage(named: "Left Delt")! } ()
    public static let darkInjectionLeftDelt: UIImage = { return UIImage(named: "Left Delt Dark")! } ()
    public static let injectionRightDelt: UIImage = { return UIImage(named: "Right Delt")! }()
    public static let darkInjectionRightDelt: UIImage = { return UIImage(named: "Right Delt Dark")! }()
    public static let customInjection: UIImage = { return UIImage(named: "Custom Injection")! }()
    public static let darkCustomInjection: UIImage = { return UIImage(named: "Custom Injection Dark")! }()
    
    // Pills
    public static let pill: UIImage = { return #imageLiteral(resourceName: "Pill") }()
    
    public static func siteImages(theme: PDTheme, deliveryMethod: DeliveryMethod) -> [UIImage] {
        switch (theme, deliveryMethod) {
        case (.Light, .Patches):
            return [patchRightGlute, patchLeftGlute, patchRightAbdomen, patchLeftAbdomen, customPatch]
        case (.Dark, .Patches):
            return [darkPatchRightGlute, darkPatchLeftGlute, darkPatchRightAbdomen, darkPatchLeftAbdomen, darkCustomPatch]
        case (.Light, .Injections):
            return [injectionRightQuad, injectionLeftQuad, injectionLeftGlute, injectionGluteRight, injectionLeftDelt, injectionRightDelt, customInjection]
        case (.Dark, .Injections):
            return [darkInjectionRightQuad, darkInjectionLeftQuad, darkInjectionLeftGlute, darkInjectionGluteRight, darkInjectionLeftDelt, darkInjectionRightDelt, darkCustomInjection]
        }
    }
    
    public static func getCustomHormoneImage(theme: PDTheme, deliveryMethod: DeliveryMethod) -> UIImage {
        switch (theme, deliveryMethod) {
        case (.Light, .Patches):
            return customPatch
        case (.Dark, .Patches):
            return darkCustomPatch
        case (.Light, .Injections):
            return customInjection
        case (.Dark, .Injections):
            return darkCustomInjection
        }
    }
    
    // -------------------------------------------------------------------------------
    
    // MARK: - Functions
    
    public static func getCerebralHormoneImage(theme: PDTheme, deliveryMethod: DeliveryMethod) -> UIImage {
        switch (theme, deliveryMethod) {
        case (.Dark, .Patches):
            return darkCerebralPatch
        case(.Light, .Patches):
            return cerebralPatch
        case (.Light, .Injections):
            return cerebralInjection
        case (.Dark, .Injections):
            return darkCerebralInjection
        }
    }
    
    public static func representsEstrogenLess(_ img: UIImage) -> Bool {
        return img == cerebralPatch || img == cerebralInjection
    }
    
    /// Coverts SiteName a.k.a String to corresponding patch image.
    public static func siteNameToImage(_ siteName: SiteName, theme: PDTheme, deliveryMethod: DeliveryMethod) -> UIImage {
        let stringToImageDict = getStringToImageDict(theme: theme, deliveryMethod: deliveryMethod)
        let siteNames = PDSiteStrings.getSiteNames(for: deliveryMethod)
        if (siteNames.contains(siteName)) {
            return stringToImageDict[siteName]!
        } else if siteName != PDSiteStrings.unplaced {
            return getCustomHormoneImage(theme: theme, deliveryMethod: deliveryMethod)
        }
        return getCerebralHormoneImage(theme: theme, deliveryMethod: deliveryMethod)
    }
    
    /// Converts patch image to SiteName a.k.a String
    public static func imageToSiteName(_ image: UIImage) -> String {
        let imageToStringDict = [patchRightGlute : PDSiteStrings.SiteNames.rightGlute,
                                 darkPatchRightGlute : PDSiteStrings.SiteNames.rightGlute,
                                 patchLeftGlute : PDSiteStrings.SiteNames.leftGlute,
                                 darkPatchLeftGlute : PDSiteStrings.SiteNames.leftGlute,
                                 patchRightAbdomen : PDSiteStrings.SiteNames.rightAbdomen,
                                 darkPatchRightAbdomen : PDSiteStrings.SiteNames.rightAbdomen,
                                 patchLeftAbdomen : PDSiteStrings.SiteNames.leftAbdomen,
                                 darkPatchLeftAbdomen : PDSiteStrings.SiteNames.leftAbdomen,
                                 injectionGluteRight : PDSiteStrings.SiteNames.rightGlute,
                                 darkInjectionGluteRight : PDSiteStrings.SiteNames.rightGlute,
                                 injectionLeftGlute : PDSiteStrings.SiteNames.leftGlute,
                                 darkInjectionLeftGlute : PDSiteStrings.SiteNames.leftGlute,
                                 injectionRightQuad : PDSiteStrings.SiteNames.rightQuad,
                                 darkInjectionRightQuad : PDSiteStrings.SiteNames.rightQuad,
                                 injectionLeftQuad : PDSiteStrings.SiteNames.leftQuad,
                                 darkInjectionLeftQuad : PDSiteStrings.SiteNames.leftQuad,
                                 injectionRightDelt : PDSiteStrings.SiteNames.rightDelt,
                                 darkInjectionRightDelt : PDSiteStrings.SiteNames.rightDelt,
                                 injectionLeftDelt : PDSiteStrings.SiteNames.leftDelt,
                                 darkInjectionLeftDelt : PDSiteStrings.SiteNames.leftDelt]
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
    
    public static func getImage(for hormone: Hormonal, theme: PDTheme, deliveryMethod: DeliveryMethod) -> UIImage {
        if !hormone.isEmpty {
            if let siteName = hormone.site?.name {
                return siteNameToImage(siteName, theme: theme, deliveryMethod: deliveryMethod)
            } else {
                return getCustomHormoneImage(theme: theme, deliveryMethod: deliveryMethod)
            }
        } else {
            return getCerebralHormoneImage(theme: theme, deliveryMethod: deliveryMethod)
        }
    }

    // MARK: - Private
    
    private static func getStringToImageDict(theme: PDTheme, deliveryMethod: DeliveryMethod) -> Dictionary<String, UIImage> {
        let newImg = getCerebralHormoneImage(theme: theme, deliveryMethod: .Patches);
        switch (theme, deliveryMethod) {
        case (.Light, .Patches):
            return [PDSiteStrings.unplaced: newImg,
                    PDSiteStrings.SiteNames.rightGlute : patchRightGlute,
                    PDSiteStrings.SiteNames.leftGlute : patchLeftGlute,
                    PDSiteStrings.SiteNames.rightAbdomen : patchRightAbdomen,
                    PDSiteStrings.SiteNames.leftAbdomen : patchLeftAbdomen]
        case (.Dark, .Patches):
            return [PDSiteStrings.unplaced : newImg,
                    PDSiteStrings.SiteNames.rightGlute : darkPatchRightGlute,
                    PDSiteStrings.SiteNames.leftGlute : darkPatchLeftGlute,
                    PDSiteStrings.SiteNames.rightAbdomen : darkPatchRightAbdomen,
                    PDSiteStrings.SiteNames.leftAbdomen : darkPatchLeftAbdomen]
        case (.Light, .Injections):
            return [PDSiteStrings.unplaced : newImg,
                    PDSiteStrings.SiteNames.rightGlute : injectionGluteRight,
                    PDSiteStrings.SiteNames.leftGlute : injectionLeftGlute,
                    PDSiteStrings.SiteNames.leftDelt : injectionLeftDelt,
                    PDSiteStrings.SiteNames.rightDelt : injectionRightDelt,
                    PDSiteStrings.SiteNames.leftQuad : injectionLeftQuad,
                    PDSiteStrings.SiteNames.rightQuad : injectionRightQuad]
        case (.Dark, .Injections):
            return [PDSiteStrings.unplaced : newImg,
                    PDSiteStrings.SiteNames.rightGlute : darkInjectionGluteRight,
                    PDSiteStrings.SiteNames.leftGlute : darkInjectionLeftGlute,
                    PDSiteStrings.SiteNames.leftDelt : darkInjectionLeftDelt,
                    PDSiteStrings.SiteNames.rightDelt : darkInjectionRightDelt,
                    PDSiteStrings.SiteNames.leftQuad : darkInjectionLeftQuad,
                    PDSiteStrings.SiteNames.rightQuad : darkInjectionRightQuad]
        }
    }
}
