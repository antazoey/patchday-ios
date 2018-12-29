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
    let estroSchedule = EstrogenSchedule()

    override func setUp() {
        super.setUp()
        siteSchedule.reset()
        estroSchedule.reset()
        
        // Load estrogens to occupy the sites
        estroSchedule.setEstrogenSite(of: 0, with: siteSchedule.getSite(at: 0)!)
        estroSchedule.setEstrogenSite(of: 1, with: siteSchedule.getSite(at: 1)!)
        estroSchedule.setEstrogenSite(of: 2, with: siteSchedule.getSite(at: 2)!)
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
            XCTAssertTrue(siteSchedule.getSites().contains(site))
        } else {
            XCTFail()
        }
    }
    
    func testReset() {
        UserDefaultsController.setDeliveryMethod(to: "Patches")
        siteSchedule.setName(at: 0, to: "NOT DEFAULT SITE NAME")
        siteSchedule.setName(at: 1, to: "NOT DEFAULT SITE NAME")
        let _ = siteSchedule.insert()
        siteSchedule.reset()
        XCTAssertEqual(siteSchedule.count(), 4)
        XCTAssert(siteSchedule.isDefault(usingPatches: true))
        siteSchedule.setName(at: 0, to: "NOT DEFAULT SITE NAME")
        siteSchedule.setName(at: 1, to: "NOT DEFAULT SITE NAME")
        let _ = siteSchedule.insert()
        UserDefaultsController.setDeliveryMethod(to: "Injections")
        siteSchedule.reset()
        XCTAssertEqual(siteSchedule.count(), 6)
        XCTAssert(siteSchedule.isDefault(usingPatches: false))
    }
    
    func testSetSiteName() {
        siteSchedule.setName(at: 0, to: "TEST SITE")
        if let actual = siteSchedule.sites[0].getName() {
            let expected = "TEST SITE"
            XCTAssertEqual(actual, expected)
        } else {
            XCTFail()
        }
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
    
    func testGetNextSiteIndex() {
        // Finds next index even if current is incorrect
        var actual = siteSchedule.nextIndex(current: 0)
        XCTAssertEqual(actual, 3)
        // Finds next index even if current index is way off
        actual = siteSchedule.nextIndex(current: 100)
        XCTAssertEqual(actual, 3)
        // Find next index when current is as it should be
        actual = siteSchedule.nextIndex(current: 3)
        XCTAssertEqual(actual, 3)
        // Returns same index when all sites are filled
        estroSchedule.setEstrogenSite(of: 3, with: siteSchedule.getSite(at: 3)!)
        actual = siteSchedule.nextIndex(current: 3)
        XCTAssertEqual(actual, 3)
        // Returns max when current is too large
        actual = siteSchedule.nextIndex(current: 100)
        XCTAssertEqual(actual, siteSchedule.count() - 1)
        // Returns nil when current is < 0
        actual = siteSchedule.nextIndex(current: -1)
        XCTAssertNil(actual)
    }
    
    func testSetSiteOrder() {
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
    
    func testSetSiteImageID() {
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
    
    func testDeleteSite() {
        var old_count = siteSchedule.count();
        let old_site = siteSchedule.sites[0]
        if let siteNameDeleted = siteSchedule.getSite(at: 0)?.getName() {
            siteSchedule.delete(at: 0)
            // Assert that the backup site name remains after deleted
            if let n = estroSchedule.estrogens[0].getSiteNameBackUp() {
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
    
    func testLoadEstrogenFromBackUpSite() {
        // Assert begins at nil
        if let estro = estroSchedule.getEstrogen(at: 0, insertOnFail: false) {
            XCTAssertNil(estro.siteNameBackUp)
        } else {
            XCTFail()
        }
        siteSchedule.loadBackupSiteName(from: siteSchedule.sites[0])
        if let siteNameFromSite = siteSchedule.sites[0].getName(),
            let siteNameFromEstro = estroSchedule.estrogens[0].getSiteNameBackUp() {
            XCTAssertEqual(siteNameFromSite, siteNameFromEstro)
        }
    }
    
    func testGetSiteName() {
        XCTAssertEqual(siteSchedule.getNames(), PDStrings.SiteNames.patchSiteNames)
    }
    
    func testGetSiteImageIDs() {
        XCTAssertEqual(siteSchedule.getImageIDs(), PDStrings.SiteNames.patchSiteNames)
    }
    
    func testSiteNameSetUnionDefaultSites() {
        siteSchedule.setName(at: 0, to: "SITE NAME")
        var sites = PDStrings.SiteNames.patchSiteNames
        sites.append("SITE NAME")
        XCTAssertEqual(siteSchedule.unionDefault(usingPatches: true), Set(sites))
    }
    
    func testIsDefault() {
        UserDefaultsController.setDeliveryMethod(to: "Patches")
        siteSchedule.reset()
        XCTAssert(siteSchedule.isDefault(usingPatches: true))
        // Patches fail when tested against injections
        XCTAssertFalse(siteSchedule.isDefault(usingPatches: false))
        // Fails when add a custom site
        siteSchedule.setName(at: 0, to: "SITE NAME")
        XCTAssertFalse(siteSchedule.isDefault(usingPatches: true))
        UserDefaultsController.setDeliveryMethod(to: "Injections")
        siteSchedule.reset()
        // Injection defaults pass
        XCTAssert(siteSchedule.isDefault(usingPatches: false))
        // Injections fail when tested against patches
        XCTAssertFalse(siteSchedule.isDefault(usingPatches: true))
    }
    
    func testFilterEmptySites() {
        let before = siteSchedule.count()
        siteSchedule.setName(at: 0, to: "")
        siteSchedule.filterEmpty()
        let after = siteSchedule.count()
        XCTAssertEqual(after, before - 1)
    }
    
    func testAppendSite() {
        if let new_site = siteSchedule.insert() {
            XCTAssert(siteSchedule.sites.contains(new_site))
        } else {
            XCTFail()
        }
    }
}
