//
//  MockSitesTable.swift
//  PDMock
//
//  Created by Juliya Smith on 11/8/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockSitesTable: SitesTableProtocol {

    public init() {}

    public var sites: SiteScheduling?

    public var rowHeight: CGFloat = 0

    public var isEditing: Bool = false

    public var initCallArgs: [UITableView] = []
    public required init(_ table: UITableView) {
        initCallArgs.append(table)
    }

    public var reloadCellsCallCount = 0
    public func reloadCells() {
        reloadCellsCallCount += 1
    }

    public var subscriptCallArgs: [Index] = []
    public var subscriptReturnValue = MockSiteCell()
    public subscript(index: Index) -> SiteCellProtocol {
        subscriptCallArgs.append(index)
        return subscriptReturnValue
    }

    public var toggleEditCallArgs: [Bool] = []
    public func toggleEdit(isEditing: Bool) {
        toggleEditCallArgs.append(isEditing)
    }

    public var turnOffEditingModeCallCount = 0
    public func turnOffEditingMode() {
        turnOffEditingModeCallCount += 1
    }

    public var deleteCellCallArgs: [IndexPath] = []
    public func deleteCell(indexPath: IndexPath) {
        deleteCellCallArgs.append(indexPath)
    }

    public var reloadDataCallCount = 0
    public func reloadData() {
        reloadDataCallCount += 1
    }
}
