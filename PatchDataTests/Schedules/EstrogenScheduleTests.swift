//
//  EstrogenScheduleTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 1/1/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
@testable import PatchData

class EstrogenScheduleTests: XCTestCase {
    
    private var estrogenSchedule: EstrogenSchedule!
    private var siteSchedule: SiteSchedule!
    private var defaults: PDDefaults!

    override func setUp() {
        super.setUp()
        PatchData.useTestContainer()
        estrogenSchedule = EstrogenSchedule()
        siteSchedule = SiteSchedule()
        defaults = PDDefaults(estrogenSchedule: estrogenSchedule,
                              siteSchedule: siteSchedule,
                              state: PDState(),
                              sharedData: nil,
                              alerter: nil)
        defaults.setDeliveryMethod(to: "Patches")
    }
    
    override func tearDown() {
        super.tearDown()
        estrogenSchedule.delete(after: -1)
    }

    func testCount() {
        defaults.setDeliveryMethod(to: "Patches")
        XCTAssertEqual(estrogenSchedule.count(), 3)
        let _ = estrogenSchedule.insert()
        XCTAssertEqual(estrogenSchedule.count(), 4)
    }
    
    func testInsert() {
        estrogenSchedule.delete(after: -1)
        for _ in 0..<50 {
            let _ = estrogenSchedule.insert()
        }
        XCTAssertEqual(estrogenSchedule.count(), 50)
    }
    
    func testSort() {
        if let newEstro = estrogenSchedule.getEstrogen(at: 0) as MOEstrogen? {
            XCTAssertNil(newEstro.getDate())
        }
        estrogenSchedule.delete(after: -1)
        let youngestDate = Date(timeIntervalSince1970: 7000000) as NSDate
        let youngest = estrogenSchedule.insert() as? MOEstrogen
        youngest?.setDate(youngestDate)
        let oldestDate = Date(timeIntervalSince1970: 0) as NSDate
        let oldest = estrogenSchedule.insert() as? MOEstrogen
        oldest?.setDate(oldestDate)
        let middleDate = Date(timeIntervalSince1970: 10000) as NSDate
        let middle = estrogenSchedule.insert() as? MOEstrogen
        middle?.setDate(middleDate)
        estrogenSchedule.sort()
        if let estro1 = estrogenSchedule.getEstrogen(at: 0),
            let estro2 = estrogenSchedule.getEstrogen(at: 1),
            let estro3 = estrogenSchedule.getEstrogen(at: 2) {
            XCTAssert(estro1 < estro2)
            XCTAssert(estro2 < estro3)
            estro1.setDate(youngestDate)
            estrogenSchedule.sort()
            if let estro4 = estrogenSchedule.getEstrogen(at: 0) {
                XCTAssertEqual(estro4.getDate(), middleDate)
            } else {
                XCTFail()
            }
        } else {
            XCTFail()
        }
    }
    
    func testReset() {
        defaults.setDeliveryMethod(to: "Patches")
        estrogenSchedule.reset() {
            self.defaults.setQuantityWithoutWarning(to: 3)
            let sched = EstrogenSchedule()
            XCTAssertEqual(sched.count(), self.estrogenSchedule.count())
            XCTAssert(self.estrogenSchedule.isEmpty())
        }
        XCTAssertEqual(estrogenSchedule.count(), 3)
        defaults.setDeliveryMethod(to: "Injections")
        XCTAssertEqual(estrogenSchedule.count(), 1)
    }
    
    func testNew() {
        let estros_start = estrogenSchedule.estrogens
        let _ = estrogenSchedule.insert()
        // estros_middle has 1 extra
        let estros_middle = estrogenSchedule.estrogens
        XCTAssertNotEqual(estros_start, estros_middle)
        estrogenSchedule.new()
        let estros_end = estrogenSchedule.estrogens
        XCTAssertEqual(estros_start.count, estros_end.count)
    }
    
    func testDeleteAfterIndex() {
        let _ = estrogenSchedule.insert()
        XCTAssertEqual(estrogenSchedule.count(), 4)
        estrogenSchedule.delete(after: 1)
        XCTAssertEqual(estrogenSchedule.count(), 2)
        // No change when index too high
        estrogenSchedule.delete(after: 1)
        XCTAssertEqual(estrogenSchedule.count(), 2)
        // Negative numbers will erase it all
        estrogenSchedule.delete(after: -2000)
        XCTAssertEqual(estrogenSchedule.count(), 0)
        let _ = estrogenSchedule.insert()
        XCTAssertEqual(estrogenSchedule.count(), 1)
        estrogenSchedule.delete(after: 0)
        XCTAssertEqual(estrogenSchedule.count(), 1)
        estrogenSchedule.delete(after: -1)
        XCTAssertEqual(estrogenSchedule.count(), 0)
    }
    
