//
//  PDSerialTest.swift
//  PDTest
//
//  Created by Juliya Smith on 8/8/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

let testRunner = DispatchQueue(label: "com.pdtest.serial-runner")

open class PDSerialTestCase: PDTestCase {
    public override func invokeTest() {

        // Only run tests serially and using the simulator.
        #if targetEnvironment(simulator)
        testRunner.sync(flags: .barrier) {
            super.invokeTest()
        }
        #endif
    }
}
