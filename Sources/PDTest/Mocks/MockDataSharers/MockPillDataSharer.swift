//
//  MockPillDataSharer.swift
//  PDTest
//
//  Created by Juliya Smith on 1/18/20.

import Foundation
import PDKit

public class MockPillDataSharer: PDTesting, PillDataSharing {

    public var shareCallArgs: [Swallowable] = []

    public init() { }

    public func share(nextPill: Swallowable) {
        shareCallArgs.append(nextPill)
    }

    public func resetMock() {
        shareCallArgs = []
    }
}
