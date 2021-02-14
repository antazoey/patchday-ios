//
//  MockHormonesTable.swift
//  PDMock
//
//  Created by Juliya Smith on 11/8/20.

import Foundation
import PDKit

public class MockHormonesTable: HormonesTableProtocol {

    public init() {}

    public var getCellRowHeightCallArgs: [CGFloat] = []
    public var getCellRowHeightReturnValue: CGFloat = 0.0
    public func getCellRowHeight(viewHeight: CGFloat) -> CGFloat {
        getCellRowHeightCallArgs.append(viewHeight)
        return getCellRowHeightReturnValue
    }

    public var applyThemeCallCount = 0
    public func applyTheme() {
        applyThemeCallCount += 1
    }

    public var reflectModelCallCount = 0
    public func reflectModel() {
        reflectModelCallCount += 1
    }

    public var reloadDataCallCount = 0
    public func reloadData() {
        reloadDataCallCount += 1
    }

    public var cells: [HormoneCellProtocol] = []
}
