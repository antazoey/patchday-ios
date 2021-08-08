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

    func testXDaysPillSchedule_whenTimesadayOneDaysOneTwoDaysTwoTwoAndDaysGapOne() {
        runTest(timesaday: 1, daysOne: 2, daysTwo: 2, daysGap: 1)
    }
}
