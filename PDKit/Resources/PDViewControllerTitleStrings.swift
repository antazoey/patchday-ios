//
//  PDViewControllerTitleStrings.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/15/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public class PDViewControllerTitleStrings {
    
    private static let comment = "Title of a view controller. Keep it brief."

    public static let patchesTitle = {
        return NSLocalizedString("Patches", comment: comment)
    }()

    public static let injectionsTitle = {
        return NSLocalizedString("Injections", comment: comment)
    }()

    public static let settingsTitle = {
        return NSLocalizedString("Settings", comment: comment)
    }()

    public static let pillsTitle = {
        return NSLocalizedString("Pills", comment: comment)
    }()

    public static let editPillTitle = {
        return NSLocalizedString("Edit Pill", comment: comment)
    }()

    public static let newPillTitle = {
        return NSLocalizedString("New Pill", comment: comment)
    }()

    public static let sitesTitle = {
        return NSLocalizedString("Sites", comment: comment)
    }()

    public static let patchSitesTitle = {
        return NSLocalizedString("Patch Sites", comment: comment)
    }()

    public static let injectionSitesTitle = {
        return NSLocalizedString("Injection Sites", comment: comment)
    }()

    public static let editSiteTitle = {
        return NSLocalizedString("Edit Site", comment: comment)
    }()
    
    public static let patchTitle = {
        return NSLocalizedString("Patch", comment: comment)
    }()
    public static let injectionTitle = {
        return NSLocalizedString("Injection", comment: comment)
    }()
    
    public static let siteTitle = {
        return NSLocalizedString("Site", comment: comment)
    }()

    public static func getTitle(for method: DeliveryMethod) -> String {
        switch method {
        case .Patches:
            return patchesTitle
        case .Injections:
            return injectionsTitle
        }
    }
}
