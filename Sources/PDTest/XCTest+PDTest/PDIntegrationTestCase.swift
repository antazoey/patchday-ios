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

let testRunner = DispatchQueue(label: "com.pdtest.pd-integration-test.test-runner")

open class PDIntegrationTestCase: PDTestCase {

    public let dependencies = MockDependencies()
    public let now = MockNow()

    public var sdk: PatchDataSDK {
        if let sdk = dependencies.sdk {
            return sdk
        }
        let mockSDK = MockSDK()
        dependencies.sdk = mockSDK
        return mockSDK
    }

    open override func setUp() {
        dependencies.sdk?.resetAll()
    }

    open override func beforeEach() {
        dependencies.sdk?.resetAll()
    }

    public override func invokeTest() {
        // Only run tests serially and using the simulator.
        #if targetEnvironment(simulator)
        testRunner.sync {
            super.invokeTest()
        }
        #endif
    }
}
