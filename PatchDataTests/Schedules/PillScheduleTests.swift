//
//  PillScheduleTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 1/15/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchData


class PillScheduleTests: XCTestCase {

    private var pills: PillSchedule!
    
    override func setUp() {
        pills = PillSchedule(
            coreDataStack: <#T##PDCoreDataDelegate#>,
            pillDataSharer: <#T##DataSharing#>,
            state: PillSchedule.PillScheduleState
        )
    }
}