    func testGetEstrogenAtIndex() {
        var actual = estrogenSchedule.getEstrogen(at: 0)
        let expected = estrogenSchedule.estrogens[0]
        XCTAssertEqual(actual, expected)
        actual = estrogenSchedule.getEstrogen(at: -1)
        XCTAssertNil(actual)
    }
    
    func testGetEstrogenForId() {
        if let id = estrogenSchedule.estrogens[0].getId() {
            let actual = estrogenSchedule.getEstrogen(for: id)
            let expected = estrogenSchedule.estrogens[0]
            XCTAssertEqual(actual, expected)
        } else {
            XCTFail()
        }
        let newId = UUID()
        let actual = estrogenSchedule.getEstrogen(for: newId)
        XCTAssertNil(actual)
    }
    
    func testSetSite() {
        if let site = siteSchedule.getSite(at: 3) {
            let e = expectation(description: "Setter was called.")
            estrogenSchedule.setSite(of: 0, with: site) {
                e.fulfill()
            }
            wait(for: [e], timeout: 3)
            let actual = estrogenSchedule.getEstrogen(at: 0)?.getSite()
            XCTAssertEqual(actual, site)
        } else {
            XCTFail()
        }
    }
    
    func testSetDate() {
        let d = Date(timeIntervalSince1970: 234534624)
        let e = expectation(description: "Shared data was set.")
        estrogenSchedule.setDate(of: 0, with: d) {
            e.fulfill()
        }
        wait(for: [e], timeout: 3)
        let actual = estrogenSchedule.getEstrogen(at: 0)?.getDate()
        XCTAssertEqual(actual, d as NSDate)
    }
    
    func testSetEstrogen() {
        let d = Date(timeIntervalSince1970: 234534624) as NSDate
        if let estro = estrogenSchedule.getEstrogen(at: 0),
            let site = siteSchedule.getSite(at: 3),
            let id = estro.getId() {
            let e = expectation(description: "Shared data was set.")
            estrogenSchedule.setEstrogen(for: id,
                                         date: d,
                                         site: site) { e.fulfill() }
            wait(for: [e], timeout: 3)
            XCTAssertEqual(estro.getDate(), d)
            XCTAssertEqual(estro.getSite(), site)
            XCTAssertEqual(estro.getId(), id)
        } else {
            XCTFail()
        }
    }
    
    func testSetBackupSiteName() {
        if let site = siteSchedule.getSite(at: 0) {
            estrogenSchedule.setSite(of: 0, with: site, setSharedData: nil)
            let expected = site.getName()
            siteSchedule.delete(at: 0)
            var actual = estrogenSchedule.getEstrogen(at: 0)?.getSiteName()
            XCTAssertEqual(actual, expected)
            estrogenSchedule.setBackUpSiteName(of: 0, with: "SITE NAME")
            actual = estrogenSchedule.getEstrogen(at: 0)?.getSiteName()
            XCTAssertEqual(actual, "SITE NAME")
        } else {
            XCTFail()
        }
    }
    
    func testGetIndex() {
        if let estro = estrogenSchedule.getEstrogen(at: 0) {
            let actual = estrogenSchedule.getIndex(for: estro)
            XCTAssertEqual(actual, 0)
        } else {
            XCTFail()
        }
        // TODO: Find a way to test an estrogen in another schedule
        // Currently, estrogens are loaded from the same context,
        // So multiple schedule is not really supported yet
    }
    
    func testNextDue() {
        let oldest = Date(timeIntervalSince1970: 0)
        let middle = Date(timeIntervalSince1970: 100000)
        let newest = Date(timeIntervalSince1970: 9999999)
        estrogenSchedule.setDate(of: 0, with: middle, setSharedData: nil)
        estrogenSchedule.setDate(of: 1, with: oldest, setSharedData: nil)
        estrogenSchedule.setDate(of: 2, with: newest, setSharedData: nil)
        let actual = estrogenSchedule.nextDue()?.getDate()
        let expected = oldest as NSDate
        XCTAssertEqual(actual, expected)
    }
    
    func testDatePlacedCount() {
        estrogenSchedule.setDate(of: 0, with: Date(), setSharedData: nil)
        estrogenSchedule.setDate(of: 1, with: Date(), setSharedData: nil)
        var actual = estrogenSchedule.datePlacedCount()
        var expected = 2
        XCTAssertEqual(actual, expected)
        estrogenSchedule.setDate(of: 2, with: Date(), setSharedData: nil)
        actual = estrogenSchedule.datePlacedCount()
        expected = 3
        XCTAssertEqual(actual, expected)
    }
    
    func testHasNoDates() {
        XCTAssert(estrogenSchedule.hasNoDates())
        estrogenSchedule.setDate(of: 0, with: Date(), setSharedData: nil)
        XCTAssertFalse(estrogenSchedule.hasNoDates())
    }
    
