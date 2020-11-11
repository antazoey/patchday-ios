//
//  MockAlert.swift
//  PDMock
//
//  Created by Juliya Smith on 6/14/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockAlert: PDAlerting {
    public init() {}

    public var presentCallArgs: [[UIAlertAction]] = []
    public func present(actions: [UIAlertAction]) {
        presentCallArgs.append(actions)
    }

    public var presentCallCount = 0
    public func present() {
        presentCallCount += 1
    }
}
