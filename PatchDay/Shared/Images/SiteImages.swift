//
//  SiteImages.swift
//  PDKit
//
//  Created by Juliya Smith on 6/3/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


public class SiteImages: NSObject {
    
    override public var description: String { "Read-only app image static accessor." }
    
    // Placeholder
    private static var lightPlaceholderPatch: UIImage { initImage("Add Patch") }
    private static var darkPlaceholderPatch: UIImage { initImage("Add Patch Dark") }
    private static var lightPlaceholderInjection: UIImage { initImage("Add Injection") }
    private static var darkPlaceholderInjection: UIImage { initImage("Add Injection Dark") }
    
    // Patch site images
    private static var lightPatchRightGlute: UIImage { initImage("Right Glute") }
    private static var darkPatchRightGlute: UIImage { initImage("Right Glute Dark") }
    private static var lightPatchLeftGlute: UIImage { initImage("Left Glute") }
    private static var darkPatchLeftGlute: UIImage { initImage("Left Glute Dark") }
    private static var lightPatchRightAbdomen: UIImage { initImage("Right Abdomen") }
    private static var darkPatchRightAbdomen: UIImage { initImage("Right Abdomen Dark") }
    private static var lightPatchLeftAbdomen: UIImage { initImage("Left Abdomen") }
    private static var darkPatchLeftAbdomen: UIImage { initImage("Left Abdomen Dark") }
    private static var lightCustomPatch: UIImage { initImage("Custom Patch") }
    private static var darkCustomPatch: UIImage { initImage("Custom Patch Dark") }
    
    
    // Injection site images
    
    private static var lightInjectionLeftQuad: UIImage { initImage("Left Quad") }
    private static var darkInjectionLeftQuad: UIImage { initImage("Left Quad Dark") }
    private static var lightInjectionRightQuad: UIImage { initImage("Right Quad") }
    private static var darkInjectionRightQuad: UIImage { initImage("Right Quad Dark") }
    private static var lightInjectionLeftGlute: UIImage { initImage("Left Injection Glute") }
    private static var darkInjectionLeftGlute: UIImage { initImage("Left Injection Glute Dark") }
    private static var lightInjectionGluteRight: UIImage { initImage("Right Injection Glute") }
    private static var darkInjectionGluteRight: UIImage { initImage("Right Injection Glute Dark") }
    private static var lightInjectionLeftDelt: UIImage { initImage("Left Delt") }
    private static var darkInjectionLeftDelt: UIImage { initImage("Left Delt Dark") }
    private static var lightInjectionRightDelt: UIImage { initImage("Right Delt") }
    private static var darkInjectionRightDelt: UIImage { initImage("Right Delt Dark") }
    private static var lightCustomInjection: UIImage { initImage("Custom Injection") }
    private static var darkCustomInjection: UIImage { initImage("Custom Injection Dark") }
    
    private static var lightPatchImages: [UIImage] {
        [lightPatchRightGlute, lightPatchLeftGlute, lightPatchRightAbdomen, lightPatchLeftAbdomen, lightCustomPatch]
    }

    private static var darkPatchImages: [UIImage] {
        [darkPatchRightGlute, darkPatchLeftGlute, darkPatchRightAbdomen, darkPatchLeftAbdomen, darkCustomPatch]
    }

    private static var lightInjectionImages: [UIImage] {
        [
            lightInjectionRightQuad,
            lightInjectionLeftQuad,
            lightInjectionLeftGlute,
            lightInjectionGluteRight,
            lightInjectionLeftDelt,
            lightInjectionRightDelt,
            lightCustomInjection
        ]
    }

    private static var darkInjectionImages: [UIImage] {
        [
            darkInjectionRightQuad,
            darkInjectionLeftQuad,
            darkInjectionLeftGlute,
            darkInjectionGluteRight,
            darkInjectionLeftDelt,
            darkInjectionRightDelt,
            darkCustomInjection
        ]
    }

    private static var imageToSiteNameDict: [UIImage: SiteName] {
        [
            lightPatchRightGlute : SiteStrings.rightGlute,
            darkPatchRightGlute : SiteStrings.rightGlute,
            lightPatchLeftGlute : SiteStrings.leftGlute,
            darkPatchLeftGlute : SiteStrings.leftGlute,
            lightPatchRightAbdomen : SiteStrings.rightAbdomen,
            darkPatchRightAbdomen : SiteStrings.rightAbdomen,
            lightPatchLeftAbdomen : SiteStrings.leftAbdomen,
            darkPatchLeftAbdomen : SiteStrings.leftAbdomen,
            lightInjectionGluteRight : SiteStrings.rightGlute,
            darkInjectionGluteRight : SiteStrings.rightGlute,
            lightInjectionLeftGlute : SiteStrings.leftGlute,
            darkInjectionLeftGlute : SiteStrings.leftGlute,
            lightInjectionRightQuad : SiteStrings.rightQuad,
            darkInjectionRightQuad : SiteStrings.rightQuad,
            lightInjectionLeftQuad : SiteStrings.leftQuad,
            darkInjectionLeftQuad : SiteStrings.leftQuad,
            lightInjectionRightDelt : SiteStrings.rightDelt,
            darkInjectionRightDelt : SiteStrings.rightDelt,
            lightInjectionLeftDelt : SiteStrings.leftDelt,
            darkInjectionLeftDelt : SiteStrings.leftDelt
        ]
    }

