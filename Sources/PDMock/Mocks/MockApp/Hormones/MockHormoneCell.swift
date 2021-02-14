//
//  MockHormoneCell.swift
//  PDMock
//
//  Created by Juliya Smith on 11/8/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockHormoneCell: HormoneCellProtocol, Equatable {

    public static func == (lhs: MockHormoneCell, rhs: MockHormoneCell) -> Bool {
        lhs.id == rhs.id
    }

    public let id = UUID()

    public var configureCallArgs: [HormoneCellViewModelProtocol] = []
    public func configure(_ viewModel: HormoneCellViewModelProtocol) -> HormoneCellProtocol {
        configureCallArgs.append(viewModel)
        return self
    }

    public var reflectSiteImageCallArgs: [SiteImageRecording] = []
    public var reflectSiteImageDoThrow: Bool = false
    public func reflectSiteImage(_ history: SiteImageRecording) throws {
        reflectSiteImageCallArgs.append(history)
        if reflectSiteImageDoThrow {
            throw SiteImageReflectionError.AddWithoutGivenPlaceholderImage
        }
    }

    public init() {}
}
