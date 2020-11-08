//
//  MockPillsTable.swift
//  PDMock
//
//  Created by Juliya Smith on 11/8/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockPillsTable: PillsTableProtocol {

    public var subscriptCallArgs: [Index] = []
    public var subscriptReturnValue = MockPillCell()
    public subscript(index: Index) -> PillCellProtocol {
        subscriptCallArgs.append(index)
        return subscriptReturnValue
    }

    public var deleteCellCallArgs: [(IndexPath, Int)] = []
    public func deleteCell(at indexPath: IndexPath, pillsCount: Int) {
        deleteCellCallArgs.append((indexPath, pillsCount))
    }

    public var reloadDataCallCount = 0
    public func reloadData() {
        reloadDataCallCount += 1
    }

    public init() {}
}
