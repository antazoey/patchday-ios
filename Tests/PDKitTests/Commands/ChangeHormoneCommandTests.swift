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
        X
        PDAssertNow(<#T##actual: Date##Date#>)
    }

    private func createCommand() -> ChangeHormoneCommand {
        ChangeHormoneCommand(hormones: hormones, sites: sites, hormoneId: testId)
    }
}
