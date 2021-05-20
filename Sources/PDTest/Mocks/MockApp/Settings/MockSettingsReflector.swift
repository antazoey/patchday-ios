//
//  MockSettingsReflector.swift
//  PDTest
//
//  Created by Juliya Smith on 5/3/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockSettingsReflector: SettingsReflecting {

    public init() {}

    public var reflectCallCount = 0
    public func reflect() {
        reflectCallCount += 1
    }
}
