//
//  PDImages.swift
//  PDKit
//
//  Created by Juliya Smith on 6/3/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

public typealias UIIcon = UIImage

public class PDImages: NSObject {
    
    override public var description: String { return "Read-only app images." }
    
    // Cerebral
    private static let cerebralPatch = { return UIImage(named: "Add Patch")! }()
    private static let darkCerebralPatch = { return UIImage(named: "Add Patch Dark")! }()
    private static var cerebralInjection = { return UIImage(named: "Add Injection")! }()
    private static var darkCerebralInjection = { return UIImage(named: "Add Injection Dark")! }()
    
    // Patch site images
    private static let patchRightGlute = { return UIImage(named: "Right Glute")! }()
    private static let darkPatchRightGlute = { return UIImage(named: "Right Glute Dark")! }()
    private static let patchLeftGlute = { return UIImage(named: "Left Glute")! }()
    private static let darkPatchLeftGlute = { return UIImage(named: "Left Glute Dark")! }()
    private static let patchRightAbdomen = { return UIImage(named: "Right Abdomen")! }()
    private static let darkPatchRightAbdomen = { return UIImage(named: "Right Abdomen Dark")! }()
    private static let patchLeftAbdomen = { return UIImage(named: "Left Abdomen")! }()
    private static let darkPatchLeftAbdomen = { return UIImage(named: "Left Abdomen Dark")! }()
    private static let customPatch = { return UIImage(named: "Custom Patch")! }()
    private static let darkCustomPatch = { return UIImage(named: "Custom Patch Darl")! }()
    
    // Injection site images
    private static let injectionLeftQuad = { return UIImage(named: "Left Quad")! }()
    private static let darkInjectionLeftQuad = { return UIImage(named: "Left Quad Dark")! }()
    private static let injectionRightQuad = { return UIImage(named: "Right Quad")! }()
    private static let darkInjectionRightQuad = { return UIImage(named: "Right Quad Dark")! }()
    private static let injectionLeftGlute = { return UIImage(named: "Left Injection Glute")! }()
    private static let darkInjectionLeftGlute = { return UIImage(named: "Left Injection Glute Dark")! }()
    private static let injectionGluteRight = { return UIImage(named: "Right Injection Glute")! }()
    private static let darkInjectionGluteRight = { return UIImage(named: "Right Injection Glute Dark")! }()
    private static let injectionLeftDelt = { return UIImage(named: "Left Delt")! } ()
    private static let darkInjectionLeftDelt = { return UIImage(named: "Left Delt Dark")! } ()
    private static let injectionRightDelt = { return UIImage(named: "Right Delt")! }()
    private static let darkInjectionRightDelt = { return UIImage(named: "Right Delt Dark")! }()
    private static let customInjection = { return UIImage(named: "Custom Injection")! }()
    private static let darkCustomInjection = { return UIImage(named: "Custom Injection Dark")! }()
    
    // Site Index Icons
    private static let calendarIcon = { return UIImage(named: "Calendar Icon")! }()
    private static let siteIndexIcon = { return UIImage(named: "Site Index Icon")! }()
    private static let siteIndexIconOne = { return UIImage(named: "Site Index Icon 1")! }()
    private static let siteIndexIconTwo = { return UIImage(named: "Site Index Icon 2")! }()
    private static let siteIndexIconThree = { return UIImage(named: "Site Index Icon 3")! }()
    private static let siteIndexIconFour = { return UIImage(named: "Site Index Icon 4")! }()
    
    // Icons
    private static let patchIcon = { return UIImage(named: "Patch Icon")! }()
    private static let injectionIcon = { return UIImage(named: "Injection Icon")! }()
    
    // Accessible Icons
    static let settingsIcon = { return UIImage(named: "Settings Icon")! }()
    
    
    // Pills
    public static let pill = { return UIImage(named: "Pill")! }()
    
    public static func siteImages(
        theme: PDTheme?, deliveryMethod: DeliveryMethod?) -> [UIImage] {

        if let theme = theme, let deliveryMethod = deliveryMethod {
            switch (theme, deliveryMethod) {
            case (.Light, .Patches):
                return [
                    patchRightGlute,
                    patchLeftGlute,
                    patchRightAbdomen,
                    patchLeftAbdomen,
                    customPatch
                ]
            case (.Dark, .Patches):
                return [
                    darkPatchRightGlute,
                    darkPatchLeftGlute,
                    darkPatchRightAbdomen,
                    darkPatchLeftAbdomen,
                    darkCustomPatch
                ]
            case (.Light, .Injections):
                return [
                    injectionRightQuad,
                    injectionLeftQuad,
                    injectionLeftGlute,
                    injectionGluteRight,
                    injectionLeftDelt,
                    injectionRightDelt,
                    customInjection
                ]
            case (.Dark, .Injections):
                return [
                    darkInjectionRightQuad,
                    darkInjectionLeftQuad,
                    darkInjectionLeftGlute,
                    darkInjectionGluteRight,
                    darkInjectionLeftDelt,
                    darkInjectionRightDelt,
                    darkCustomInjection
                ]
            }
        } else {
            return []
        }
    }
    
