//
//  ChangeHormoneCommandTests.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/23/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDTest

import XCTest
@testable
import PDKit

class ChangeHormoneCommandTests: XCTestCase {

    private let testId = UUID()
    private var hormones: MockHormoneSchedule!
    private var sites: MockSiteSchedule!

    override func setUp() {
        hormones = MockHormoneSchedule()
        sites = MockSiteSchedule()
    }

    func testExecute_whenHormoneHasDynamicExpirationTimes_setsDateToNow() {
        let command = createCommand()
        command.execute()
        let callArgs = hormones.setDateByIdCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(callArgs[0].0, testId)
        PDAssertNow(callArgs[0].1)
    }

    private func createCommand() -> ChangeHormoneCommand {
        ChangeHormoneCommand(hormones: hormones, sites: sites, hormoneId: testId)
    }
}
