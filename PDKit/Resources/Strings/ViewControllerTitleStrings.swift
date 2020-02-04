//
//  VCTitleStrings.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/15/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public class VCTitleStrings {
    
    private static let c = "Title of a view controller. Keep it brief please."

    public static let PatchesTitle = { NSLocalizedString("Patches", comment: c) }()
    public static let InjectionsTitle = { NSLocalizedString("Injections", comment: c) }()
    public static let HormonesTitle = { NSLocalizedString("Hormones", comment: c) }()
    public static let SettingsTitle = { NSLocalizedString("Settings", comment: c) }()
    public static let PillsTitle = { NSLocalizedString("Pills", comment: c) }()
    public static let PillTitle = { NSLocalizedString("Pill", comment: c) }()
    public static let EditPillTitle = { NSLocalizedString("Edit Pill", comment: c) }()
    public static let NewPillTitle = { NSLocalizedString("New Pill", comment: c) }()
    public static let SitesTitle = { NSLocalizedString("Sites", comment: c) }()
    public static let PatchSitesTitle = { NSLocalizedString("Patch Sites", comment: c) }()
    public static let InjectionSitesTitle = { NSLocalizedString("Injection Sites", comment: c) }()
    public static let EditSiteTitle = { NSLocalizedString("Edit Site", comment: c) }()
    public static let PatchTitle = { NSLocalizedString("Patch", comment: c) }()
    public static let InjectionTitle = { NSLocalizedString("Injection", comment: c) }()
    public static let SiteTitle = { NSLocalizedString("Site", comment: c) }()

    public static func getTitle(for method: DeliveryMethod) -> String {
        switch method {
        case .Patches: return PatchesTitle
        case .Injections: return InjectionsTitle
        }
    }
    
    public static func getSitesTitle(for method: DeliveryMethod) -> String {
        switch method {
        case .Patches: return PatchSitesTitle
        case .Injections: return InjectionSitesTitle
        }
    }
}
