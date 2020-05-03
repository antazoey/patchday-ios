//
//  ViewTitleStrings.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/15/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public class ViewTitleStrings {

	private static let c = "Title of a view controller. Keep it brief please."

	public static var PatchesTitle: String { NSLocalizedString("Patches", comment: c) }
	public static var InjectionsTitle: String { NSLocalizedString("Injections", comment: c) }
	public static var GelTitle: String { NSLocalizedString("Gel", comment: c)}
	public static var HormonesTitle: String { NSLocalizedString("Hormones", comment: c) }
	public static var SettingsTitle: String { NSLocalizedString("Settings", comment: c) }
	public static var PillsTitle: String { NSLocalizedString("Pills", comment: c) }
	public static var PillTitle: String { NSLocalizedString("Pill", comment: c) }
	public static var EditPillTitle: String { NSLocalizedString("Edit Pill", comment: c) }
	public static var NewPillTitle: String { NSLocalizedString("New Pill", comment: c) }
	public static var SitesTitle: String { NSLocalizedString("Sites", comment: c) }
	public static var PatchSitesTitle: String { NSLocalizedString("Patch Sites", comment: c) }
	public static var InjectionSitesTitle: String { NSLocalizedString("Injection Sites", comment: c) }
	public static var GelSitesTitle: String { NSLocalizedString("Gel Sites", comment: c) }
	public static var EditSiteTitle: String { NSLocalizedString("Edit Site", comment: c) }
	public static var PatchTitle: String { NSLocalizedString("Patch", comment: c) }
	public static var InjectionTitle: String { NSLocalizedString("Injection", comment: c) }
	public static var SiteTitle: String { NSLocalizedString("Site", comment: c) }

	public static func getTitle(for method: DeliveryMethod) -> String {
		switch method {
			case .Patches: return PatchesTitle
			case .Injections: return InjectionsTitle
			case .Gel: return GelTitle
			default: return HormonesTitle
		}
	}

	public static func getSitesTitle(for method: DeliveryMethod) -> String {
		switch method {
			case .Patches: return PatchSitesTitle
			case .Injections: return InjectionSitesTitle
			case .Gel: return GelSitesTitle
			default: return SitesTitle
		}
	}
}
