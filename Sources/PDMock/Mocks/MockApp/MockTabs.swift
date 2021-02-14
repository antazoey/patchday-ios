//
//  MockTabs.swift
//  PDMock
//
//  Created by Juliya Smith on 5/10/20.
//  
//

import Foundation
import PDKit

public class MockTabs: TabReflective {

    public init() {}

    public var hormonesViewController: UIViewController?

    public var pillsViewController: UIViewController?

    public var sitesViewController: UIViewController?

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
