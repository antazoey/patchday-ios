//
//  HormonesViewModelProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.

import Foundation

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

    /// Reflect hormone site changes in cell images.
    func updateSiteImages()

    /// Handle the user tapping a row by presenting alert actions.
    func handleRowTapped(
        at index: Index, _ hormonesViewController: UIViewController, reload: @escaping () -> Void
    )

    /// Get a Hormone cell.
    subscript(row: Index) -> HormoneCellProtocol { get }

    /// Navigate to the details view of a hormone.
    func goToHormoneDetails(hormoneIndex: Index, _ hormonesViewController: UIViewController)

    /// Load the bottom tabs (since this is the first view model of the app).
    func loadAppTabs(source: UIViewController)
}
