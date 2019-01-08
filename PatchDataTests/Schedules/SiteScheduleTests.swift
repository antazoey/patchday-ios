//
//  PatchDataTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 12/20/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
@testable import PatchData

class SiteScheduleTests: XCTestCase {
    let siteSchedule = SiteSchedule()
    let estrogenSchedule = EstrogenSchedule()
    var defaults: PDDefaults! = nil

    override func setUp() {
        super.setUp()
        estrogenSchedule.delete(after: -1)
        siteSchedule.reset()
        // Load estrogens to occupy the sites
        estrogenSchedule.setSite(of: 0,
                                 with: siteSchedule.getSite(at: 0)!,
                                 setSharedData: nil)
        estrogenSchedule.setSite(of: 1,
                                 with: siteSchedule.getSite(at: 1)!,
                                 setSharedData: nil)
        estrogenSchedule.setSite(of: 2,
                                 with: siteSchedule.getSite(at: 2)!,
                                 setSharedData: nil)
        defaults = PDDefaults(estrogenSchedule: estrogenSchedule,
                              siteSchedule: siteSchedule,
                              state: PDState(),
                              alerter: nil)
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testCount() {
        XCTAssertEqual(siteSchedule.count(), 4)
    }
    
    func testInsert() {
        if let site = siteSchedule.insert() {
            XCTAssertEqual(siteSchedule.count(), 5)
            XCTAssertTrue(siteSchedule.sites.contains(site))
        } else {
            XCTFail()
        }
    }
    
    func testReset() {
        defaults.setDeliveryMethod(to: "Patches")
        siteSchedule.setName(at: 0, to: "NOT DEFAULT SITE NAME")
        siteSchedule.setName(at: 1, to: "NOT DEFAULT SITE NAME")
        let _ = siteSchedule.insert()
        siteSchedule.reset()
        XCTAssertEqual(siteSchedule.count(), 4)
        XCTAssert(siteSchedule.isDefault(usingPatches: true))
        siteSchedule.setName(at: 0, to: "NOT DEFAULT SITE NAME")
        siteSchedule.setName(at: 1, to: "NOT DEFAULT SITE NAME")
        let _ = siteSchedule.insert()
        defaults.setDeliveryMethod(to: "Injections")
        siteSchedule.reset()
        XCTAssertEqual(siteSchedule.count(), 6)
        XCTAssert(siteSchedule.isDefault(usingPatches: false))
    }

    func testNew() {
        defaults.setDeliveryMethod(to: "Injections")
        siteSchedule.new()
        XCTAssert(siteSchedule.isDefault(usingPatches: false))
    }
    
    func testFilterEmptySites() {
        let before = siteSchedule.count()
        siteSchedule.setName(at: 0, to: "")
        siteSchedule.filterEmpty()
        let after = siteSchedule.count()
        XCTAssertEqual(after, before - 1)
    }

    func testSitesAreSorted() {
        XCTAssertEqual(siteSchedule.sites[0].getOrder(), 0)
        XCTAssertEqual(siteSchedule.sites[1].getOrder(), 1)
        XCTAssertEqual(siteSchedule.sites[2].getOrder(), 2)
        XCTAssertEqual(siteSchedule.sites[3].getOrder(), 3)
    }
    
    func testGetSiteAtIndex() {
        // Returns nil when site index too high
        XCTAssertNil(siteSchedule.getSite(at: 100))
        if let actual = siteSchedule.getSite(at: 0) {
            XCTAssertEqual(actual, siteSchedule.sites[0])
        }
    }
    
    func testGetSiteForName() {
        // Should append new site if site not in schedule
        if let new_site = siteSchedule.getSite(for: "NEW SITE NAME") {
            XCTAssert(siteSchedule.sites.contains(new_site))
        } else {
            XCTFail()
        }
        if let n = siteSchedule.sites[0].getName() {
            let actual = siteSchedule.getSite(for: n)
            XCTAssertEqual(actual, siteSchedule.sites[0])
        }
    }

    func testSetName() {
        siteSchedule.setName(at: 0, to: "TEST SITE")
        if let actual = siteSchedule.sites[0].getName() {
            let expected = "TEST SITE"
            XCTAssertEqual(actual, expected)
        } else {
            XCTFail()
        }
    }
    
    func testSetOrder() {
        // Successfully sets order when within bounds and swaps
        var oldname_at0 = siteSchedule.sites[0].getName()
        let oldname_at1 = siteSchedule.sites[1].getName()
        siteSchedule.setOrder(at: 0, to: 1)
        var newname_at0 = siteSchedule.sites[0].getName()
        let newname_at1 = siteSchedule.sites[1].getName()
        XCTAssertEqual(newname_at0, oldname_at1)
        XCTAssertEqual(newname_at1, oldname_at0)
        // Should not set order when order > count()
        oldname_at0 = siteSchedule.sites[0].getName()
        siteSchedule.setOrder(at: 0, to: 10)
        newname_at0 = siteSchedule.sites[0].getName()
        XCTAssertEqual(oldname_at0, newname_at0)
    }
    
    func testSetImageID() {
        // Fails to set image id when it is not a default Site Name
        let curr_id = siteSchedule.sites[0].getImageIdentifer()
        siteSchedule.setImageID(at: 0, to: "BAD ID", usingPatches: true)
        if let actual = siteSchedule.sites[0].getImageIdentifer() {
            let expected = curr_id
            XCTAssertEqual(actual, expected)
        } else {
            XCTFail()
        }
        // Successfully sets id when it is default patch Site Name
        var good_id = PDStrings.SiteNames.patchSiteNames[0]
        siteSchedule.setImageID(at: 0, to: good_id, usingPatches: true)
        if let actual = siteSchedule.sites[0].getImageIdentifer() {
            let expected = good_id
            XCTAssertEqual(actual, expected)
        } else {
            XCTFail()
        }
        // Successfully sets id when it is default injection Site Name
        good_id = PDStrings.SiteNames.injectionSiteNames[0]
        siteSchedule.setImageID(at: 0, to: good_id, usingPatches: false)
        if let actual = siteSchedule.sites[0].getImageIdentifer() {
            let expected = good_id
            XCTAssertEqual(actual, expected)
        } else {
            XCTFail()
        }
    }

    func testNextIndex() {
        let setter = defaults.setSiteIndex
        // Finds next index even if current is incorrect
        siteSchedule.next = 0
        var actual = siteSchedule.nextIndex(changeIndex: setter)
        XCTAssertEqual(actual, 3)
        // Finds next index even if current index is way off
        siteSchedule.next = 100
        actual = siteSchedule.nextIndex(changeIndex: setter)
        XCTAssertEqual(actual, 3)
        // Returns same index when all sites are filled
        estrogenSchedule.setSite(of: 3,
                                 with: siteSchedule.getSite(at: 3)!,
                                 setSharedData: nil)
        actual = siteSchedule.nextIndex(changeIndex: setter)
        XCTAssertEqual(actual, 3)
        siteSchedule.next = -1
        actual = siteSchedule.nextIndex(changeIndex: setter)
        XCTAssertEqual(actual, 0)
        estrogenSchedule.reset(completion: nil)
        estrogenSchedule.setSite(of: 0,
                                 with: siteSchedule.getSite(at: 0)!,
                                 setSharedData: nil)
        actual = siteSchedule.nextIndex(changeIndex: setter)
        XCTAssertEqual(actual, 1)
        // returns nil when there are no sites
        for _ in 0..<siteSchedule.count() {
            siteSchedule.delete(at: 0)
        }
        actual = siteSchedule.nextIndex(changeIndex: setter)
        XCTAssertNil(actual)
    }
    
    func testSuggest() {
        let set = defaults.setSiteIndex
        var actual = siteSchedule.suggest(changeIndex: set)
        var expected = siteSchedule.getSite(at: 3)!
        XCTAssertEqual(actual, expected)
        estrogenSchedule.setSite(of: 0, with: expected, setSharedData: nil)
        actual = siteSchedule.suggest(changeIndex: set)
        expected = siteSchedule.getSite(at: 0)!
        XCTAssertEqual(actual, expected)
    }
    
    func testGetNames() {
        XCTAssertEqual(siteSchedule.getNames(),
                       PDStrings.SiteNames.patchSiteNames)
    }
    
    func testGetImageIDs() {
        XCTAssertEqual(siteSchedule.getImageIDs(),
                       PDStrings.SiteNames.patchSiteNames)
    }
    
    func testUnionDefault() {
        siteSchedule.setName(at: 0, to: "SITE NAME")
        var sites = PDStrings.SiteNames.patchSiteNames
        sites.append("SITE NAME")
        XCTAssertEqual(siteSchedule.unionDefault(usingPatches: true),
                       Set(sites))
    }
    
    func testIsDefault() {
        XCTAssert(siteSchedule.isDefault(usingPatches: true))
        // Patches fail when tested against injections
        XCTAssertFalse(siteSchedule.isDefault(usingPatches: false))
        // Fails when add a custom site
        siteSchedule.setName(at: 0, to: "SITE NAME")
        XCTAssertFalse(siteSchedule.isDefault(usingPatches: true))
        defaults.setDeliveryMethod(to: "Injections")
        siteSchedule.reset()
        // Injection defaults pass
        XCTAssert(siteSchedule.isDefault(usingPatches: false))
        // Injections fail when tested against patches
        XCTAssertFalse(siteSchedule.isDefault(usingPatches: true))
    }
    
    func testDeleteSite() {
        var old_count = siteSchedule.count();
        let old_site = siteSchedule.sites[0]
        if let siteNameDeleted = siteSchedule.getSite(at: 0)?.getName() {
            siteSchedule.delete(at: 0)
            // Assert that the backup site name remains after deleted
            if let n = estrogenSchedule.estrogens[0].getSiteNameBackUp() {
                XCTAssertEqual(n, siteNameDeleted)
            }
            // Assert 1 less site in the schedule
            XCTAssertEqual(siteSchedule.count(), old_count - 1)
            XCTAssertFalse(siteSchedule.sites.contains(old_site))
        }
        // Assert no deletion for bad index
        old_count = siteSchedule.count()
        siteSchedule.delete(at: 100)
        XCTAssertEqual(old_count, siteSchedule.count())
    }
    
    func testAppendSite() {
        if let new_site = siteSchedule.insert() {
            XCTAssert(siteSchedule.sites.contains(new_site))
        } else {
            XCTFail()
        }
    }
}
