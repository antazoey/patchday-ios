//
//  PillTableViewModel.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PillsTableProtocol {
    subscript(index: Index) -> PillCellProtocol { get }
    func deleteCell(at indexPath: IndexPath, pillsCount: Int)
    func reloadData()
}
