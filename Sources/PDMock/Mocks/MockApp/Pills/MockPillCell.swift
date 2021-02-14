//
//  MockPillCell.swift
//  PDMock
//
//  Created by Juliya Smith on 11/8/20.

import Foundation
import PDKit

public class MockPillCell: PillCellProtocol {

    public var configureCallArgs: [PillCellConfigurationParameters] = []
    public func configure(_ params: PillCellConfigurationParameters) -> PillCellProtocol {
        configureCallArgs.append(params)
        return self
    }

    public var loadBackgroundCallCount = 0
    public func loadBackground() {
        loadBackgroundCallCount += 1
    }

    public init() {}
}
