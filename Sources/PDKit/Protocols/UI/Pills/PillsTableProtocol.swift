//
//  PillsTableProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.

import Foundation

public protocol PillsTableProtocol {

    /// Get a cell.
    subscript(index: Index) -> PillCellProtocol { get }

    /// Delete a cell.
    func deleteCell(at indexPath: IndexPath, pillsCount: Int)

    /// Reload data from the table data-source.
    /// Note:  It is usually better to just call this from the view controller on the actual `UITableView`.
    func reloadData()

    /// Set a label as the empty view or blank when not empty.
    func setBackgroundView(isEnabled: Bool)
}