    private static var siteNameToLightPatchImageDict: [SiteName: UIImage] {
        [
            SiteStrings.rightGlute: lightPatchRightGlute,
            SiteStrings.leftGlute: lightPatchLeftGlute,
            SiteStrings.rightAbdomen: lightPatchRightAbdomen,
            SiteStrings.leftAbdomen: lightPatchLeftAbdomen
        ]
    }

    private static var siteNameToDarkPatchImageDict: [SiteName: UIImage] {
        [
            SiteStrings.rightGlute: darkPatchRightGlute,
            SiteStrings.leftGlute: darkPatchLeftGlute,
            SiteStrings.rightAbdomen: darkPatchRightAbdomen,
            SiteStrings.leftAbdomen: darkPatchLeftAbdomen
        ]
    }

    private static var siteNameToLightInjectionImageDict: [SiteName: UIImage] {
        [
            SiteStrings.rightGlute: lightInjectionGluteRight,
            SiteStrings.leftGlute: lightInjectionLeftGlute,
            SiteStrings.leftDelt: lightInjectionLeftDelt,
            SiteStrings.rightDelt: lightInjectionRightDelt,
            SiteStrings.leftQuad: lightInjectionLeftQuad,
            SiteStrings.rightQuad: lightInjectionRightQuad
        ]
    }

    private static var siteNameToDarkInjectionImageDict: [SiteName: UIImage] {
        [
            SiteStrings.rightGlute: darkInjectionGluteRight,
            SiteStrings.leftGlute: darkInjectionLeftGlute,
            SiteStrings.leftDelt: darkInjectionLeftDelt,
            SiteStrings.rightDelt: darkInjectionRightDelt,
            SiteStrings.leftQuad: darkInjectionLeftQuad,
            SiteStrings.rightQuad: darkInjectionRightQuad
        ]
    }

    static var pill: UIImage { initImage("Pill") }
    
    private static func initImage(_ name: String) -> UIImage {
        guard let image = UIImage(named: name) else { return UIImage() }
        image.accessibilityIdentifier = name
        return image
    }
    
    static func getAllAvailable(_ params: SiteImageDeterminationParameters) -> [UIImage] {
        switch params.imageType {
        case .LightPatch: return lightPatchImages
        case .DarkPatch: return darkPatchImages
        case .LightInjection: return lightInjectionImages
        case .DarkInjection: return darkInjectionImages
        }
    }
    
    static func isPlaceholder(_ img: UIImage) -> Bool {
        img == lightPlaceholderPatch || img == lightPlaceholderInjection
    }
    
    /// Converts patch image to SiteName a.k.a String
    static func getName(from image: UIImage) -> SiteName {
        imageToSiteNameDict[image] ?? SiteStrings.NewSite
    }

    static subscript(params: SiteImageDeterminationParameters) -> UIImage {
        tryGetForProvided(from: params) ?? tryGetForCustom(from: params) ?? getForPlaceholderHormone(params)
    }

    // MARK: - Private

    private static func tryGetForProvided(from params: SiteImageDeterminationParameters) -> UIImage? {
        guard let siteName = params.siteName else { return nil }
        switch params.imageType {
        case .LightPatch: return siteNameToLightPatchImageDict[siteName]
        case .DarkPatch: return siteNameToDarkPatchImageDict[siteName]
        case .LightInjection: return siteNameToLightInjectionImageDict[siteName]
        case .DarkInjection: return siteNameToDarkInjectionImageDict[siteName]
        }
    }

    private static func tryGetForCustom(from params: SiteImageDeterminationParameters) -> UIImage? {
        guard let _ = params.siteName else { return nil }
        switch params.imageType {
        case .LightPatch: return lightCustomPatch
        case .DarkPatch: return darkCustomPatch
        case .LightInjection: return lightCustomInjection
        case .DarkInjection: return darkCustomInjection
        }
    }
    
    private static func getForPlaceholderHormone(_ params: SiteImageDeterminationParameters) -> UIImage {
        switch params.imageType {
        case .DarkPatch: return darkPlaceholderPatch
        case .LightPatch: return lightPlaceholderPatch
        case .LightInjection: return lightPlaceholderInjection
        case .DarkInjection: return darkPlaceholderInjection
        }
    }
}
