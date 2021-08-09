//
//  PillXDaysIntegrationTests.swift
//  PDTest
//
//  Created by Juliya Smith on 8/7/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDTest
import PatchData

@testable
import PatchDay

class PillXDaysIntegrationTests: PillXDaysIntegrationTestCase {

    func testXDaysPillSchedule_simple() {
        runTest(timesaday: 1, daysOne: 2, daysTwo: 2, daysGap: 1)
    }

    func testXDaysPillSchedule_complicated() {
        runTest(timesaday: 2, daysOne: 4, daysTwo: 5, daysGap: 2)
    }
}
