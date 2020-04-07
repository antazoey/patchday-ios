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
    private var mockSettings: MockUserDefaultsWriter!
    private var sites: SiteSchedule!
    
    override func setUp() {
        mockStore = MockSiteStore()
        mockSettings = MockUserDefaultsWriter()
    }
    
    override func tearDown() {
        mockStore.resetMock()
        mockSettings.resetMock()
    }
    
    @discardableResult
    private func setUpSites(count: Int) -> [MockSite] {
        var mockSites: [MockSite] = []
        for _ in 0..<count {
            mockSites.append(MockSite())
        }
        mockStore.getStoredCollectionReturnValues = [mockSites]
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        return mockSites
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
    
    // MARK: - Tests
    
    public func testSuggested_whenSitesCountIsZero_returnsNil() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings, resetWhenEmpty: false)
        XCTAssertNil(sites.suggested)
    }

    public func testSuggested_whenDefaultsSiteIndexIsUnoccupied_returnsSiteAtDefaultsSiteIndex() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        mockSettings.siteIndex = SiteIndexUD(2)
        let expected = sites[2]!.id
        let actual = sites.suggested!.id
        XCTAssertEqual(expected, actual)
    }
    
    public func testSuggested_whenDefaultsSiteIndexIsOccupied_updatesSiteIndexToNextOne() {
        let mockSites = setUpSites(count: 2)
        mockSites[0].hormoneIds = [UUID()]
        mockSites[0].hormoneCount = 1
        mockSettings.siteIndex = SiteIndexUD(0)
        mockStore.getStoredCollectionReturnValues = [mockSites]
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        _ = sites.suggested
        XCTAssertEqual(1, mockSettings.siteIndex.value)
    }
     
    public func testSuggested_whenDefaultsSiteIndexIsOccupied_returnsNextSiteAfterIndexWithNoHormones() {
        let mockSites = [MockSite(), MockSite(), createMockOccupiedSite(hormoneCount: 2), MockSite()]
        mockStore.getStoredCollectionReturnValues = [mockSites]
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        mockSettings.siteIndex = SiteIndexUD(2)
        let expected = mockSites[3].id
        let actual = sites.suggested!.id
        XCTAssertEqual(expected, actual)
    }
     
    public func testSuggested_whenAllSitesAreOccupied_returnsSiteWithOldestHormoneDate() {
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
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
         
        let expected = mockSites[3].id
        let actual = sites.suggested!.id
        XCTAssertEqual(expected, actual)
    }
    
    public func testSuggested_whenAllSitesAreOccupied_updatesSiteIndexToSiteIndexWithOldestHormone() {
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
        sites = SiteSchedule(store: mockStore, settings: mockSettings)

        _ = sites.suggested
        XCTAssertEqual(3, mockSettings.siteIndex.value)
    }
    
    public func testNextIndex_whenSitesCountIsZero_returnsNegativeOne() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings, resetWhenEmpty: false)
        let expected = -1
        let actual = sites.nextIndex
        XCTAssertEqual(expected, actual)
    }
    
    public func testNextIndex_whenDefaultsSiteIndexIsUnoccupied_returnsDefaultsSiteIndex() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        mockSettings.siteIndex = SiteIndexUD(2)
        let expected = 2
        let actual = sites.nextIndex
        XCTAssertEqual(expected, actual)
    }
    
    public func testNextIndex_whenDefaultsSiteIndexIsOccupied_returnsFirstSiteAfterDefaultsSiteIndexWithNoHormones() {
        let mockSites = [MockSite(), MockSite(), createMockOccupiedSite(hormoneCount: 2), MockSite()]
        mockStore.getStoredCollectionReturnValues = [mockSites]
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        mockSettings.siteIndex = SiteIndexUD(2)
        let expected = 3
        let actual = sites.nextIndex
        XCTAssertEqual(expected, actual)
    }
    
    public func testNextIndex_whenAllSitesAreOccupied_returnsSiteIndexWithOldestHormoneDate() {
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
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        
        let expected = 3
        let actual = sites.nextIndex
        XCTAssertEqual(expected, actual)
    }
    
    public func testIsDefault_whenSiteCountIsZero_returnsFalse() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings, resetWhenEmpty: false)
        XCTAssertFalse(sites.isDefault)
    }
    
    public func testIsDefault_whenIsDefault_returnsTrue() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        XCTAssertTrue(sites.isDefault)
    }
    
    public func testIsDefault_whenIsNotDefault_returnsFalse() {
        let mockSites = createOccupiedSites(hormoneCounts: [2, 3, 1, 3])
        mockStore.getStoredCollectionReturnValues = [mockSites]
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        XCTAssertFalse(sites.isDefault)
    }
    
    public func testInsertNew_callsSiteStoreCreateNewSiteWithExpectedArgs() {
        mockSettings.deliveryMethod = DeliveryMethodUD(.Injections)
        mockSettings.expirationInterval = ExpirationIntervalUD(.OnceWeekly)
        let testSite = MockSite()
        mockStore.newObjectFactory = { testSite }
        sites = SiteSchedule(store: mockStore, settings: mockSettings, resetWhenEmpty: false)
        sites.insertNew(name: "Doesn't matter", save: true, onSuccess: nil)
        XCTAssertTrue(mockStore.createNewSiteCallArgs[0])
    }
    
    public func testInsertNew_whenSuccessful_increaseCount() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings)  // starts with 4 sites
        sites.insertNew(name: "Doesn't matter", save: false, onSuccess: nil)
        let expected = 5
        let actual = sites.count
        XCTAssertEqual(expected, actual)
    }
    
    public func testInsertNew_whenSuccessful_insertsSiteWithGivenName() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        sites.insertNew(name: "Ok, now it matters I guess", save: false, onSuccess: nil)
        XCTAssert(sites.all.contains(where: { $0.name == "Ok, now it matters I guess" }))
    }
    
    public func testInsertNew_whenSuccessful_returnsNewlyInsertedSite() {
        let expected = MockSite()
        mockStore.newObjectFactory = { expected }
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        let actual = sites.insertNew(name: "Doesn't matter again.", save: false, onSuccess: nil)
        XCTAssertEqual(expected.id, actual!.id)
    }
    
    public func testInsertNew_whenSuccessful_callsOnSuccess() {
        var called = false
        let testClosure = { called = true }
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        sites.insertNew(name: "Doesn't matter", save: false, onSuccess: testClosure)
        XCTAssert(called)
    }
    
    public func testInsertNew_whenUnsuccessful_doesNotAffectCount() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings)  // starts with 4 sites
        mockStore.newObjectFactory = nil
        sites.insertNew(name: "Doesn't matter", save: false, onSuccess: nil)
        let expected = 4
        let actual = sites.count
        XCTAssertEqual(expected, actual)
    }
    
    public func testInsertNew_whenUnsuccessful_returnsNil() {
        mockStore.newObjectFactory = nil
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        sites.insertNew(name: "Doesn't matter", save: false, onSuccess: nil)
        XCTAssertNil(sites.insertNew(name: "Doesn't matter again.", save: false, onSuccess: nil))
    }
    
    public func testInsertNew_whenUnsuccessful_doesNotCallOnSuccess() {
        mockStore.newObjectFactory = nil
        var called = false
        let testClosure = { called = true }
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        sites.insertNew(name: "Doesn't matter", save: false, onSuccess: testClosure)
        XCTAssertFalse(called)
    }

    public func testReset_whenAlreadyDefault_returnsSameCount() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        let expected = sites.count
        let actual = sites.reset()
        XCTAssertEqual(expected, actual)
    }
    
    public func testReset_whenAlreadyDefault_doesNotChangeCount() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        let expected = sites.count
        sites.reset()
        let actual = sites.count
        XCTAssertEqual(expected, actual)
    }
    
    public func testReset_whenNotDefault_returnsExpectedCount() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings, resetWhenEmpty: false)  // Count = 0
        let expected = 4
        let actual = sites.reset()
        XCTAssertEqual(expected, actual)
    }
    
    public func testReset_whenNotDefault_changesCountToExpected() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings, resetWhenEmpty: false)
        let expected = 4
        sites.reset()
        let actual = sites.count
        XCTAssertEqual(expected, actual)
    }
    
    public func testReset_whenNotDefault_savesWithExpectedArgs() {
        let mockSites = [MockSite(), MockSite()]
        mockStore.getStoredCollectionReturnValues = [mockSites]
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        sites.reset()
        let args = mockStore.pushLocalChangesCallArgs[1]
        XCTAssert(args.0.count == 4 && args.0[0].id == mockSites[0].id && args.0[1].id == mockSites[1].id && args.1)
    }
    
    public func testReset_whenDeliveryMethodIsPatches_resetsToExpectedProperties() {
        mockSettings.deliveryMethod = DeliveryMethodUD(.Patches)
        sites = SiteSchedule(store: mockStore, settings: mockSettings, resetWhenEmpty: false)
        sites.reset()
        let siteOne = sites[0]!
        let siteTwo = sites[1]!
        let siteThree = sites[2]!
        let siteFour = sites[3]!
        XCTAssert(siteOne.name == "Right Glute" && siteOne.order == 0)
        XCTAssert(siteTwo.name == "Left Glute" && siteTwo.order == 1)
        XCTAssert(siteThree.name == "Right Abdomen" && siteThree.order == 2)
        XCTAssert(siteFour.name == "Left Abdomen" && siteFour.order == 3)
    }
    
    public func testReset_whenDeliveryMethodIsInjections_resetsToExpectedProperties() {
        mockSettings.deliveryMethod = DeliveryMethodUD(.Injections)
        sites = SiteSchedule(store: mockStore, settings: mockSettings, resetWhenEmpty: false)
        sites.reset()
        let siteOne = sites[0]!
        let siteTwo = sites[1]!
        let siteThree = sites[2]!
        let siteFour = sites[3]!
        let siteFive = sites[4]!
        let siteSix = sites[5]!
        XCTAssert(siteOne.name == "Right Quad" && siteOne.order == 0)
        XCTAssert(siteTwo.name == "Left Quad" && siteTwo.order == 1)
        XCTAssert(siteThree.name == "Right Glute" && siteThree.order == 2)
        XCTAssert(siteFour.name == "Left Glute" && siteFour.order == 3)
        XCTAssert(siteFive.name == "Right Delt" && siteFive.order == 4)
        XCTAssert(siteSix.name == "Left Delt" && siteSix.order == 5)
    }

    public func testReset_deletesExtrasIfNeeded() {
        let mockSites = [MockSite(), MockSite(), MockSite(), MockSite(), MockSite(), MockSite(), MockSite()]
        mockStore.getStoredCollectionReturnValues = [mockSites]
        sites = SiteSchedule(store: mockStore, settings: mockSettings, resetWhenEmpty: false)
        mockSettings.deliveryMethod = DeliveryMethodUD(.Patches)
        sites.reset()
        XCTAssertEqual(4, sites.count)
    }

    public func testDelete_decreasesCount() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings)  // Starts with 4
        sites.delete(at: 1)
        let expected = 3
        let actual = sites.count
        XCTAssertEqual(expected, actual)
    }

    public func testDelete_callsStoredDeleteWithExpectedArgs() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings)  // Starts with 4
        let expected = sites[1]!.id
        sites.delete(at: 1)
        let actual = mockStore.deleteCallArgs[0].id
        XCTAssertEqual(expected, actual)
    }

    public func testDelete_maintainsOrder() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        sites.delete(at: 1)
        XCTAssert(sites[0]!.order == 0 && sites[1]!.order == 1 && sites[2]!.order == 2)
    }

    public func testSort_keepsNegativeNumbersAtTheEnd() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        var site = sites[1]!
        site.order = -5
        sites.sort()
        let siteAgain = sites[3]!  // Last
        XCTAssertEqual(-5, siteAgain.order)
    }

    public func testSort_putsLowerPositiveNumbersAtBeginning() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        var siteOne = sites[0]!
        var siteTwo = sites[1]!
        var siteThree = sites[2]!
        var siteFour = sites[3]!
        
        siteOne.order = 6
        siteTwo.order = -9
        siteThree.order = 1
        siteFour.order = 4
        sites.sort()
        
        // Puts order 6 at end and order 1 becomes new first.
        XCTAssertTrue(
            sites[0]!.order == 1
            && sites[1]!.order == 4
            && sites[2]!.order == 6
            && sites[3]!.order == -9
        )
    }
    
    public func testSubscript_whenIndexOutOfBounds_returnsNil() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        XCTAssertNil(sites[5])
    }
    
    public func testSubscript_whenIndexInBounds_returnsSiteAtGivenIndex() {
        let mockSites = setUpSites(count: 3)
        let expected = mockSites[1].id
        let actual = sites[1]!.id
        XCTAssertEqual(expected, actual)
    }
    
    public func testGet_whenSiteDoesNotExist_returnsNil() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        XCTAssertNil(sites.get(by: UUID()))
    }
    
    public func testGet_whenSiteExists_returnsSite() {
        let mockSites = [MockSite(), MockSite(), MockSite()]
        let testId = mockSites[1].id
        mockStore.getStoredCollectionReturnValues = [mockSites]
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        XCTAssertNotNil(sites.get(by: testId))
    }
    
    public func testRename_whenSiteExists_renamesSite() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        sites.rename(at: 1, to: "New Name")
        let actual = sites[1]!.name
        XCTAssertEqual("New Name", actual)
    }
    
    public func testRename_whenSiteExists_saves() {
        let mockSites = setUpSites(count: 3)
        let expected = mockSites[1].id
        sites.rename(at: 1, to: "New Name")
        let args = mockStore.pushLocalChangesCallArgs[1]
        XCTAssert(args.0[0].id == expected && args.1)
    }
    
    public func testRename_whenSiteDoesNotExist_doesNotSave() {
        let mockSites = setUpSites(count: 3)
        mockStore.getStoredCollectionReturnValues = [mockSites]
        let newName = "New Name UHh"
        sites.rename(at: 5, to: newName)
        let args = mockStore.pushLocalChangesCallArgs
        XCTAssertFalse(args.contains(where: { $0.0.contains(where: { $0.name == newName }) }))
    }
    
    public func testReorder_whenFromIndexOutOfBounds_doesNotReorder() {
        let mockSites = setUpSites(count: 3)
        let expected = mockSites[1].id
        sites.reorder(at: 4, to: 1)
        let actual = sites[1]!.id  // Id didn't change at index
        XCTAssertEqual(expected, actual)
    }
    
    public func testReorder_whenToIndexOutOfBounds_doesNotReorder() {
        let mockSites = setUpSites(count: 3)
        let expected = mockSites[0].id
        sites.reorder(at: 0, to: 3)
        let actual = sites[0]!.id  // Id didn't change at index
        XCTAssertEqual(expected, actual)
    }
    
    public func testReorder_whenIndexesAreValid_swaps() {
        let mockSites = setUpSites(count: 3)
        let expected = mockSites[0].id
        sites.reorder(at: 0, to: 2)
        let actual = sites[2]!.id  // Id is now at index 1.
        XCTAssertEqual(expected, actual)
    }
    
    public func testReorder_whenArgumentsAreValid_saves() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        sites.reorder(at: 0, to: 1)
        let args = mockStore.pushLocalChangesCallArgs[1]
        XCTAssert(sites[0]!.id == args.0[0].id && sites[1]!.id == args.0[1].id && args.1)
    }
    
    public func testSetImageId_whenDeliveryMethodIsPatchesAndGivenADefaultSiteName_setsImageIdToSiteName() {
        mockSettings.deliveryMethod = DeliveryMethodUD(.Patches)
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        sites.setImageId(at: 0, to: "Right Glute")
        let expected = "Right Glute"
        let actual = sites[0]!.imageId
        XCTAssertEqual(expected, actual)
    }
    
    public func testSetImageId_whenDeliveryMethodIsInjectionsAndGivenADefaultSiteName_setsImageIdToSiteName() {
        mockSettings.deliveryMethod = DeliveryMethodUD(.Injections)
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        sites.setImageId(at: 0, to: "Right Delt")
        let expected = "Right Delt"
        let actual = sites[0]!.imageId
        XCTAssertEqual(expected, actual)
    }
    
    public func testSetImageId_whenGivenACustomString_setsImageIdToWordCustom() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        sites.setImageId(at: 0, to: "Right Eyeball")
        let expected = "custom"
        let actual = sites[0]!.imageId
        XCTAssertEqual(expected, actual)
    }
    
    public func testSetImageId_whenSiteAtIndexExists_saves() {
        mockSettings.deliveryMethod = DeliveryMethodUD(.Injections)
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        sites.setImageId(at: 0, to: "Right Delt")
        let args = mockStore.pushLocalChangesCallArgs[1]
        XCTAssert(args.0[0].imageId == "Right Delt" && args.1)
    }
    
    public func testSetImageId_whenSiteAtIndexDoesNotExist_doesNotSave() {
        mockSettings.deliveryMethod = DeliveryMethodUD(.Injections)
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        sites.setImageId(at: 11, to: "Right Eyeball")
        let args = mockStore.pushLocalChangesCallArgs
        XCTAssertFalse(args.contains(where: { $0.0.contains(where: { $0.imageId == "custom" }) }))
    }
    
    public func testFirstIndexOf_whenSiteExists_returnsFirstIndexOfSite() {
        let mockSites = setUpSites(count: 3)
        let testSite = mockSites[2]
        let expected = 2
        let actual = sites.indexOf(testSite)
        XCTAssertEqual(expected, actual)
    }
    
    public func testFirstIndexOf_whenSiteDoesNotExist_returnsNil() {
        sites = SiteSchedule(store: mockStore, settings: mockSettings)
        XCTAssertNil(sites.indexOf(MockSite()))
    }
}
