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
    }
    
    private func createMockOccupiedSite(hormoneCount: Int) -> MockSite {
        let site = MockSite()
        site.hormoneCount = hormoneCount
        var ids: [UUID] = []
        for _ in 0..<hormoneCount {
            ids.append(UUID())
        }
        site.hormoneIds = ids
        return site
    }
    
    private func createOccupiedSites(hormoneCounts: [Int]) -> [MockSite] {
        var sites: [MockSite] = []
        for count in hormoneCounts {
            sites.append(createMockOccupiedSite(hormoneCount: count))
        }
        return sites
    }
    
    private func createTestHormoneStructs(from mockSite: MockSite) -> [HormoneStruct] {
        var hormones: [HormoneStruct] = []
        for id in mockSite.hormoneIds {
            let hormone = createTestHormoneStruct(id)
            hormones.append(hormone)
        }
        return hormones
    }
    
    private func createTestHormoneStruct(_ id: UUID? = nil, _ date: Date? = nil) -> HormoneStruct {
        var hormone = HormoneStruct(id ?? UUID())
        hormone.date = date ?? Date()
        return hormone
    }
    
    private func setUpRelatedHormonesFactory(sites: [MockSite], hormonesOptions: [[HormoneStruct]]) {
        let c = min(sites.count, hormonesOptions.count)
        mockStore.getRelatedHormonesFactory = {
            for i in 0..<c {
                if sites[i].id == $0 {
                    return hormonesOptions[i]
                }
            }
            return []
        }
    }
    
    public func testNextIndex_whenSitesCountIsZero_returnsNegativeOne() {
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults, resetWhenEmpty: false)
        let expected = -1
        let actual = sites.nextIndex
        XCTAssertEqual(expected, actual)
    }
    
    public func testNextIndex_whenDefaultsSiteIndexIsUnoccupied_returnsDefaultsSiteIndex() {
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults)
        mockDefaults.siteIndex = SiteIndexUD(2)
        let expected = 2
        let actual = sites.nextIndex
        XCTAssertEqual(expected, actual)
    }
    
    public func testNextIndex_whenDefaultsSiteIndexIsOccupied_returnsFirstSiteAfterDefaultsSiteIndexWithNoHormones() {
        let mockSites = [MockSite(), MockSite(), createMockOccupiedSite(hormoneCount: 2), MockSite()]
        mockStore.getStoredCollectionReturnValues = [mockSites]
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults)
        mockDefaults.siteIndex = SiteIndexUD(2)
        let expected = 3
        let actual = sites.nextIndex
        XCTAssertEqual(expected, actual)
    }
    
    public func testNextIndex_whenAllSitesAreOccupied_returnsSiteWithOldestHormoneDate() {
        let mockSites = createOccupiedSites(hormoneCounts: [2, 3, 1, 3])
        let oldestDate = Date(timeInterval: -100000, since: Date())
        mockStore.getStoredCollectionReturnValues = [mockSites]
        let hormonesOne = createTestHormoneStructs(from: mockSites[0])
        let hormonesTwo = createTestHormoneStructs(from: mockSites[1])
        let hormonesThree = createTestHormoneStructs(from: mockSites[2])
        
        // This hormone list contains the hormone with the oldest date at index 1
        // The site that is occpied by this list is located at index 3.
        let hormonesFour = [
            createTestHormoneStruct(mockSites[3].hormoneIds[0]),
            createTestHormoneStruct(mockSites[3].hormoneIds[1], oldestDate),
            createTestHormoneStruct(mockSites[3].hormoneIds[2])
        ]
        let hormonesOptions = [hormonesOne, hormonesTwo, hormonesThree, hormonesFour]
        setUpRelatedHormonesFactory(sites: mockSites, hormonesOptions:hormonesOptions)
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults)
        
        let expected = 3
        let actual = sites.nextIndex
        XCTAssertEqual(expected, actual)
    }
}
