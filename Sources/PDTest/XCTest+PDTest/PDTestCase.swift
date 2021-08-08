//
//  PDTest.swift
//  PDTest
//
//  Created by Juliya Smith on 8/7/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import XCTest
import PDKit

open class PDTestCase: XCTestCase {

    private var _continueAfterFailure = false

    open func beforeEach() {}

    open override var continueAfterFailure: Bool {
        get { _continueAfterFailure }
        set { _continueAfterFailure = newValue }
    }

    public override func invokeTest() {
        beforeEach()
        super.invokeTest()
    }
}
