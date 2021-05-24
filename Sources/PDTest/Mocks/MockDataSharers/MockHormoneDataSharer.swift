//
// Created by Juliya Smith on 1/6/20.
// Copyright (c) 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockHormoneDataSharer: HormoneDataSharing, PDMocking {

    public init() { }

    public func resetMock() {
        shareCallArgs = []
    }

    public var shareCallArgs: [Hormonal] = []
    public func share(nextHormone: Hormonal) {
        shareCallArgs.append(nextHormone)
    }
}
