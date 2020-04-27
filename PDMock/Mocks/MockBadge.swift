//
//  MockBadge.swift
//  PDMock
//
//  Created by Juliya Smith on 4/26/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class MockBadge: PDBadgeDelegate {
    
    public init() {}
    
    public var incrementCallCount = 0
    public func increment() {
        incrementCallCount += 1
    }
    
    public var decrementCallCount = 0
    public func decrement() {
        decrementCallCount += 1
    }
    
    public var setCallArgs: [Int] = []
    public func set(to newBadgeValue: Int) {
        setCallArgs.append(newBadgeValue)
    }
}
