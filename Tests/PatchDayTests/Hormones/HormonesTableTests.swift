//
//  HormonesTableTests.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/11/20.
//  
//

import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class HormonesTableTests: XCTestCase {
    func testApplyTheme_appliesExpectedColors() {
        let view = UITableView()
        let table = HormonesTable(view, MockSDK(), .dark)
        table.applyTheme()
        XCTAssertEqual(UIColor.systemBackground, view.backgroundColor)
        XCTAssertEqual(PDColors[.Border], view.separatorColor)
    }
}
