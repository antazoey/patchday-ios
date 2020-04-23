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
    private static var placeholderPatch: UIImage { initImage("Add Patch") }
    private static var placeholderInjection: UIImage { initImage("Add Injection") }
    
    // Patch site images
    private static var patchRightGlute: UIImage { initImage("Right Glute") }
    private static var patchLeftGlute: UIImage { initImage("Left Glute") }
    private static var patchRightAbdomen: UIImage { initImage("Right Abdomen") }
    private static var patchLeftAbdomen: UIImage { initImage("Left Abdomen") }
    private static var customPatch: UIImage { initImage("Custom Patch") }
    
    // Injection site images
    private static var lnjectionLeftQuad: UIImage { initImage("Left Quad") }
    private static var lnjectionRightQuad: UIImage { initImage("Right Quad") }
    private static var lnjectionLeftGlute: UIImage { initImage("Left Injection Glute") }
    private static var lnjectionGluteRight: UIImage { initImage("Right Injection Glute") }
    private static var lnjectionLeftDelt: UIImage { initImage("Left Delt") }
    private static var lnjectionRightDelt: UIImage { initImage("Right Delt") }
    private static var customInjection: UIImage { initImage("Custom Injection") }
    
    private static var patchImages: [UIImage] {
        [patchRightGlute, patchLeftGlute, patchRightAbdomen, patchLeftAbdomen, customPatch]
    }

    private static var injectionImages: [UIImage] {
        [
            lnjectionRightQuad,
            lnjectionLeftQuad,
            lnjectionLeftGlute,
            lnjectionGluteRight,
            lnjectionLeftDelt,
            lnjectionRightDelt,
            customInjection
        ]
    }

    private static var imageToSiteNameDict: [UIImage: SiteName] {
        [
            patchRightGlute : SiteStrings.rightGlute,
            patchLeftGlute : SiteStrings.leftGlute,
            patchRightAbdomen : SiteStrings.rightAbdomen,
            patchLeftAbdomen : SiteStrings.leftAbdomen,
            lnjectionGluteRight : SiteStrings.rightGlute,
            lnjectionLeftGlute : SiteStrings.leftGlute,
            lnjectionRightQuad : SiteStrings.rightQuad,
            lnjectionLeftQuad : SiteStrings.leftQuad,
            lnjectionRightDelt : SiteStrings.rightDelt,
            lnjectionLeftDelt : SiteStrings.leftDelt,
        ]
    }

    private static var siteNameToPatchImageDict: [SiteName: UIImage] {
        [
            SiteStrings.rightGlute: patchRightGlute,
            SiteStrings.leftGlute: patchLeftGlute,
            SiteStrings.rightAbdomen: patchRightAbdomen,
            SiteStrings.leftAbdomen: patchLeftAbdomen
        ]
    }

    private static var siteNameToInjectionImageDict: [SiteName: UIImage] {
        [
            SiteStrings.rightGlute: lnjectionGluteRight,
            SiteStrings.leftGlute: lnjectionLeftGlute,
            SiteStrings.leftDelt: lnjectionLeftDelt,
            SiteStrings.rightDelt: lnjectionRightDelt,
            SiteStrings.leftQuad: lnjectionLeftQuad,
            SiteStrings.rightQuad: lnjectionRightQuad
        ]
    }

    static var pill: UIImage { initImage("Pill") }
    
    private static func initImage(_ name: String) -> UIImage {
        guard let image = UIImage(named: name) else { return UIImage() }
        image.accessibilityIdentifier = name
        return image
    }
    
    static func getAllAvailable(_ params: SiteImageDeterminationParameters) -> [UIImage] {
        switch params.deliveryMethod {
        case .Patches: return patchImages
        case .Injections: return injectionImages
        }
    }
    
    static func isPlaceholder(_ img: UIImage) -> Bool {
        img == placeholderPatch || img == placeholderInjection
    }
    
    /// Converts patch image to SiteName a.k.a String
    static func getName(from image: UIImage) -> SiteName {
        imageToSiteNameDict[image] ?? SiteStrings.NewSite
    }

    static subscript(params: SiteImageDeterminationParameters) -> UIImage {
        provided(from: params) ?? custom(from: params) ?? placeholder(params)
    }

    private static func provided(from params: SiteImageDeterminationParameters) -> UIImage? {
        guard let siteName = params.siteName else { return nil }
        switch params.deliveryMethod {
        case .Patches: return siteNameToPatchImageDict[siteName]
        case .Injections: return siteNameToInjectionImageDict[siteName]
        }
    }

    private static func custom(from params: SiteImageDeterminationParameters) -> UIImage? {
        guard let _ = params.siteName else { return nil }
        switch params.deliveryMethod {
        case .Patches: return customPatch
        case .Injections: return customInjection
        }
    }
    
    private static func placeholder(_ params: SiteImageDeterminationParameters) -> UIImage {
        switch params.deliveryMethod {
        case .Patches: return placeholderPatch
        case .Injections: return placeholderInjection
        }
    }
}
