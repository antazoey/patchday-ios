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
    
    override public var description: String { "Read-only app images." }
    
    // Placeholder
    private static let lightPlaceholderPatch = { UIImage(named: "Add Patch")! }()
    private static let darkPlaceholderPatch = { UIImage(named: "Add Patch Dark")! }()
    private static var lightPlaceholderInjection = { UIImage(named: "Add Injection")! }()
    private static var darkPlaceholderInjection = { UIImage(named: "Add Injection Dark")! }()
    
    // Patch site images
    private static let lightPatchRightGlute = { UIImage(named: "Right Glute")! }()
    private static let darkPatchRightGlute = { UIImage(named: "Right Glute Dark")! }()
    private static let lightPatchLeftGlute = { UIImage(named: "Left Glute")! }()
    private static let darkPatchLeftGlute = { UIImage(named: "Left Glute Dark")! }()
    private static let lightPatchRightAbdomen = { UIImage(named: "Right Abdomen")! }()
    private static let darkPatchRightAbdomen = { UIImage(named: "Right Abdomen Dark")! }()
    private static let lightPatchLeftAbdomen = { UIImage(named: "Left Abdomen")! }()
    private static let darkPatchLeftAbdomen = { UIImage(named: "Left Abdomen Dark")! }()
    private static let lightCustomPatch = { UIImage(named: "Custom Patch")! }()
    private static let darkCustomPatch = { UIImage(named: "Custom Patch Dark")! }()
    
    // Injection site images
    private static let lightInjectionLeftQuad = { UIImage(named: "Left Quad")! }()
    private static let darkInjectionLeftQuad = { UIImage(named: "Left Quad Dark")! }()
    private static let lightInjectionRightQuad = { UIImage(named: "Right Quad")! }()
    private static let darkInjectionRightQuad = { UIImage(named: "Right Quad Dark")! }()
    private static let lightInjectionLeftGlute = { UIImage(named: "Left Injection Glute")! }()
    private static let darkInjectionLeftGlute = { UIImage(named: "Left Injection Glute Dark")! }()
    private static let lightInjectionGluteRight = { UIImage(named: "Right Injection Glute")! }()
    private static let darkInjectionGluteRight = { UIImage(named: "Right Injection Glute Dark")! }()
    private static let lightInjectionLeftDelt = { UIImage(named: "Left Delt")! } ()
    private static let darkInjectionLeftDelt = { UIImage(named: "Left Delt Dark")! } ()
    private static let lightInjectionRightDelt = { UIImage(named: "Right Delt")! }()
    private static let darkInjectionRightDelt = { UIImage(named: "Right Delt Dark")! }()
    private static let lightCustomInjection = { UIImage(named: "Custom Injection")! }()
    private static let darkCustomInjection = { UIImage(named: "Custom Injection Dark")! }()

    private static let lightPatchImages = {
        [lightPatchRightGlute, lightPatchLeftGlute, lightPatchRightAbdomen, lightPatchLeftAbdomen, lightCustomPatch]
    }()

    private static let darkPatchImages = {
        [darkPatchRightGlute, darkPatchLeftGlute, darkPatchRightAbdomen, darkPatchLeftAbdomen, darkCustomPatch]
    }()

    private static let lightInjectionImages = {
        [
            lightInjectionRightQuad,
            lightInjectionLeftQuad,
            lightInjectionLeftGlute,
            lightInjectionGluteRight,
            lightInjectionLeftDelt,
            lightInjectionRightDelt,
            lightCustomInjection
        ]
    }()

    private static let darkInjectionImages = {
        [
            darkInjectionRightQuad,
            darkInjectionLeftQuad,
            darkInjectionLeftGlute,
            darkInjectionGluteRight,
            darkInjectionLeftDelt,
            darkInjectionRightDelt,
            darkCustomInjection
        ]
    }()

    private static let imageToSiteNameDict = {
        [
            lightPatchRightGlute : SiteStrings.SiteNames.rightGlute,
            darkPatchRightGlute : SiteStrings.SiteNames.rightGlute,
            lightPatchLeftGlute : SiteStrings.SiteNames.leftGlute,
            darkPatchLeftGlute : SiteStrings.SiteNames.leftGlute,
            lightPatchRightAbdomen : SiteStrings.SiteNames.rightAbdomen,
            darkPatchRightAbdomen : SiteStrings.SiteNames.rightAbdomen,
            lightPatchLeftAbdomen : SiteStrings.SiteNames.leftAbdomen,
            darkPatchLeftAbdomen : SiteStrings.SiteNames.leftAbdomen,
            lightInjectionGluteRight : SiteStrings.SiteNames.rightGlute,
            darkInjectionGluteRight : SiteStrings.SiteNames.rightGlute,
            lightInjectionLeftGlute : SiteStrings.SiteNames.leftGlute,
            darkInjectionLeftGlute : SiteStrings.SiteNames.leftGlute,
            lightInjectionRightQuad : SiteStrings.SiteNames.rightQuad,
            darkInjectionRightQuad : SiteStrings.SiteNames.rightQuad,
            lightInjectionLeftQuad : SiteStrings.SiteNames.leftQuad,
            darkInjectionLeftQuad : SiteStrings.SiteNames.leftQuad,
            lightInjectionRightDelt : SiteStrings.SiteNames.rightDelt,
            darkInjectionRightDelt : SiteStrings.SiteNames.rightDelt,
            lightInjectionLeftDelt : SiteStrings.SiteNames.leftDelt,
            darkInjectionLeftDelt : SiteStrings.SiteNames.leftDelt
        ]
    }()

    private static let siteNameToLightPatchImageDict = {
        [
            SiteStrings.SiteNames.rightGlute: lightPatchRightGlute,
            SiteStrings.SiteNames.leftGlute: lightPatchLeftGlute,
            SiteStrings.SiteNames.rightAbdomen: lightPatchRightAbdomen,
            SiteStrings.SiteNames.leftAbdomen: lightPatchLeftAbdomen
        ]
    }()

    private static let siteNameToDarkPatchImageDict = {
        [
            SiteStrings.SiteNames.rightGlute: darkPatchRightGlute,
            SiteStrings.SiteNames.leftGlute: darkPatchLeftGlute,
            SiteStrings.SiteNames.rightAbdomen: darkPatchRightAbdomen,
            SiteStrings.SiteNames.leftAbdomen: darkPatchLeftAbdomen
        ]
    }()

    private static let siteNameToLightInjectionImageDict = {
        [
            SiteStrings.SiteNames.rightGlute: lightInjectionGluteRight,
            SiteStrings.SiteNames.leftGlute: lightInjectionLeftGlute,
            SiteStrings.SiteNames.leftDelt: lightInjectionLeftDelt,
            SiteStrings.SiteNames.rightDelt: lightInjectionRightDelt,
            SiteStrings.SiteNames.leftQuad: lightInjectionLeftQuad,
            SiteStrings.SiteNames.rightQuad: lightInjectionRightQuad
        ]
    }()

    private static let siteNameToDarkInjectionImageDict = {
        [
            SiteStrings.SiteNames.rightGlute: darkInjectionGluteRight,
            SiteStrings.SiteNames.leftGlute: darkInjectionLeftGlute,
            SiteStrings.SiteNames.leftDelt: darkInjectionLeftDelt,
            SiteStrings.SiteNames.rightDelt: darkInjectionRightDelt,
            SiteStrings.SiteNames.leftQuad: darkInjectionLeftQuad,
            SiteStrings.SiteNames.rightQuad: darkInjectionRightQuad
        ]
    }()

    // Pills
    static let pill = { UIImage(named: "Pill")! }()
    
    static func getAvailableSiteImages(_ params: SiteImageDeterminationParameters) -> [UIImage] {
        switch params.imageType {
        case .LightPatch: return lightPatchImages
        case .DarkPatch: return darkPatchImages
        case .LightInjection: return lightInjectionImages
        case .DarkInjection: return darkInjectionImages
        }
    }
    
    static func isPlaceholderImage(_ img: UIImage) -> Bool {
        img == lightPlaceholderPatch || img == lightPlaceholderInjection
    }
    
    /// Converts patch image to SiteName a.k.a String
    static func getSiteName(from image: UIImage) -> SiteName {
        imageToSiteNameDict[image] ?? SiteStrings.NewSite
    }

    /// Coverts SiteName a.k.a String to corresponding hormone image.
    static func getSiteImage(from params: SiteImageDeterminationParameters) -> UIImage {
        tryGetSystemImage(from: params) ?? getPlaceholderHormoneImage(params)
    }

    // MARK: - Private

    private static func getPlaceholderHormoneImage(_ params: SiteImageDeterminationParameters) -> UIImage {
        switch params.imageType {
        case .DarkPatch: return darkPlaceholderPatch
        case .LightPatch: return lightPlaceholderPatch
        case .LightInjection: return lightPlaceholderInjection
        case .DarkInjection: return darkPlaceholderInjection
        }
    }

    private static func tryGetSystemImage(from params: SiteImageDeterminationParameters) -> UIImage? {
        if let siteImage = tryGetSystemSiteImage(from: params) {
            return siteImage
        }
        return tryGetCustomImage(from: params)
    }

    private static func tryGetSystemSiteImage(from params: SiteImageDeterminationParameters) -> UIImage? {
        if let siteName = params.siteName {
            switch params.imageType {
            case .LightPatch: return siteNameToLightPatchImageDict[siteName]
            case .DarkPatch: return siteNameToDarkPatchImageDict[siteName]
            case .LightInjection: return siteNameToLightInjectionImageDict[siteName]
            case .DarkInjection: return siteNameToDarkInjectionImageDict[siteName]
            }
        }
        return nil
    }

    private static func tryGetCustomImage(from params: SiteImageDeterminationParameters) -> UIImage? {
        if let _ = params.siteName {
            switch params.imageType {
            case .LightPatch: return lightCustomPatch
            case .DarkPatch: return darkCustomPatch
            case .LightInjection: return lightCustomInjection
            case .DarkInjection: return darkCustomInjection
            }
        }
        return nil
    }
}
