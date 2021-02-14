//
//  PillTableViewModel.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.

import Foundation

public protocol PillsTableProtocol {
    subscript(index: Index) -> PillCellProtocol { get }
    func deleteCell(at indexPath: IndexPath, pillsCount: Int)
    func reloadData()
}