    func testHasNoSites() {
        XCTAssert(estrogenSchedule.hasNoSites())
        if let site = siteSchedule.getSite(at: 0) {
            estrogenSchedule.setSite(of: 0, with: site, setSharedData: nil)
            XCTAssertFalse(estrogenSchedule.hasNoSites())
        } else {
            XCTFail()
        }
        estrogenSchedule.new()
        XCTAssert(estrogenSchedule.estrogens.count > 0)
        XCTAssert(estrogenSchedule.hasNoSites())
        estrogenSchedule.setBackUpSiteName(of: 0, with: "SITE NAME")
        XCTAssertFalse(estrogenSchedule.hasNoSites())
    }
    
    func testIsEmpty() {
        XCTAssert(estrogenSchedule.isEmpty())
        estrogenSchedule.setDate(of: 0, with: Date(), setSharedData: nil)
        XCTAssertFalse(estrogenSchedule.isEmpty())
        estrogenSchedule.new()
        if let site = siteSchedule.getSite(at: 0) {
            estrogenSchedule.setSite(of: 0, with: site, setSharedData: nil)
            XCTAssertFalse(estrogenSchedule.isEmpty())
        } else {
            XCTFail()
        }
        estrogenSchedule.new()
        if let site = siteSchedule.getSite(at: 0) {
            estrogenSchedule.setSite(of: 0, with: site, setSharedData: nil)
            estrogenSchedule.setDate(of: 0, with: Date(), setSharedData: nil)
            XCTAssertFalse(estrogenSchedule.isEmpty())
        } else {
            XCTFail()
        }
    }
    
    func testIsEmptyFromThisIndexOnward() {
        XCTAssert(estrogenSchedule.isEmpty(fromThisIndexOnward: 0, lastIndex: 2))
        estrogenSchedule.setBackUpSiteName(of: 0, with: "SITE NAME")
        XCTAssertFalse(estrogenSchedule.isEmpty(fromThisIndexOnward: 0, lastIndex: 2))
        XCTAssert(estrogenSchedule.isEmpty(fromThisIndexOnward: 1, lastIndex: 2))
    }
    
    func testTotalDue() {
        let intervals = PDStrings.PickerData.expirationIntervals
        let oldDate = Date(timeIntervalSince1970: 0)
        let now = Date()
        let halfweek: TimeInterval = 302400
        let week: TimeInterval = 2 * halfweek
        let twoweeks: TimeInterval = 2 * week
        estrogenSchedule.setDate(of: 0, with: oldDate, setSharedData: nil)
        XCTAssertEqual(estrogenSchedule.totalDue("ANY"), 1)
        estrogenSchedule.setDate(of: 0, with: now, setSharedData: nil)
        XCTAssertEqual(estrogenSchedule.totalDue("ANY"), 0)
        // Halfweek just past due
        var d1 = Date(timeInterval: -halfweek-10, since: now)
        estrogenSchedule.setDate(of: 0, with: d1, setSharedData: nil)
        XCTAssertEqual(estrogenSchedule.totalDue(intervals[0]), 1)
        // Halfweek not quite due yet
        d1 = Date(timeInterval: -halfweek+10, since: now)
        estrogenSchedule.setDate(of: 0, with: d1, setSharedData: nil)
        XCTAssertEqual(estrogenSchedule.totalDue(intervals[0]), 0)
        // Week just past due
        d1 = Date(timeInterval: -week-10, since: now)
        estrogenSchedule.setDate(of: 0, with: d1, setSharedData: nil)
        XCTAssertEqual(estrogenSchedule.totalDue(intervals[1]), 1)
        // Week not quite due yet
        d1 = Date(timeInterval: -week+10, since: now)
        estrogenSchedule.setDate(of: 0, with: d1, setSharedData: nil)
        XCTAssertEqual(estrogenSchedule.totalDue(intervals[1]), 0)
        // Two weeks just past due
        d1 = Date(timeInterval: -twoweeks-10, since: now)
        estrogenSchedule.setDate(of: 0, with: d1, setSharedData: nil)
        XCTAssertEqual(estrogenSchedule.totalDue(intervals[2]), 1)
        // Two weeks not quite due yet
        d1 = Date(timeInterval: -twoweeks+10, since: now)
        estrogenSchedule.setDate(of: 0, with: d1, setSharedData: nil)
        XCTAssertEqual(estrogenSchedule.totalDue(intervals[2]), 0)
    }
    
    func testResetFrom() {
        estrogenSchedule.setDate(of: 0, with: Date(), setSharedData: nil)
        estrogenSchedule.setDate(of: 1, with: Date(), setSharedData: nil)
        estrogenSchedule.setDate(of: 2, with: Date(), setSharedData: nil)
        XCTAssertFalse(estrogenSchedule.isEmpty())
        estrogenSchedule.reset(from: 2)
        var actual = estrogenSchedule.datePlacedCount()
        var expected = 2
        XCTAssertEqual(actual, expected)
        estrogenSchedule.reset(from: 0)
        actual = estrogenSchedule.datePlacedCount()
        expected = 0
        XCTAssertEqual(actual, expected)
    }
}
