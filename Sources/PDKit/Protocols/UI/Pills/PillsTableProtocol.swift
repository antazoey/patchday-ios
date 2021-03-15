//
//  PillsTableProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.

import Foundation

public protocol PillsTableProtocol {

    /// Get a cell.
    subscript(index: Index) -> PillCellProtocol { get }

    /// Deletes a cell.
    func deleteCell(at indexPath: IndexPath, pillsCount: Int)

    /// Reloads the data.
    /// Note:  It is usually better to just call this from the view controller on the actual `UITableView`.
    func reloadData()

    /// Sets a label as the empty view or blank when not empty.
    func setBackgroundView(isEnabled: Bool)
}
