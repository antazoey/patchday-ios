//
// Created by Juliya Smith on 1/6/20.
// Copyright (c) 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockHormoneDataSharer: HormoneDataSharing, PDMocking {

    public var shareedHormoneIds: [String] = []

    public init() { }

    public func resetMock() {
        shareedHormoneIds = []
    }

    public func share(nextHormone: Hormonal) {
        shareedHormoneIds.append(nextHormone.id.uuidString)
    }
}
