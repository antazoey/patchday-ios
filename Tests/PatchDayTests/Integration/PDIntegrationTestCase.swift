//
//  PDIntegrationTest.swift
//  PDTest
//
//  Created by Juliya Smith on 8/7/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit
import PatchData
import PDTest
import XCTest

open class PDIntegrationTestCase: PDSerialTestCase {

    public let dependencies = MockDependencies(sdk: PatchData())
    public let now = MockNow()

    public var sdk: PatchDataSDK {
        if let sdk = dependencies.sdk {
            return sdk
        }
        let sdk = PatchData()
        dependencies.sdk = sdk
        return sdk
    }

    open override func setUp() {
        resetSDK()
    }

    open override func beforeEach() {
        resetSDK()
    }

    private func resetSDK() {
        let sdk = PatchData()
        sdk.resetAll()
        dependencies.sdk = sdk
    }
}
