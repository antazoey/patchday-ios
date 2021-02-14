//
//  SitesTableProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public protocol SitesTableProtocol {
    var sites: SiteScheduling? { get set }
    var rowHeight: CGFloat { get }
    var isEditing: Bool { get }
    init(_ table: UITableView)
    func reloadCells()
    subscript(index: Index) -> SiteCellProtocol { get }
    func toggleEdit(isEditing: Bool)
    func turnOffEditingMode()
    func deleteCell(indexPath: IndexPath)
    func reloadData()
}
