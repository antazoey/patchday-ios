//
//  PatchDataTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 12/20/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

//import XCTest
//import PDKit
//@testable
//
//class SiteScheduleTests: XCTestCase {
//    private var estrogenSchedule: EstrogenSchedule!
//    private var defaults: PDDefaults!
//    private var siteSchedule: SiteSchedule!
//
//    override func setUp() {
//        super.setUp()
//        PatchData.useTestContainer()
//        estrogenSchedule = EstrogenSchedule()
//        siteSchedule = SiteSchedule()
//        siteSchedule.reset()
//        estrogenSchedule.reset(completion: nil)
//        estrogenSchedule = EstrogenSchedule()
//        defaults = PDDefaults(estrogenSchedule: estrogenSchedule,
//                              siteSchedule: siteSchedule,
//                              state: PDState(),
//                              sharedData: nil,
//                              alerter: nil)
//        defaults.setDeliveryMethod(to: .Patches)
//        // Load estrogens to occupy the sites
//        estrogenSchedule.setSite(of: 0,
//                                 with: siteSchedule.at(0)!,
//                                 setSharedData: nil)
//        estrogenSchedule.setSite(of: 1,
//                                 with: siteSchedule.at(1)!,
//                                 setSharedData: nil)
//        estrogenSchedule.setSite(of: 2,
//                                 with: siteSchedule.at(2)!,
//                                 setSharedData: nil)
//    }
//
//    override func tearDown() {
//        super.tearDown()
//    }
//
//    func testInit() {
//        XCTAssertEqual(estrogenSchedule.count(), 3)
//        let deliv = defaults.deliveryMethod.value
//        XCTAssertEqual(deliv, DeliveryMethod.Patches)
//        var i = 0
//        for mone in estrogenSchedule.estrogens {
//            if let actual = estro.getSite(),
//                let expected = siteSchedule.at(i) {
//                i += 1
//                XCTAssertEqual(actual, expected)
//            } else {
//                XCTFail()
//            }
//        }
//    }
//
//    func testCount() {
//        XCTAssertEqual(siteSchedule.count(), 4)
//    }
//
//    func testInsert() {
//        if let site = siteSchedule.insert() as? MOSite {
//            XCTAssertEqual(siteSchedule.count(), 5)
//            XCTAssertTrue(siteSchedule.sites.contains(site))
//        } else {
//            XCTFail()
//        }
//    }
//
//    func testReset() {
//        defaults.setDeliveryMethod(to: .Patches)
//        siteSchedule.rename(at: 0, to: "NOT DEFAULT SITE NAME")
//        siteSchedule.rename(at: 1, to: "NOT DEFAULT SITE NAME")
//        let _ = siteSchedule.insert()
//        siteSchedule.reset()
//        XCTAssertEqual(siteSchedule.count(), 4)
//        XCTAssert(siteSchedule.isDefault(deliveryMethod: .Patches))
//        siteSchedule.rename(at: 0, to: "NOT DEFAULT SITE NAME")
//        siteSchedule.rename(at: 1, to: "NOT DEFAULT SITE NAME")
//        let _ = siteSchedule.insert()
//        defaults.setDeliveryMethod(to: .Injections)
//        siteSchedule.reset()
//        XCTAssertEqual(siteSchedule.count(), 6)
//        XCTAssert(siteSchedule.isDefault(deliveryMethod: .Injections))
//    }
//
//    func testDelete() {
//        var old_count = siteSchedule.count();
//        let old_site = siteSchedule.sites[0]
//        if let siteNameDeleted = siteSchedule.at(0)?.getName() {
//            siteSchedule.delete(at: 0)
//            // Assert that the backup site name remains after deleted
//            if let n = estrogenSchedule.estrogens[0].getSiteNameBackUp() {
//                XCTAssertEqual(n, siteNameDeleted)
//            }
//            // Assert 1 less site in the schedule
//            XCTAssertEqual(siteSchedule.count(), old_count - 1)
//            XCTAssertFalse(siteSchedule.sites.contains(old_site))
//        }
//        // Assert no deletion for bad index
//        old_count = siteSchedule.count()
//        siteSchedule.delete(at: 100)
//        XCTAssertEqual(old_count, siteSchedule.count())
//    }
//
//    func testNew() {
//        defaults.setDeliveryMethod(to: .Injections)
//        siteSchedule.new()
//        XCTAssert(siteSchedule.isDefault(deliveryMethod: .Injections))
//    }
//
//    func testFilterEmptySites() {
//        let before = siteSchedule.count()
//        siteSchedule.rename(at: 0, to: "")
//        siteSchedule.filterEmpty()
//        let after = siteSchedule.count()
//        XCTAssertEqual(after, before - 1)
//    }
//
//    func testSitesAreSorted() {
//        XCTAssertEqual(siteSchedule.sites[0].getOrder(), 0)
//        XCTAssertEqual(siteSchedule.sites[1].getOrder(), 1)
//        XCTAssertEqual(siteSchedule.sites[2].getOrder(), 2)
//        XCTAssertEqual(siteSchedule.sites[3].getOrder(), 3)
//    }
//
//    func testGetSiteAtIndex() {
//        // Returns nil when site index too high
//        XCTAssertNil(siteSchedule.at(100))
//        if let actual = siteSchedule.at(0) {
//            XCTAssertEqual(actual, siteSchedule.sites[0])
//        }
//    }
//
//    func testGetSiteForName() {
//        // Should append new site if site not in schedule
//        if let newSite = siteSchedule.getSite(for: "NEW SITE NAME") {
//            XCTAssert(siteSchedule.sites.contains(newSite))
//        } else {
//            XCTFail()
//        }
//        if let n = siteSchedule.sites[0].getName() {
//            let actual = siteSchedule.getSite(for: n)
//            XCTAssertEqual(actual, siteSchedule.sites[0])
//        }
//    }
//
//    func testrename() {
//        siteSchedule.rename(at: 0, to: "TEST SITE")
//        if let actual = siteSchedule.sites[0].getName() {
//            let expected = "TEST SITE"
//            XCTAssertEqual(actual, expected)
//        } else {
//            XCTFail()
//        }
//    }
//
//    func testSetOrder() {
//        // Successfully sets order when within bounds and swaps
//        var oldname_at0 = siteSchedule.sites[0].getName()
//        let oldname_at1 = siteSchedule.sites[1].getName()
//        siteSchedule.setOrder(at: 0, to: 1)
//        var newname_at0 = siteSchedule.sites[0].getName()
//        let newname_at1 = siteSchedule.sites[1].getName()
//        XCTAssertEqual(newname_at0, oldname_at1)
//        XCTAssertEqual(newname_at1, oldname_at0)
//        // Should not set order when order > count()
//        oldname_at0 = siteSchedule.sites[0].getName()
//        siteSchedule.setOrder(at: 0, to: 10)
//        newname_at0 = siteSchedule.sites[0].getName()
//        XCTAssertEqual(oldname_at0, newname_at0)
//    }
//
//    func testSetImageId() {
//        let expected = "custom"
//        siteSchedule.setImageId(at: 0, to: "BAD Id", deliveryMethod: .Patches)
//        if let actual = siteSchedule.sites[0].getImageIdentifer() {
//            XCTAssertEqual(actual, expected)
//        } else {
//            XCTFail()
//        }
//        // Successfully sets id when it is default patch Site Name
//        var good_id = PDSiteStrings.getSiteNames(for: .Patches)[0]
//        siteSchedule.setImageId(at: 0, to: good_id, deliveryMethod: .Patches)
//        if let actual = siteSchedule.sites[0].getImageIdentifer() {
//            let expected = good_id
//            XCTAssertEqual(actual, expected)
//        } else {
//            XCTFail()
//        }
//        // Successfully sets id when it is default injection Site Name
//        good_id = PDSiteStrings.getSiteNames(for: .Injections)[0]
//        siteSchedule.setImageId(at: 0, to: good_id, deliveryMethod: .Injections)
//        if let actual = siteSchedule.sites[0].getImageIdentifer() {
//            let expected = good_id
//            XCTAssertEqual(actual, expected)
//        } else {
//            XCTFail()
//        }
//    }
//
//    func testNextIndex() {
//        let setter = defaults.setSiteIndex
//
//        // Finds next index even if current is incorrect
//        siteSchedule.next = 0
//        var actual = siteSchedule.nextIndex(changeIndex: setter)
//        XCTAssertEqual(actual, 3)
//
//        // Finds next index even if current index is way off
//        siteSchedule.next = 100
//        actual = siteSchedule.nextIndex(changeIndex: setter)
//        XCTAssertEqual(actual, 3)
//
//        // Returns same index when all sites are filled
//        let _ = estrogenSchedule.insert()
//        estrogenSchedule.setSite(of: 3,
//                                 with: siteSchedule.at(3)!,
//                                 setSharedData: nil)
//        let sitesCount = estrogenSchedule.estrogens.reduce(0) {
//            (count: Int, estro: MOEstrogen) -> Int in
//            if let _ = estro.getSite() {
//                return count + 1
//            }
//            return count
//        }
//        actual = siteSchedule.nextIndex(changeIndex: setter)
//        XCTAssertEqual(sitesCount, 4)
//        XCTAssertEqual(actual, 3)
//
//        // Fixes negative next and return index 0 when full
//        siteSchedule.next = -1
//        actual = siteSchedule.nextIndex(changeIndex: setter)
//        XCTAssertEqual(actual, 0)
//        estrogenSchedule.setSite(of: 0,
//                                 with: siteSchedule.at(0)!,
//                                 setSharedData: nil)
//        actual = siteSchedule.nextIndex(changeIndex: setter)
//        XCTAssertEqual(actual, 0)
//        // returns nil when there are no sites
//        for _ in 0..<siteSchedule.count() {
//            siteSchedule.delete(at: 0)
//        }
//        actual = siteSchedule.nextIndex(changeIndex: setter)
//        XCTAssertNil(actual)
//    }
//
//    func testSuggest() {
//        let set = defaults.setSiteIndex
//        var actual = siteSchedule.suggest(changeIndex: set)
//        var expected = siteSchedule.at(3)!
//        XCTAssertEqual(actual, expected)
//        estrogenSchedule.setSite(of: 0, with: expected, setSharedData: nil)
//        actual = siteSchedule.suggest(changeIndex: set)
//        expected = siteSchedule.at(0)!
//        XCTAssertEqual(actual, expected)
//    }
//
//    func testGetNames() {
//        XCTAssertEqual(siteSchedule.getNames(),
//                       PDSiteStrings.getSiteNames(for: .Patches))
//    }
//
//    func testGetImageIds() {
//        XCTAssertEqual(siteSchedule.getImageIds(),
//                       PDSiteStrings.getSiteNames(for: .Patches))
//    }
//
//    func testUnionDefault() {
//        siteSchedule.rename(at: 0, to: "SITE NAME")
//        var sites = PDSiteStrings.getSiteNames(for: .Patches)
//        sites.append("SITE NAME")
//        XCTAssertEqual(siteSchedule.unionDefault(deliveryMethod: .Patches),
//                       Set(sites))
//    }
//
//    func testIsDefault() {
//        XCTAssert(siteSchedule.isDefault(deliveryMethod: .Patches))
//        // Patches fail when tested against injections
//        XCTAssertFalse(siteSchedule.isDefault(deliveryMethod: .Injections))
//        // Fails when add a custom site
//        siteSchedule.rename(at: 0, to: "SITE NAME")
//        XCTAssertFalse(siteSchedule.isDefault(deliveryMethod: .Patches))
//        defaults.setDeliveryMethod(to: .Injections)
//        siteSchedule.reset()
//        // Injection defaults pass
//        XCTAssert(siteSchedule.isDefault(deliveryMethod: .Injections))
//        // Injections fail when tested against patches
//        XCTAssertFalse(siteSchedule.isDefault(deliveryMethod: .Patches))
//    }
//
//    func testAppendSite() {
//        if let newSite = siteSchedule.insert() as? MOSite {
//            XCTAssert(siteSchedule.sites.contains(newSite))
//        } else {
//            XCTFail()
//        }
//    }
//}
