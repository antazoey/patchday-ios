//
//  PillsViewModelProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.

import Foundation

public protocol PillsViewModelProtocol {

    /// The tabs object for setting badge values and icons accordingly.
    var tabs: TabReflective? { get }

    /// The table protocol for the pills.
    var pillsTable: PillsTableProtocol! { get }

    /// The `PatchData.PillSchedule` object containing pill-data and methods.
    var pills: PillScheduling? { get }

    /// The number of pills in the schedule.
    var pillsCount: Int { get }

    /// Whether the pills are enabled or not.
    var enabled: Bool { get }

    /// A factory method for cell swip actions.
    func createPillCellSwipeActions(index: IndexPath) -> UISwipeActionsConfiguration

    /// Take a pill for the day.
    func takePill(at index: Index)

    /// Delete a pill from the schedule.
    func deletePill(at index: IndexPath)

    /// Present actions (an alert) that you can take on a pill.
    func presentPillActions(
        at index: Index, viewController: UIViewController, takePillCompletion: @escaping () -> Void
    )

    /// Navigate to the details view of a new pill.
    func goToNewPillDetails(pillsViewController: UIViewController)

    /// Navigate to the Details view of a pill.
    func goToPillDetails(pillIndex: Index, pillsViewController: UIViewController)

    /// Change the `pillsEnabled` setting.
    func togglePillsEnabled(_ toggledOn: Bool)

    /// Set the table background view accordingly depending on the value of `enabled`.
    func setBackgroundView()
}
