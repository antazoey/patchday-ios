//
//  MOEstrogenTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 1/9/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
@testable import PatchData

class MOEstrogenTests: XCTestCase {
    
    private var estrogenSchedule: EstrogenSchedule!
    private var siteSchedule: SiteSchedule!
    
    override func setUp() {
        super.setUp()
        PatchData.useTestContainer()
        estrogenSchedule = EstrogenSchedule()
        siteSchedule = SiteSchedule()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testLT() {
        let estro_recent = estrogenSchedule.insert() as! MOEstrogen
        let estro_next = estrogenSchedule.insert() as! MOEstrogen
        let estro_nilDate = estrogenSchedule.insert() as! MOEstrogen
        let later = Date();
        let earlier = Date(timeInterval: -1000, since: later)
        estro_recent.setDate(later as NSDate)
        estro_next.setDate(earlier as NSDate)
        // Estrogens that need to be changed next are less than.
        XCTAssert(estro_next < estro_recent)
        // Estrogen with date is less than Estrogen with nil date
        XCTAssert(estro_recent < estro_nilDate && estro_next < estro_nilDate)
        // Estrogens with nil dates are not less than
        XCTAssertFalse(estro_nilDate < estro_nilDate)
    }
    
    func testGT() {
        let estro_recent = estrogenSchedule.insert() as! MOEstrogen
        let estro_next = estrogenSchedule.insert() as! MOEstrogen
        let estro_nilDate = estrogenSchedule.insert() as! MOEstrogen
        let later = Date();
        let earlier = Date(timeInterval: -1000, since: later)
        estro_recent.setDate(later as NSDate)
        estro_next.setDate(earlier as NSDate)
        // Estrogens that were changed recently are greater than than
        XCTAssert(estro_recent > estro_next)
        // Estrogen with nil date is greater than Estrogen with not nil date
        XCTAssert(estro_nilDate > estro_recent)
        XCTAssert(estro_nilDate > estro_next)
        // Estrogens with nil dates are not greater than
        XCTAssertFalse(estro_nilDate > estro_nilDate)
    }
    
    func testEQ() {
        let estro_recent = estrogenSchedule.insert() as! MOEstrogen
        let estro_sameDateAsRecent = estrogenSchedule.insert() as! MOEstrogen
        let estro_next = estrogenSchedule.insert() as! MOEstrogen
        let estro_nilDate = estrogenSchedule.insert() as! MOEstrogen
        let later = Date();
        let earlier = Date(timeInterval: -1000, since: later)
        estro_recent.setDate(later as NSDate)
        estro_sameDateAsRecent.setDate(later as NSDate)
        estro_next.setDate(earlier as NSDate)
        // Estrogens with the same date are equal
        XCTAssert(estro_recent == estro_sameDateAsRecent)
        // Estrogens with different dates not equal
        XCTAssertFalse(estro_recent == estro_next)
        // Estrogen with nil date is not equal to estrogen with date
        XCTAssertFalse (estro_recent == estro_nilDate)
        XCTAssertFalse(estro_nilDate == estro_recent)
        // Estrogens with two nil dates are equal
        XCTAssert(estro_nilDate == estro_nilDate)
    }
    
    func testNQ() {
        let estro_recent = estrogenSchedule.insert() as! MOEstrogen
        let estro_sameDateAsRecent = estrogenSchedule.insert() as! MOEstrogen
        let estro_next = estrogenSchedule.insert() as! MOEstrogen
        let estro_nilDate = estrogenSchedule.insert() as! MOEstrogen
        let later = Date();
        let earlier = Date(timeInterval: -1000, since: later)
        estro_recent.setDate(later as NSDate)
        estro_sameDateAsRecent.setDate(later as NSDate)
        estro_next.setDate(earlier as NSDate)
        // Estrogens with different dates are not equal
        XCTAssert(estro_recent != estro_next)
        // Estrogens with the same date are equal
        XCTAssertFalse(estro_recent != estro_sameDateAsRecent)
        // Estrogen with nil date is not equal to estrogen with date
        XCTAssert (estro_recent != estro_nilDate)
        XCTAssert(estro_nilDate != estro_recent)
        // Estrogens with two nil dates are equal
        XCTAssertFalse(estro_nilDate != estro_nilDate)
    }
    
    func testSetSite() {
        let estro = estrogenSchedule.insert() as! MOEstrogen
        let site = SiteSchedule().insert() as! MOSite
        site.setName("Left Armpit")
        estro.setSite(site)
        XCTAssertEqual(estro.getSite(), site)
        // Backup sitename should be nil upon setting site
        XCTAssertNil(estro.getSiteNameBackUp())
    }
    
    func testSetDate() {
        let estro = estrogenSchedule.insert() as! MOEstrogen
        estro.stamp()
        let d = estro.getDate()! as Date
        // Should set to now without arg
        XCTAssert(d.isWithin(minutes: 1, of: Date()))
        let date = Date(timeIntervalSince1970: 23975) as NSDate
        estro.date = date
        XCTAssertEqual(estro.getDate(), date)
    }
    
    func testSetId() {
        let estro = estrogenSchedule.insert() as! MOEstrogen
        let id = estro.setId()
        XCTAssertEqual(estro.getId(), id)
    }
    
    func testSetBackupSiteName() {
        let estro = estrogenSchedule.insert() as! MOEstrogen
        estro.setSiteBackup(to: "NEW SITE")
        XCTAssertEqual(estro.getSiteNameBackUp(), "NEW SITE")
        // should set site to nil upon setting site backup name
        XCTAssertNil(estro.getSite())
    }
    
    func testGetSiteName() {
        if let estro = estrogenSchedule.insert() as? MOEstrogen,
            let site = siteSchedule.insert() as? MOSite {
            site.setName("Left Armpit")
            estro.setSite(site)
            // When site is set, the sitename should be the site's name.
            XCTAssertEqual(estro.getSiteName(), site.getName())
            // When the sitename-backup is set, the sitename should be the backup
            estro.setSiteBackup(to: "Right Tongue")
            XCTAssertEqual(estro.getSiteName(), estro.getSiteNameBackUp())
            estro.reset()
            // When estro is without a site, it's sitename is "NEW SITE"
            XCTAssertEqual(estro.getSiteName(), PDStrings.PlaceholderStrings.new_site)
        } else {
            XCTFail()
        }
    }
    
    func testReset() {
        let estro = estrogenSchedule.insert() as! MOEstrogen
        estro.setSiteBackup(to: "Booty")
        estro.stamp()
        estro.reset()
        XCTAssertNil(estro.getId())
        XCTAssertNil(estro.getDate())
        XCTAssertNil(estro.getSite())
        XCTAssertNil(estro.getSiteNameBackUp())
    }
    
    func testIsExpired() {
        let estro = estrogenSchedule.insert() as! MOEstrogen
        let halfweek_interval = ExpirationIntervalUD(with: .TwiceAWeek)
        let week_interval = ExpirationIntervalUD(with: .OnceAWeek)
        let two_weeks_interval = ExpirationIntervalUD(with: .EveryTwoWeeks)

        let date = Date()
        let expDate1 = Date(timeInterval: -302401, since: date) as NSDate
        let expDate2 = Date(timeInterval: -604801, since: date) as NSDate
        let expDate3 = Date(timeInterval: -1209601, since: date) as NSDate
        
        estro.date = date as NSDate
        XCTAssertFalse(estro.isExpired(halfweek_interval))
        XCTAssertFalse(estro.isExpired(week_interval))
        XCTAssertFalse(estro.isExpired(two_weeks_interval))
        
        estro.date = expDate1
        XCTAssertTrue(estro.isExpired(halfweek_interval))
        XCTAssertFalse(estro.isExpired(week_interval))
        XCTAssertFalse(estro.isExpired(two_weeks_interval))
        
        estro.date = expDate2
        XCTAssertTrue(estro.isExpired(halfweek_interval))
        XCTAssertTrue(estro.isExpired(week_interval))
        XCTAssertFalse(estro.isExpired(two_weeks_interval))
        
        estro.date = expDate3
        estro.setDate(expDate3)
        XCTAssertTrue(estro.isExpired(halfweek_interval))
        XCTAssertTrue(estro.isExpired(week_interval))
        XCTAssertTrue(estro.isExpired(two_weeks_interval))
    }
    
    func testIsEmpty() {
        let estro = estrogenSchedule.insert() as! MOEstrogen
        XCTAssertTrue(estro.isEmpty())
        estro.stamp()
        XCTAssertFalse(estro.isEmpty())
        estro.reset()
        XCTAssertTrue(estro.isEmpty())
        estro.setSite(SiteSchedule().insert() as? MOSite)
        XCTAssertFalse(estro.isEmpty())
        estro.reset()
        estro.setSiteBackup(to: "Site")
        XCTAssertFalse(estro.isEmpty())
    }
}
