//
//  SiteScheduledTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 1/16/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchData


class SiteScheduleTests: XCTestCase {

    private var mockStore: MockSiteStore!
    private var mockDefaults: MockUserDefaultsWriter!
    private var sites: SiteSchedule!
    
    override func setUp() {
        mockStore = MockSiteStore()
        mockDefaults = MockUserDefaultsWriter()
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults)
    }
}

