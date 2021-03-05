//
// Created by Juliya Smith on 2/10/20.
// Copyright (c) 2021 Juliya Smith. All rights reserved.
//

import XCTest
import Foundation
import PDKit
import PDMock

@testable
import PatchData

class LoggingPlayground: XCTestCase {

    func logHormone() {
        var data = HormoneStruct(UUID())
        data.date = Date()
        data.siteRelationshipId = UUID()
        data.siteName = "Left Delt"
        data.siteNameBackUp = "Left Delt"
        let settings = MockSettings()
        let hormone = Hormone(hormoneData: data, settings: settings)
        PDObjectLogger.logHormone(hormone)
    }

    func logPill() {
        let attributes = PillAttributes()
        attributes.name = "Prolactin"
        attributes.notify = true
        attributes.lastTaken = Date(timeIntervalSinceNow: -2342652)
        attributes.times = "12:00:00,5:00:00"
        attributes.timesTakenToday = 0
        let pill = Pill(pillData: PillStruct(UUID(), attributes))
        PDObjectLogger.logPill(pill)
    }

    func logSite() {
        var data = SiteStruct(UUID())
        data.order = 2
        data.name = "Right Abdomen"
        data.imageIdentifier = "Right Abdomen"
        data.hormoneRelationshipIds = [UUID(), UUID()]
        let site = Site(siteData: data)
        PDObjectLogger.logSite(site)
    }

    func testLogging() {
        logHormone()
        print()
        logPill()
        print()
        logSite()
    }
}
