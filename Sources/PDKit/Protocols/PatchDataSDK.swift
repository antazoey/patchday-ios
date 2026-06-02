//
//  PatchDataSDK.swift
//  PDKit
//
//  Created by Juliya Smith on 9/10/19.

import Foundation

public protocol PatchDataSDK {

    /// If this is the first initialization.
    var isFresh: Bool { get }

    /// The UserDefaults manager.
    var settings: SettingsManaging { get }

    /// Hormones schedule.
    var hormones: HormoneScheduling { get }

    /// The Sites schedule.
    var sites: SiteScheduling { get }

    /// The Pills schedule.
    var pills: PillScheduling { get }

    /// The expired hormones count plus the due pills count.
    var totalAlerts: Int { get }

    /// Create reusable commands that are common in PatchData.
    var commandFactory: PDCommandFactory { get }

    /// Reset each schedule and the settings back to defaults.
    func resetAll()

    /// Write the next suggested site into shared storage so the widget can show
    /// where the next patch should go. (Hormones/sites don't know about each
    /// other, so the SDK — which has both — shares it.)
    func shareSuggestedSite()
}
