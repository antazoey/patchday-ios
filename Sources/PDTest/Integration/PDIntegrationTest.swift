//
//  PDIntegrationTest.swift
//  PDTest
//
//  Created by Juliya Smith on 8/7/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit
import XCTest

public class PDIntegrationTest: PDTest {

    private let dependencies: MockDependencies

    public init(dependencies: MockDependencies) {
        self.dependencies = dependencies
        super.init()
    }

    public override func setUp() {
        dependencies.sdk?.resetAll()
    }

    public override func beforeEach() {
        dependencies.sdk?.resetAll()
    }
}
