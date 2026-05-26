//
//  HormonesViewModelProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.
//

import Foundation

/// Result of a hormone row tap, surfaced to the view so it can present the
/// appropriate UI (SwiftUI confirmationDialog or navigation push) without the
/// VM needing a UIViewController reference.
public enum HormoneTapResult {
    case changeOrEdit(currentSite: SiteName, suggestedSite: SiteName?, change: () -> Void, edit: () -> Void)
    case none
}

public protocol HormonesViewModelProtocol {

    /// The bottom tabs.
    var tabs: TabReflective? { get }

    /// App navigation.
    var nav: NavigationHandling? { get }

    /// The list of Hormone table cells.
    var table: HormonesTableProtocol! { get }

    /// The title of the hormones view.
    var title: String { get }

    /// The amount of expired hormone notifications.
    var expiredHormoneBadgeValue: String? { get }

    /// Update widget data.
    func setWidget()

    /// Present the disclaimer alert that appears on first launch.
    func presentDisclaimerAlertIfFirstLaunch()

    /// True iff the disclaimer alert has not been acknowledged yet.
    var shouldShowDisclaimer: Bool { get }

    /// Mark the disclaimer as acknowledged.
    func acknowledgeDisclaimer()

    /// Reflect hormone site changes in cell images.
    func updateSiteImages()

    /// Handle the user tapping a row by presenting alert actions.
    func handleRowTapped(
        at index: Index, _ hormonesViewController: UIViewController, reload: @escaping () -> Void
    )

    /// SwiftUI-friendly row tap: returns the data the view needs to present a
    /// confirmation dialog. Navigation to detail is the caller's responsibility.
    func handleRowTapped(at index: Index, reload: @escaping () -> Void) -> HormoneTapResult

    /// Resolve a cell view model directly from the SDK without going through
    /// the UIKit cell array. Used by SwiftUI rows.
    func cellViewModel(at index: Index, isPad: Bool) -> HormoneCellViewModelProtocol?

    /// Get a Hormone cell.
    subscript(row: Index) -> HormoneCellProtocol { get }

    /// Navigate to the details view of a hormone.
    func goToHormoneDetails(hormoneIndex: Index, _ hormonesViewController: UIViewController)

    /// Load the bottom tabs (since this is the first view model of the app).
    func loadAppTabs(source: UIViewController)
}
