//
//  PatchDayTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 4/26/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest

@testable
import PatchDay

class PatchDayTests: XCTestCase {

    /// The sidebar (macOS) and tab bar (iPhone) both render from this single
    /// ordered list, so it must stay in the expected order and cover every
    /// section — otherwise the two shells could silently drift apart.
    func testSidebarOrder_matchesExpectedSectionsInOrder() {
        XCTAssertEqual(AppTab.sidebarOrder, [.hormones, .pills, .sites, .settings])
    }

    func testSidebarOrder_coversEveryTab() {
        XCTAssertEqual(Set(AppTab.sidebarOrder), Set(AppTab.allCases))
        XCTAssertEqual(AppTab.sidebarOrder.count, AppTab.allCases.count)
    }
}
