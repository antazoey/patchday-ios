//
//  VCTitleStrings.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/15/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public class VCTitleStrings {
    
    private static let comment = "Title of a view controller. Keep it brief please."

    public static let patchesTitle = {
        NSLocalizedString("Patches", comment: comment)
    }()

    public static let injectionsTitle = {
        NSLocalizedString("Injections", comment: comment)
    }()
    
    public static let hormonesTitle = {
        return NSLocalizedString("Hormones", comment: comment)
    }()

    public static let settingsTitle = {
        NSLocalizedString("Settings", comment: comment)
    }()

    public static let pillsTitle = {
        NSLocalizedString("Pills", comment: comment)
    }()

    public static let editPillTitle = {
        NSLocalizedString("Edit Pill", comment: comment)
    }()

    public static let newPillTitle = {
        NSLocalizedString("New Pill", comment: comment)
    }()

    public static let sitesTitle = {
        NSLocalizedString("Sites", comment: comment)
    }()

    public static let patchSitesTitle = {
        NSLocalizedString("Patch Sites", comment: comment)
    }()

    public static let injectionSitesTitle = {
        NSLocalizedString("Injection Sites", comment: comment)
    }()

    public static let editSiteTitle = {
        NSLocalizedString("Edit Site", comment: comment)
    }()
    
    public static let patchTitle = {
        NSLocalizedString("Patch", comment: comment)
    }()
    public static let injectionTitle = {
        NSLocalizedString("Injection", comment: comment)
    }()
    
    public static let siteTitle = {
        NSLocalizedString("Site", comment: comment)
    }()

    public static func getTitle(for method: DeliveryMethod) -> String {
        switch method {
        case .Patches:
            return patchesTitle
        case .Injections:
            return injectionsTitle
        }
    }
    
    public static func getSitesTitle(for method: DeliveryMethod) -> String {
        switch method {
        case .Patches:
            return patchSitesTitle
        case .Injections:
            return injectionSitesTitle
        }
    }
}
