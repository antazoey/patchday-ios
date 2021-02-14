//
//  MockPillDataSharer.swift
//  PDMock
//
//  Created by Juliya Smith on 1/18/20.

import Foundation
import PDKit

public class MockPillDataSharer: PDMocking, PillDataSharing {

    public var shareCallArgs: [Swallowable] = []

    public init() { }

    public func share(nextPill: Swallowable) {
        shareCallArgs.append(nextPill)
    }

    public func resetMock() {
        shareCallArgs = []
    }
}
