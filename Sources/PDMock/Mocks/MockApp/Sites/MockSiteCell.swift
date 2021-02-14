//
//  MockSiteCell.swift
//  PDMock
//
//  Created by Juliya Smith on 11/8/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockSiteCell: SiteCellProtocol {

    public init() {}

    public var configureCallArgs: [SiteCellProperties] = []
    public func configure(props: SiteCellProperties) -> SiteCellProtocol {
        configureCallArgs.append(props)
        return self
    }

    public var backgroundColor: UIColor?
}
