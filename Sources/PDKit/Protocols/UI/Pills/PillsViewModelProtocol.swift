//
//  PillsViewModelProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.
//  
//

import Foundation

public protocol PillsViewModelProtocol {
    var tabs: TabReflective? { get }
    var pillsTable: PillsTableProtocol! { get }
    var pills: PillScheduling? { get }
    var pillsCount: Int { get }
    func createPillCellSwipeActions(index: IndexPath) -> UISwipeActionsConfiguration
    func takePill(at index: Index)
    func deletePill(at index: IndexPath)
    func presentPillActions(
        at index: Index, viewController: UIViewController, takePillCompletion: @escaping () -> Void
    )
    func goToNewPillDetails(pillsViewController: UIViewController)
    func goToPillDetails(pillIndex: Index, pillsViewController: UIViewController)
}
