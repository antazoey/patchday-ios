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
        siteSchedule.reset(usingPatches: true)
        estroSchedule.reset()
        estroSchedule.setEstrogenSite(of: 0, with: siteSchedule.getSite(at: 0)!)
        estroSchedule.setEstrogenSite(of: 1, with: siteSchedule.getSite(at: 1)!)
        estroSchedule.setEstrogenSite(of: 2, with: siteSchedule.getSite(at: 2)!)
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testSetSiteName() {
        siteSchedule.setSiteName(at: 0, to: "TEST SITE")
        if let actual = siteSchedule.siteArray[0].getName() {
            let expected = "TEST SITE"
            XCTAssertEqual(actual, expected)
        } else {
            XCTFail()
        }
    }
    
    func testSitesAreSorted() {
        XCTAssertEqual(siteSchedule.siteArray[0].getOrder(), 0)
        XCTAssertEqual(siteSchedule.siteArray[1].getOrder(), 1)
        XCTAssertEqual(siteSchedule.siteArray[2].getOrder(), 2)
        XCTAssertEqual(siteSchedule.siteArray[3].getOrder(), 3)
    }
    
    func testGetSiteAtIndex() {
        // Returns nil when site index too high
        XCTAssertNil(siteSchedule.getSite(at: 100))
        if let actual = siteSchedule.getSite(at: 0) {
            XCTAssertEqual(actual, siteSchedule.siteArray[0])
        }
    }
    
    func testGetSiteForName() {
        // Should append new site if site not in schedule
        if let new_site = siteSchedule.getSite(for: "NEW SITE NAME") {
            XCTAssert(siteSchedule.siteArray.contains(new_site))
        } else {
            XCTFail()
        }
        if let n = siteSchedule.siteArray[0].getName() {
            let actual = siteSchedule.getSite(for: n)
            XCTAssertEqual(actual, siteSchedule.siteArray[0])
        }
    }
    
    func testGetNextSiteIndex() {
        // Finds next index even if currentIndex is incorrect
        var actual = siteSchedule.getNextSiteIndex(currentIndex: 0)
        XCTAssertEqual(actual, 3)
        // Finds next index even if current index is way off
        actual = siteSchedule.getNextSiteIndex(currentIndex: 100)
        XCTAssertEqual(actual, 3)
        // Find next index when currentIndex is as it should be
        actual = siteSchedule.getNextSiteIndex(currentIndex: 3)
        XCTAssertEqual(actual, 3)
        // Returns same index when all sites are filled
        estroSchedule.setEstrogenSite(of: 3, with: siteSchedule.getSite(at: 3)!)
        actual = siteSchedule.getNextSiteIndex(currentIndex: 3)
        XCTAssertEqual(actual, 3)
        // Returns max when currentIndex is too large
        actual = siteSchedule.getNextSiteIndex(currentIndex: 100)
        XCTAssertEqual(actual, siteSchedule.siteArray.count - 1)
        // Returns nil when currentIndex is < 0
        actual = siteSchedule.getNextSiteIndex(currentIndex: -1)
        XCTAssertNil(actual)
    }
    
    func testSetSiteOrder() {
        // Successfully sets order when within bounds and swaps
        var oldname_at0 = siteSchedule.siteArray[0].getName()
        let oldname_at1 = siteSchedule.siteArray[1].getName()
        siteSchedule.setSiteOrder(at: 0, to: 1)
        var newname_at0 = siteSchedule.siteArray[0].getName()
        let newname_at1 = siteSchedule.siteArray[1].getName()
        XCTAssertEqual(newname_at0, oldname_at1)
        XCTAssertEqual(newname_at1, oldname_at0)
        // Should not set order when order > sites.count
        oldname_at0 = siteSchedule.siteArray[0].getName()
        siteSchedule.setSiteOrder(at: 0, to: 10)
        newname_at0 = siteSchedule.siteArray[0].getName()
        XCTAssertEqual(oldname_at0, newname_at0)
    }
    
    func testSetSiteImageID() {
        // Fails to set image id when it is not a default Site Name
        let curr_id = siteSchedule.siteArray[0].getImageIdentifer()
        siteSchedule.setSiteImageID(at: 0, to: "BAD ID", usingPatches: true)
        if let actual = siteSchedule.siteArray[0].getImageIdentifer() {
            let expected = curr_id
            XCTAssertEqual(actual, expected)
        } else {
            XCTFail()
        }
        // Successfully sets id when it is default patch Site Name
        var good_id = PDStrings.SiteNames.patchSiteNames[0]
        siteSchedule.setSiteImageID(at: 0, to: good_id, usingPatches: true)
        if let actual = siteSchedule.siteArray[0].getImageIdentifer() {
            let expected = good_id
            XCTAssertEqual(actual, expected)
        } else {
            XCTFail()
        }
        // Successfully sets id when it is default injection Site Name
        good_id = PDStrings.SiteNames.injectionSiteNames[0]
        siteSchedule.setSiteImageID(at: 0, to: good_id, usingPatches: false)
        if let actual = siteSchedule.siteArray[0].getImageIdentifer() {
            let expected = good_id
            XCTAssertEqual(actual, expected)
        } else {
            XCTFail()
        }
    }
    
    func testDeleteSite() {
        var old_count = siteSchedule.siteArray.count;
        let old_site = siteSchedule.siteArray[0]
        if let siteNameDeleted = siteSchedule.getSite(at: 0)?.getName() {
            siteSchedule.deleteSite(at: 0)
            // Assert that the backup site name remains after deleted
            if let n = estroSchedule.estrogenArray[0].getSiteNameBackUp() {
                XCTAssertEqual(n, siteNameDeleted)
            }
            // Assert 1 less site in the schedule
            XCTAssertEqual(siteSchedule.siteArray.count, old_count - 1)
            XCTAssertFalse(siteSchedule.siteArray.contains(old_site))
        }
        // Assert no deletion for bad index
        old_count = siteSchedule.siteArray.count
        siteSchedule.deleteSite(at: 100)
        XCTAssertEqual(old_count, siteSchedule.siteArray.count)
    }
    
    func testLoadEstrogenFromBackUpSite() {
        // Assert begins at nil
        XCTAssertNil(estroSchedule.getEstrogen(at: 0).siteNameBackUp)
        siteSchedule.loadEstrogenBackupSiteNameFromSite(site: siteSchedule.siteArray[0])
        if let siteNameFromSite = siteSchedule.siteArray[0].getName(),
            let siteNameFromEstro = estroSchedule.estrogenArray[0].getSiteNameBackUp() {
            XCTAssertEqual(siteNameFromSite, siteNameFromEstro)
        }
    }
    
    func testGetSiteName() {
        XCTAssertEqual(siteSchedule.getSiteNames(), PDStrings.SiteNames.patchSiteNames)
    }
    
    func testGetSiteImageIDs() {
        XCTAssertEqual(siteSchedule.getSiteImageIDs(), PDStrings.SiteNames.patchSiteNames)
    }
    
    func testSiteNameSetUnionDefaultSites() {
        siteSchedule.setSiteName(at: 0, to: "SITE NAME")
        var sites = PDStrings.SiteNames.patchSiteNames
        sites.append("SITE NAME")
        XCTAssertEqual(siteSchedule.siteNameSetUnionDefaultSites(usingPatches: true), Set(sites))
    }
    
    func testIsDefault() {
        // Begins as patch defaults in test set-up
        XCTAssert(siteSchedule.isDefault(usingPatches: true))
        // Patches fail when tested against injections
        XCTAssertFalse(siteSchedule.isDefault(usingPatches: false))
        // Fails when add a custom site
        siteSchedule.setSiteName(at: 0, to: "SITE NAME")
        XCTAssertFalse(siteSchedule.isDefault(usingPatches: true))
        siteSchedule.reset(usingPatches: false)
        // Injection defaults pass
        XCTAssert(siteSchedule.isDefault(usingPatches: false))
        // Injections fail when tested against patches
        XCTAssertFalse(siteSchedule.isDefault(usingPatches: true))
    }
    
    func testFilterEmptySites() {
        let c = siteSchedule.siteArray.count
        siteSchedule.setSiteName(at: 0, to: "")
        let filtered_sites = SiteSchedule.filterEmptySites(from: siteSchedule.getSites())
        XCTAssertEqual(filtered_sites.count, c - 1)
    }
    
    func testReset() {
        siteSchedule.setSiteName(at: 0, to: "NOT DEFAULT SITE NAME")
        siteSchedule.setSiteName(at: 1, to: "NOT DEFAULT SITE NAME")
        let _ = siteSchedule.getSite(for: "NEW SITE")
        siteSchedule.reset(usingPatches: true)
        XCTAssert(siteSchedule.isDefault(usingPatches: true))
        siteSchedule.setSiteName(at: 0, to: "NOT DEFAULT SITE NAME")
        siteSchedule.setSiteName(at: 1, to: "NOT DEFAULT SITE NAME")
        let _ = siteSchedule.getSite(for: "NEW SITE")
        siteSchedule.reset(usingPatches: false)
        XCTAssert(siteSchedule.isDefault(usingPatches: false))
    }
    
    func testAppendSite() {
        if let new_site = SiteSchedule.appendSite(name: "NEW SITE", sites: &siteSchedule.siteArray) {
            XCTAssert(siteSchedule.siteArray.contains(new_site))
        } else {
            XCTFail()
        }
    }
}
