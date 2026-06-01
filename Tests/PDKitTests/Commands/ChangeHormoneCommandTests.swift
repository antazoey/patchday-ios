//
//  ChangeHormoneCommandTests.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/23/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import XCTest
import PDTest
@testable
import PDKit

class ChangeHormoneCommandTests: PDTestCase {

    private let testId = UUID()
    private var hormones: MockHormoneSchedule!
    private var hormone: MockHormone!
    private var sites: MockSiteSchedule!

    override func setUp() {
        hormone = MockHormone()
        hormone.id = testId
        hormones = MockHormoneSchedule()
        hormones.all = [hormone]
        sites = MockSiteSchedule()
    }

    func testExecute_whenHormoneHasDynamicExpirationTimes_setsDateToNow() {
        hormones.useStaticExpirationTime = false
        let command = createCommand()
        command.execute()
        let callArgs = hormones.setDateByIdCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(callArgs[0].0, testId)
        PDAssertNow(callArgs[0].1)
    }

    func testExecute_whenHormoneHasStaticExpirationTimes_setsDateToNowWithTimeAsExpirationTime() {
        hormones.useStaticExpirationTime = true
        let expirationDate = TestDateFactory.createTestDate(hoursFrom: -54)
        hormone.expiration = expirationDate
        let expected = TestDateFactory.createTestDate(at: expirationDate)
        let command = createCommand()
        command.execute()
        let callArgs = hormones.setDateByIdCallArgs
        XCTAssertEqual(callArgs[0].0, testId)
        PDAssertEquiv(expected, callArgs[0].1)
    }

    func testExecute_whenNoHormone_setsDateToNow() {
        let hormones = MockHormoneSchedule()
        hormones.all = []
        let command = ChangeHormoneCommand(hormones: hormones, sites: sites, hormoneId: testId)
        command.execute()
        let callArgs = hormones.setDateByIdCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(callArgs[0].0, testId)
        PDAssertNow(callArgs[0].1)
    }

    func testExecute_whenHasSuggestedSite_setsSiteToSuggestedSite() {
        let site = MockSite()
        sites.suggested = site
        let command = createCommand()
        command.execute()
        let callArgs = hormones.setSiteByIdCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(testId, callArgs[0].0)
        XCTAssertEqual(site.id, callArgs[0].1.id)
    }

    func testExecute_whenNoSuggestedSite_doesNotSetSite() {
        sites.suggested = nil
        let command = createCommand()
        command.execute()
        PDAssertEmpty(hormones.setSiteByIdCallArgs)
    }

    func testCreateAutoDate_whenGivenFalseForStaticTime_returnsNow() {
        let actual = ChangeHormoneCommand.createAutoDate(hormone: hormone, useStaticTime: false)
        PDAssertNow(actual)
    }

    func testCreateAutoDate_whenGivenTrueForStaticTime_returnsNowAtHormoneExpirationTime() {
        let expirationDate = TestDateFactory.createTestDate(hoursFrom: -54)
        hormone.expiration = expirationDate
        let expected = TestDateFactory.createTestDate(at: expirationDate)
        let actual = ChangeHormoneCommand.createAutoDate(hormone: hormone, useStaticTime: true)
        PDAssertEquiv(expected, actual)
    }

    // MARK: - changeAllHormones (backend "Change all")

    func testChangeAllHormones_whenOnlyDue_changesOnlyExpiredHormones() {
        sites.suggested = MockSite()
        let due1 = MockHormone(); due1.isExpired = true
        let notDue = MockHormone(); notDue.isExpired = false
        let due2 = MockHormone(); due2.isExpired = true
        hormones.all = [due1, notDue, due2]
        let factory = PDCommandFactory(hormones: hormones, sites: sites)

        let changed = factory.changeAllHormones(onlyDue: true)

        XCTAssertEqual([due1.id, due2.id], changed.map { $0.id })
        XCTAssertEqual([due1.id, due2.id], hormones.setSiteByIdCallArgs.map { $0.0 })
        XCTAssertEqual([due1.id, due2.id], hormones.setDateByIdCallArgs.map { $0.0 })
    }

    func testChangeAllHormones_whenNotOnlyDue_changesEveryHormone() {
        sites.suggested = MockSite()
        let h0 = MockHormone() // neither expired
        let h1 = MockHormone()
        hormones.all = [h0, h1]
        let factory = PDCommandFactory(hormones: hormones, sites: sites)

        let changed = factory.changeAllHormones(onlyDue: false)

        XCTAssertEqual([h0.id, h1.id], changed.map { $0.id })
        XCTAssertEqual([h0.id, h1.id], hormones.setDateByIdCallArgs.map { $0.0 })
    }

    func testChangeAllHormones_reloadsSiteContextBeforeChanging() {
        let due = MockHormone(); due.isExpired = true
        hormones.all = [due]
        let factory = PDCommandFactory(hormones: hormones, sites: sites)
        _ = factory.changeAllHormones(onlyDue: true)
        XCTAssertEqual(1, sites.reloadContextCallCount)
    }

    private func createCommand() -> ChangeHormoneCommand {
        ChangeHormoneCommand(hormones: hormones, sites: sites, hormoneId: testId)
    }
}
