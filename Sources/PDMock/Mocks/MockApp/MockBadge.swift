//
//  MockBadge.swift
//  PDMock
//
//  Created by Juliya Smith on 4/26/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockBadge: PDBadgeReflective {
    public var clearCallCount = 0
    public func clear() { clearCallCount += 1 }
    public init() {}
    public var value: Int = 0
    public var reflectCallCount = 0
    public func reflect() { reflectCallCount += 1 }
}
