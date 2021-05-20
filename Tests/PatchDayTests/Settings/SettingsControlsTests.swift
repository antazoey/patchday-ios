//
//  SettingsControlsTests.swift
//  PDTest
//
//  Created by Juliya Smith on 5/4/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDTest

@testable
import PatchDay

class SettingsControlsTests: XCTestCase {

    private let helper = SettingsTestHelper()

    func testReflect_whenGivenPatches_enablesQuantityButtons() {
        let controls = helper.createControls()
        controls.reflect(method: .Patches)
        XCTAssertTrue(controls.quantityButton.isEnabled)
        XCTAssertTrue(controls.quantityArrowButton.isEnabled)
    }

    func testReflect_whenGivenInjections_disablesQuantityButtons() {
        let controls = helper.createControls()
        controls.reflect(method: .Injections)
        XCTAssertFalse(controls.quantityButton.isEnabled)
        XCTAssertFalse(controls.quantityArrowButton.isEnabled)
    }

    func testReflect_whenGivenGel_disablesQuantityButtons() {
        let controls = helper.createControls()
        controls.reflect(method: .Gel)
        XCTAssertFalse(controls.quantityButton.isEnabled)
        XCTAssertFalse(controls.quantityArrowButton.isEnabled)
    }
}
