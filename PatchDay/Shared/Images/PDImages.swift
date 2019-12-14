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
    
    override public var description: String { "Read-only app images." }
    
    // Cerebral
    private static let cerebralPatch = { UIImage(named: "Add Patch")! }()
    private static let darkCerebralPatch = { UIImage(named: "Add Patch Dark")! }()
    private static var cerebralInjection = { UIImage(named: "Add Injection")! }()
    private static var darkCerebralInjection = { UIImage(named: "Add Injection Dark")! }()
    
    // Patch site images
    private static let patchRightGlute = { UIImage(named: "Right Glute")! }()
    private static let darkPatchRightGlute = { UIImage(named: "Right Glute Dark")! }()
    private static let patchLeftGlute = { UIImage(named: "Left Glute")! }()
    private static let darkPatchLeftGlute = { UIImage(named: "Left Glute Dark")! }()
    private static let patchRightAbdomen = { UIImage(named: "Right Abdomen")! }()
    private static let darkPatchRightAbdomen = { UIImage(named: "Right Abdomen Dark")! }()
    private static let patchLeftAbdomen = { UIImage(named: "Left Abdomen")! }()
    private static let darkPatchLeftAbdomen = { UIImage(named: "Left Abdomen Dark")! }()
    private static let customPatch = { UIImage(named: "Custom Patch")! }()
    private static let darkCustomPatch = { UIImage(named: "Custom Patch Darl")! }()
    
    // Injection site images
    private static let injectionLeftQuad = { UIImage(named: "Left Quad")! }()
    private static let darkInjectionLeftQuad = { UIImage(named: "Left Quad Dark")! }()
    private static let injectionRightQuad = { UIImage(named: "Right Quad")! }()
    private static let darkInjectionRightQuad = { UIImage(named: "Right Quad Dark")! }()
    private static let injectionLeftGlute = { UIImage(named: "Left Injection Glute")! }()
    private static let darkInjectionLeftGlute = { UIImage(named: "Left Injection Glute Dark")! }()
    private static let injectionGluteRight = { UIImage(named: "Right Injection Glute")! }()
    private static let darkInjectionGluteRight = { UIImage(named: "Right Injection Glute Dark")! }()
    private static let injectionLeftDelt = { UIImage(named: "Left Delt")! } ()
    private static let darkInjectionLeftDelt = { UIImage(named: "Left Delt Dark")! } ()
    private static let injectionRightDelt = { UIImage(named: "Right Delt")! }()
    private static let darkInjectionRightDelt = { UIImage(named: "Right Delt Dark")! }()
    private static let customInjection = { UIImage(named: "Custom Injection")! }()
    private static let darkCustomInjection = { UIImage(named: "Custom Injection Dark")! }()
    
    // Site Index Icons
    private static let calendarIcon = { UIImage(named: "Calendar Icon")! }()
    private static let siteIndexIcon = { UIImage(named: "Site Index Icon")! }()
    private static let siteIndexIconOne = { UIImage(named: "Site Index Icon 1")! }()
    private static let siteIndexIconTwo = { UIImage(named: "Site Index Icon 2")! }()
    private static let siteIndexIconThree = { UIImage(named: "Site Index Icon 3")! }()
    private static let siteIndexIconFour = { UIImage(named: "Site Index Icon 4")! }()
    
    // Icons
    private static let patchIcon = { UIImage(named: "Patch Icon")! }()
    private static let injectionIcon = { UIImage(named: "Injection Icon")! }()
    
    // Accessible Icons
    static let settingsIcon = { UIImage(named: "Settings Icon")! }()
    
    
    // Pills
    static let pill = { UIImage(named: "Pill")! }()
    
    static func siteImages(
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
    
    static func getDeliveryIcon(_ method: DeliveryMethod) -> UIIcon {
        switch method {
        case .Patches: return patchIcon
        case .Injections: return injectionIcon
        }
    }
    
    static func representsCerebral(_ img: UIImage) -> Bool {
        img == cerebralPatch || img == cerebralInjection
    }

    static func getSiteImage(_ params: SiteImageDeterminationParameters) -> UIImage {
        let sitesWithImages = SiteStrings.getSiteNames(for: params.deliveryMethod)
        if params.siteName == SiteStrings.newSite {
            return PDImages.getCerebralHormoneImage(params)
        } else if let imageName = sitesWithImages.tryGet(at: params.siteIndex) {
            params.siteName = imageName
            return PDImages.siteNameToImage(params)
        }
        return PDImages.getCustomHormoneImage(params)
    }
    
    /// Converts patch image to SiteName a.k.a String
    static func imageToSiteName(_ image: UIImage) -> String {
        let imageToStringDict = [
            patchRightGlute : SiteStrings.SiteNames.rightGlute,
            darkPatchRightGlute : SiteStrings.SiteNames.rightGlute,
            patchLeftGlute : SiteStrings.SiteNames.leftGlute,
            darkPatchLeftGlute : SiteStrings.SiteNames.leftGlute,
            patchRightAbdomen : SiteStrings.SiteNames.rightAbdomen,
            darkPatchRightAbdomen : SiteStrings.SiteNames.rightAbdomen,
            patchLeftAbdomen : SiteStrings.SiteNames.leftAbdomen,
            darkPatchLeftAbdomen : SiteStrings.SiteNames.leftAbdomen,
            injectionGluteRight : SiteStrings.SiteNames.rightGlute,
            darkInjectionGluteRight : SiteStrings.SiteNames.rightGlute,
            injectionLeftGlute : SiteStrings.SiteNames.leftGlute,
            darkInjectionLeftGlute : SiteStrings.SiteNames.leftGlute,
            injectionRightQuad : SiteStrings.SiteNames.rightQuad,
            darkInjectionRightQuad : SiteStrings.SiteNames.rightQuad,
            injectionLeftQuad : SiteStrings.SiteNames.leftQuad,
            darkInjectionLeftQuad : SiteStrings.SiteNames.leftQuad,
            injectionRightDelt : SiteStrings.SiteNames.rightDelt,
            darkInjectionRightDelt : SiteStrings.SiteNames.rightDelt,
            injectionLeftDelt : SiteStrings.SiteNames.leftDelt,
            darkInjectionLeftDelt : SiteStrings.SiteNames.leftDelt
        ]
        return imageToStringDict[image] ?? SiteStrings.newSite
    }
    
    /// Returns a site icon representing the site index
    static func getSiteIndexIcon(for site: Bodily) -> UIIcon {
        switch site.hormones.count {
        case 1: return siteIndexIconOne
        case 2: return siteIndexIconTwo
        case 3: return siteIndexIconThree
        case 4: return siteIndexIconFour
        default: return siteIndexIcon
        }
    }

    // MARK: - Private

    private static func getCerebralHormoneImage(_ params: SiteImageDeterminationParameters) -> UIImage {
        switch (params.theme, params.deliveryMethod) {
        case (.Dark, .Patches): return darkCerebralPatch
        case(.Light, .Patches): return cerebralPatch
        case (.Light, .Injections): return cerebralInjection
        case (.Dark, .Injections): return darkCerebralInjection
        }
    }

    /// Coverts SiteName a.k.a String to corresponding patch image.
    private static func siteNameToImage(_ params: SiteImageDeterminationParameters) -> UIImage {
        let stringToImageDict = getStringToImageDict(params)
        let siteNames = SiteStrings.getSiteNames(for: params.deliveryMethod)
        if siteNames.contains(params.siteName), let siteImage = stringToImageDict[params.siteName] {
            return siteImage
        }
        if params.siteName != SiteStrings.unplaced {
            let customSiteImage = getCustomHormoneImage(params)
            return customSiteImage
        }
        return getCerebralHormoneImage(params)
    }

    private static func getCustomHormoneImage(_ params: SiteImageDeterminationParameters) -> UIImage {
        switch (params.theme, params.deliveryMethod) {
        case (.Light, .Patches): return customPatch
        case (.Dark, .Patches): return darkCustomPatch
        case (.Light, .Injections): return customInjection
        case (.Dark, .Injections): return darkCustomInjection
        }
    }

    private static func getStringToImageDict(_ params: SiteImageDeterminationParameters) -> Dictionary<String, UIImage> {
        let newImg = getCerebralHormoneImage(params)
        switch (params.theme, params.deliveryMethod) {
        case (.Light, .Patches):
            return [
                SiteStrings.unplaced: newImg,
                SiteStrings.SiteNames.rightGlute : patchRightGlute,
                SiteStrings.SiteNames.leftGlute : patchLeftGlute,
                SiteStrings.SiteNames.rightAbdomen : patchRightAbdomen,
                SiteStrings.SiteNames.leftAbdomen : patchLeftAbdomen
            ]
        case (.Dark, .Patches):
            return [
                SiteStrings.unplaced : newImg,
                SiteStrings.SiteNames.rightGlute : darkPatchRightGlute,
                SiteStrings.SiteNames.leftGlute : darkPatchLeftGlute,
                SiteStrings.SiteNames.rightAbdomen : darkPatchRightAbdomen,
                SiteStrings.SiteNames.leftAbdomen : darkPatchLeftAbdomen
            ]
        case (.Light, .Injections):
            return [
                SiteStrings.unplaced : newImg,
                SiteStrings.SiteNames.rightGlute : injectionGluteRight,
                SiteStrings.SiteNames.leftGlute : injectionLeftGlute,
                SiteStrings.SiteNames.leftDelt : injectionLeftDelt,
                SiteStrings.SiteNames.rightDelt : injectionRightDelt,
                SiteStrings.SiteNames.leftQuad : injectionLeftQuad,
                SiteStrings.SiteNames.rightQuad : injectionRightQuad
            ]
        case (.Dark, .Injections):
            return [
                SiteStrings.unplaced : newImg,
                SiteStrings.SiteNames.rightGlute : darkInjectionGluteRight,
                SiteStrings.SiteNames.leftGlute : darkInjectionLeftGlute,
                SiteStrings.SiteNames.leftDelt : darkInjectionLeftDelt,
                SiteStrings.SiteNames.rightDelt : darkInjectionRightDelt,
                SiteStrings.SiteNames.leftQuad : darkInjectionLeftQuad,
                SiteStrings.SiteNames.rightQuad : darkInjectionRightQuad
            ]
        }
    }
}
