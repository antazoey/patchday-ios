//
//  PatchDataSDK.swift
//  PDKit
//
//  Created by Juliya Smith on 9/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PatchDataSDK {

	/// If this is the first initialization.
	var isFresh: Bool { get }

	/// The UserDefaults manager.
	var settings: PDSettingsManaging { get }

	/// Hormones schedule.
	var hormones: HormoneScheduling { get }

	/// The Sites schedule.
	var sites: SiteScheduling { get }

	/// The Pills schedule.
	var pills: PillScheduling { get }

	/// The expired hormones count plus the due pills count.
	var totalAlerts: Int { get }

	/// Resets each schedule and the settings back to defaults.
	func resetAll()
}