    public static func getDeliveryIcon(_ method: DeliveryMethod) -> UIIcon {
        switch method {
        case .Patches:
            return patchIcon
        case .Injections:
            return injectionIcon
        }
    }
    
    public static func getCustomHormoneImage(
        theme: PDTheme, deliveryMethod: DeliveryMethod) -> UIImage {

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

    // MARK: - Functions
    
    public static func getCerebralHormoneImage(
        theme: PDTheme, deliveryMethod: DeliveryMethod) -> UIImage {

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
    
    public static func representsCerebral(_ img: UIImage) -> Bool {
        return img == cerebralPatch || img == cerebralInjection
    }
    
    /// Coverts SiteName a.k.a String to corresponding patch image.
    public static func siteNameToImage(
        _ siteName: SiteName, theme: PDTheme, deliveryMethod: DeliveryMethod) -> UIImage {

        let stringToImageDict = getStringToImageDict(theme: theme, deliveryMethod: deliveryMethod)
        let siteNames = PDSiteStrings.getSiteNames(for: deliveryMethod)
        if (siteNames.contains(siteName)), let siteImage = stringToImageDict[siteName] {
            return siteImage
        }
        if siteName != PDSiteStrings.unplaced {
            let customSiteImage = getCustomHormoneImage(theme: theme, deliveryMethod: deliveryMethod)
            return customSiteImage
        }
        return getCerebralHormoneImage(theme: theme, deliveryMethod: deliveryMethod)
    }
    
    /// Converts patch image to SiteName a.k.a String
    public static func imageToSiteName(_ image: UIImage) -> String {
        let imageToStringDict = [
            patchRightGlute : PDSiteStrings.SiteNames.rightGlute,
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
            darkInjectionLeftDelt : PDSiteStrings.SiteNames.leftDelt
        ]
        return imageToStringDict[image] ?? PDStrings.PlaceholderStrings.newSite
    }
    
    /// Returns a site icon representing the site index
    public static func getSiteIndexIcon(for site: Bodily) -> UIIcon {
        switch site.hormones.count {
        case 1: return siteIndexIconOne
        case 2: return siteIndexIconTwo
        case 3: return siteIndexIconThree
        case 4: return siteIndexIconFour
        default: return siteIndexIcon
        }
    }
    
    public static func getImage(
        for hormone: Hormonal,
        theme: PDTheme,
        deliveryMethod: DeliveryMethod) -> UIImage {

        if let site = hormone.site {
            return siteNameToImage(site.name,
                                   theme: theme,
                                   deliveryMethod: deliveryMethod)
        }
        return getCerebralHormoneImage(theme: theme, deliveryMethod: deliveryMethod)
    }

    // MARK: - Private

    private static func getStringToImageDict(
        theme: PDTheme,
        deliveryMethod: DeliveryMethod) -> Dictionary<String, UIImage> {

        let newImg = getCerebralHormoneImage(theme: theme, deliveryMethod: .Patches);
        switch (theme, deliveryMethod) {
        case (.Light, .Patches):
            return [
                PDSiteStrings.unplaced: newImg,
                PDSiteStrings.SiteNames.rightGlute : patchRightGlute,
                PDSiteStrings.SiteNames.leftGlute : patchLeftGlute,
                PDSiteStrings.SiteNames.rightAbdomen : patchRightAbdomen,
                PDSiteStrings.SiteNames.leftAbdomen : patchLeftAbdomen
            ]
        case (.Dark, .Patches):
            return [
                PDSiteStrings.unplaced : newImg,
                PDSiteStrings.SiteNames.rightGlute : darkPatchRightGlute,
                PDSiteStrings.SiteNames.leftGlute : darkPatchLeftGlute,
                PDSiteStrings.SiteNames.rightAbdomen : darkPatchRightAbdomen,
                PDSiteStrings.SiteNames.leftAbdomen : darkPatchLeftAbdomen
            ]
        case (.Light, .Injections):
            return [
                PDSiteStrings.unplaced : newImg,
                PDSiteStrings.SiteNames.rightGlute : injectionGluteRight,
                PDSiteStrings.SiteNames.leftGlute : injectionLeftGlute,
                PDSiteStrings.SiteNames.leftDelt : injectionLeftDelt,
                PDSiteStrings.SiteNames.rightDelt : injectionRightDelt,
                PDSiteStrings.SiteNames.leftQuad : injectionLeftQuad,
                PDSiteStrings.SiteNames.rightQuad : injectionRightQuad
            ]
        case (.Dark, .Injections):
            return [
                PDSiteStrings.unplaced : newImg,
                PDSiteStrings.SiteNames.rightGlute : darkInjectionGluteRight,
                PDSiteStrings.SiteNames.leftGlute : darkInjectionLeftGlute,
                PDSiteStrings.SiteNames.leftDelt : darkInjectionLeftDelt,
                PDSiteStrings.SiteNames.rightDelt : darkInjectionRightDelt,
                PDSiteStrings.SiteNames.leftQuad : darkInjectionLeftQuad,
                PDSiteStrings.SiteNames.rightQuad : darkInjectionRightQuad
            ]
        }
    }
}
