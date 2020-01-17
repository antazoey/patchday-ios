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

    private var sites: SiteSchedule!
    
    override func setUp() {
        sites = SiteSchedule(store: <#T##SiteStoring#>, defaults: <#T##UserDefaultsWriting#>)
    }
}

