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

    open func beforeEach() {}

    open override var continueAfterFailure: Bool {
        get { false }
        set { _ = newValue }
    }

    public override func invokeTest() {
        beforeEach()
        super.invokeTest()
    }
}
