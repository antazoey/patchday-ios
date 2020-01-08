//
// Created by Juliya Smith on 1/6/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class MockHormoneDataBroadcaster: HormoneDataBroadcasting, PDMocking {
    
    public var broadcastedHormoneIds: [String] = []

    public init() {}
    
    public func resetMock() {
        broadcastedHormoneIds = []
    }

    public func broadcast(nextHormone: Hormonal) {
        broadcastedHormoneIds.append(nextHormone.id.uuidString)
    }
}
