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
    }

    private static var siteNameToLightPatchImageDict: [SiteName: UIImage] {
        [
            SiteStrings.SiteNames.rightGlute: lightPatchRightGlute,
            SiteStrings.SiteNames.leftGlute: lightPatchLeftGlute,
            SiteStrings.SiteNames.rightAbdomen: lightPatchRightAbdomen,
            SiteStrings.SiteNames.leftAbdomen: lightPatchLeftAbdomen
        ]
    }

    private static var siteNameToDarkPatchImageDict: [SiteName: UIImage] {
        [
            SiteStrings.SiteNames.rightGlute: darkPatchRightGlute,
            SiteStrings.SiteNames.leftGlute: darkPatchLeftGlute,
            SiteStrings.SiteNames.rightAbdomen: darkPatchRightAbdomen,
            SiteStrings.SiteNames.leftAbdomen: darkPatchLeftAbdomen
        ]
    }

    private static var siteNameToLightInjectionImageDict: [SiteName: UIImage] {
        [
            SiteStrings.SiteNames.rightGlute: lightInjectionGluteRight,
            SiteStrings.SiteNames.leftGlute: lightInjectionLeftGlute,
            SiteStrings.SiteNames.leftDelt: lightInjectionLeftDelt,
            SiteStrings.SiteNames.rightDelt: lightInjectionRightDelt,
            SiteStrings.SiteNames.leftQuad: lightInjectionLeftQuad,
            SiteStrings.SiteNames.rightQuad: lightInjectionRightQuad
        ]
    }

    private static var siteNameToDarkInjectionImageDict: [SiteName: UIImage] {
        [
            SiteStrings.SiteNames.rightGlute: darkInjectionGluteRight,
            SiteStrings.SiteNames.leftGlute: darkInjectionLeftGlute,
            SiteStrings.SiteNames.leftDelt: darkInjectionLeftDelt,
            SiteStrings.SiteNames.rightDelt: darkInjectionRightDelt,
            SiteStrings.SiteNames.leftQuad: darkInjectionLeftQuad,
            SiteStrings.SiteNames.rightQuad: darkInjectionRightQuad
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

    static func get(from params: SiteImageDeterminationParameters) -> UIImage {
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
