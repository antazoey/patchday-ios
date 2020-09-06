//
//  MockTabs.swift
//  PDMock
//
//  Created by Juliya Smith on 5/10/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockTabs: TabReflective {

    public init() {}

    public var hormonesVC: UIViewController?

    public var pillsVC: UIViewController?

    public var sitesVC: UIViewController?

    public var reflectCallCount = 0
    public func reflect() {
        reflectCallCount += 1
    }

    public var reflectHormonesCallCount = 0
    public func reflectHormones() {
        reflectHormonesCallCount += 1
    }

    public var reflectPillsCallCount = 0
    public func reflectPills() {
        reflectPillsCallCount += 1
    }
}
