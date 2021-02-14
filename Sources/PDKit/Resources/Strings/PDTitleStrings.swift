//
//  ViewTitleStrings.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/15/19.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public class PDTitleStrings {

    private static let c = "Title of a view controller. Keep it brief please."

    public static var PatchesTitle: String { NSLocalizedString("Patches", comment: c) }
    public static var EditHormoneTitle: String { NSLocalizedString("Edit Hormone", comment: c)}
    public static var InjectionsTitle: String { NSLocalizedString("Injections", comment: c) }
    public static var GelTitle: String { NSLocalizedString("Gel", comment: c)}
    public static var HormonesTitle: String { NSLocalizedString("Hormones", comment: c) }
    public static var SettingsTitle: String { NSLocalizedString("Settings", comment: c) }
    public static var PillsTitle: String { NSLocalizedString("Pills", comment: c) }
    public static var PillTitle: String { NSLocalizedString("Pill", comment: c) }
    public static var EditPillTitle: String { NSLocalizedString("Edit Pill", comment: c) }
    public static var NewPillTitle: String { NSLocalizedString("New Pill", comment: c) }
    public static var SitesTitle: String { NSLocalizedString("Sites", comment: c) }
    public static var EditSiteTitle: String { NSLocalizedString("Edit Site", comment: c) }
    public static var PatchTitle: String { NSLocalizedString("Patch", comment: c) }
    public static var InjectionTitle: String { NSLocalizedString("Injection", comment: c) }
    public static var SiteTitle: String { NSLocalizedString("Site", comment: c) }

    public class Hormones {
        public static subscript(method: DeliveryMethod) -> String {
            switch method {
                case .Patches: return PatchesTitle
                case .Injections: return InjectionsTitle
                case .Gel: return GelTitle
            }
        }
    }

    public class Hormone {
        public static subscript(method: DeliveryMethod) -> String {
            switch method {
                case .Patches: return PatchTitle
                case .Injections: return InjectionTitle
                case .Gel: return GelTitle
            }
        }
    }
}
