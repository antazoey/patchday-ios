//
//  MockHormoneCell.swift
//  PDMock
//
//  Created by Juliya Smith on 11/8/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockHormoneCell: HormoneCellProtocol {

    public var configureCallArgs: [HormoneCellViewModelProtocol] = []
    public func configure(_ viewModel: HormoneCellViewModelProtocol) -> HormoneCellProtocol {
        configureCallArgs.append(viewModel)
        return self
    }

    public var reflectSiteImageCallArgs: [SiteImageRecording] = []
    public func reflectSiteImage(_ history: SiteImageRecording) throws {
        reflectSiteImageCallArgs.append(history)
    }

    public init() {}
}
