//
//  HormoneScheduleTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 1/1/19.
//  

import XCTest
import PDKit
import PDTest

@testable
import PatchData

class HormoneScheduleTests: PDTestCase {

    private var mockSharer: MockHormoneDataSharer!
    private var mockStore: MockHormoneStore!
    private var mockSettings: MockUserDefaultsWriter!
    private var hormones: HormoneSchedule!

    override func setUp() {
        super.setUp()
        mockSharer = MockHormoneDataSharer()
        mockStore = MockHormoneStore()
        mockSettings = MockUserDefaultsWriter()
    }

    private func setUpHormones(_ mockHormones: [Hormonal] = []) {
        mockStore.getStoredCollectionReturnValues = [mockHormones]
        hormones = HormoneSchedule(
            store: mockStore,
            hormoneDataSharer: mockSharer,
            settings: mockSettings
        )
    }

    private func setUpEmptyHormones() {
        mockStore.newObjectFactory = nil
        setUpHormones()
    }

    @discardableResult
    private func setUpDefaultHormones(_ count: Int) -> [MockHormone] {
        let mockHormones = MockHormone.createList(count: count)
        setUpHormones(mockHormones)
        return mockHormones
    }

    func testIsEmpty_whenADateIsInSchedule_returnsFalse() {
        let mockHormones = setUpDefaultHormones(3)
        mockHormones[1].date = Date()
        XCTAssertFalse(hormones.isEmpty)
    }

    func testIsEmpty_whenASiteIsInSchedule_returnsFalse() {
        let mockHormones = setUpDefaultHormones(3)
        mockHormones[1].siteId = UUID()
        XCTAssertFalse(hormones.isEmpty)
    }

    func testIsEmpty_whenASiteBackupNameIsInSchedule_returnsFalse() {
        let mockHormones = setUpDefaultHormones(3)
        mockHormones[1].siteNameBackUp = "Ooga Booga"
        XCTAssertFalse(hormones.isEmpty)
    }

    func testIsEmpty_whenThereAreNoSiteIdsOrSiteBackupNamesOrNonDefaultDatesInTheSchedule_returnsTrue() {
        setUpDefaultHormones(3)
        XCTAssertTrue(hormones.isEmpty)
    }

    func testIsEmpty_whenCountIsZero_returnsTrue() {
        setUpEmptyHormones()
        XCTAssertTrue(hormones.isEmpty)
    }

    func testNext_whenThereAreNoHormones_ReturnsNil() {
        setUpEmptyHormones()
        XCTAssertNil(hormones.next)
    }

    func testNext_whenThereAreHormones_returnsHormonesWithOldestDate() {
        let mockHormones = MockHormone.createList(count: 3)
        mockHormones[0].date = Date()
        mockHormones[1].date = Date(timeIntervalSinceNow: -5000) // Oldest
        mockHormones[2].date = Date(timeIntervalSinceNow: -1000)
        setUpHormones(mockHormones)
        let expected = mockHormones[1]
        let actual = hormones.next
        XCTAssertEqual(expected.id, actual?.id)
    }

    func testTotalExpired_returnsCountOfHormonesExpired() {
        let mockHormones = MockHormone.createList(count: 3)
        mockHormones[0].isExpired = true
        mockHormones[1].isExpired = true
        mockHormones[2].isExpired = false
        setUpHormones(mockHormones)
        let expected = 2
        let actual = hormones.totalExpired
        XCTAssertEqual(expected, actual)
    }

    func testTotalExpired_usingRealHormoneType_returnsCountOfHormonesExpired() {
        let testDate = DateFactory.createDate(daysFrom: -20)
        let data1 = HormoneStruct(UUID(), nil, nil, nil, testDate, nil, nil)
        let data2 = HormoneStruct(UUID(), nil, nil, nil, testDate, nil, nil)
        let hormone1 = Hormone(hormoneData: data1, settings: mockSettings)
        let hormone2 = Hormone(hormoneData: data2, settings: mockSettings)
        setUpHormones([hormone1, hormone2])
        XCTAssertEqual(2, hormones.totalExpired)
        hormones.setDate(at: 0, with: Date())
        XCTAssertEqual(1, hormones.totalExpired)
    }

#if targetEnvironment(simulator)
    /// Integration
    func testTotalExpired_afterSettingDate_reflectsAccurately() {
        let mockSettings = MockSettings()
        let testDate = DateFactory.createDate(daysFrom: -20)
        let data1 = HormoneStruct(UUID(), nil, nil, nil, testDate, nil, nil)
        let data2 = HormoneStruct(UUID(), nil, nil, nil, testDate, nil, nil)
        let hormone1 = Hormone(hormoneData: data1, settings: mockSettings)
        let hormone2 = Hormone(hormoneData: data2, settings: mockSettings)
        setUpHormones([hormone1, hormone2])
        hormones.setDate(at: 0, with: Date())
        let expected = 1
        let actual = hormones.totalExpired
        XCTAssertEqual(expected, actual)
    }
#endif

    func testUseStaticExpirationTime_returnsValueFromSettings() {
        setUpDefaultHormones(1)
        mockSettings.useStaticExpirationTime = UseStaticExpirationTimeUD(true)
        XCTAssertTrue(hormones.useStaticExpirationTime)
        mockSettings.useStaticExpirationTime = UseStaticExpirationTimeUD(false)
        XCTAssertFalse(hormones.useStaticExpirationTime)
    }

    func testInsertNew_whenStoreReturnsNil_doesNotIncreaseHormoneCount() {
        setUpDefaultHormones(3)
        mockStore.newObjectFactory = nil
        hormones.insertNew()
        let expected = 3
        let actual = hormones.count
        XCTAssertEqual(expected, actual)
    }

    func testInsertNew_whenStoreReturnsHormone_increasesCount() {
        setUpDefaultHormones(3)
        let newHormone = MockHormone()
        mockStore.newObjectFactory = { () in newHormone }
        hormones.insertNew()
        let expected = 4
        let actual = hormones.count
        XCTAssertEqual(expected, actual)
    }

    func testInsertNew_whenStoreReturnsHormone_containsHormoneInAll() {
        setUpDefaultHormones(3)
        let newHormone = MockHormone()
        mockStore.newObjectFactory = { () in newHormone }
        hormones.insertNew()
        XCTAssertTrue(hormones.all.contains(where: { $0.id == newHormone.id }))
    }

    func testInsertNew_whenStoreReturnsHormone_maintainsOrder() {
        let mockHormones = MockHormone.createList(count: 3)
        mockHormones[0].date = Date()
        mockHormones[1].date = Date(timeIntervalSinceNow: -5000) // Original oldest
        mockHormones[2].date = Date(timeIntervalSinceNow: -1000)
        let newHormone = MockHormone()
        newHormone.date = Date(timeIntervalSinceNow: -999999) // New oldest
        setUpHormones(mockHormones)
        mockStore.newObjectFactory = { () in newHormone }
        hormones.insertNew()
        let expected = newHormone
        let actual = hormones.all.first
        XCTAssertEqual(expected.id, actual?.id)
    }

    func testResetIfEmpty_ifHormonesNotEmpty_returnsCount() {
        let mockHormones = MockHormone.createList(count: 3)
        setUpHormones(mockHormones)
        let expected = mockHormones.count
        let actual = hormones.resetIfEmpty()
        XCTAssertEqual(expected, actual)
    }

    func testResetIfEmpty_ifHormonesNotEmpty_doesNotResetSites() {
        let mockHormones = MockHormone.createList(count: 1)
        let unexpectedId = UUID()
        mockHormones[0].id = unexpectedId
        setUpHormones(mockHormones)
        hormones.reset()
        XCTAssert(!hormones.all.contains(where: { $0.id == unexpectedId }))
    }

    func testReset_ifDeliveryMethodIsPatches_resetsHormonesCountToThree() {
        mockSettings.deliveryMethod = DeliveryMethodUD(.Patches)
        setUpHormones()
        hormones.reset()
        XCTAssertEqual(3, hormones.count)
    }

    func testReset_ifDeliveryMethodIsPatches_returnsThree() {
        mockSettings.deliveryMethod = DeliveryMethodUD(.Patches)
        setUpHormones()
        let actual = hormones.reset()
        XCTAssertEqual(3, actual)
    }

    func testReset_ifDeliveryMethodIsInjections_resetsHormonesCountToOne() {
        mockSettings.deliveryMethod = DeliveryMethodUD(.Injections)
        setUpHormones()
        hormones.reset()
        XCTAssertEqual(1, hormones.count)
    }

    func testReset_ifDeliveryMethodIsInjections_returnsOnes() {
        mockSettings.deliveryMethod = DeliveryMethodUD(.Injections)
        setUpHormones()
        let actual = hormones.reset()
        XCTAssertEqual(1, actual)
    }

    func testReset_ifGivenClosure_callsClosure() {
        mockSettings.deliveryMethod = DeliveryMethodUD(.Injections)
        setUpHormones()
        var closureWasCalled = false
        let testClosure = { closureWasCalled = true }
        hormones.reset(completion: testClosure)
        XCTAssertTrue(closureWasCalled)
    }

    func testDeleteAfterIndex_whenIndexGreaterThanCount_doesNotDeleteAnything() {
        let mockHormones = MockHormone.createList(count: 1)
        setUpHormones(mockHormones)
        hormones.delete(after: 1)
        XCTAssertEqual(1, hormones.count)
    }

    func testDeleteAfterIndex_whenIndexLessThanCount_deletesAfterIndex() {
        let mockHormones = MockHormone.createList(count: 3)
        setUpHormones(mockHormones)
        hormones.delete(after: 1)
        XCTAssertEqual(2, hormones.count)
    }

    func testSaveAll_whenCountIsZero_doesNotCallSave() {
        mockStore.newObjectFactory = nil
        setUpHormones()
        hormones.saveAll()
        PDAssertEmpty(mockStore.pushLocalChangesCallArgs)
    }

    func testDeleteAll_whenCountIsZero_doesNotCallStoreDelete() {
        mockStore.newObjectFactory = nil
        setUpHormones()
        hormones.deleteAll()
        PDAssertEmpty(mockStore.deleteCallArgs)
    }

    func testSubscript_whenIndexOutOfBound_returnsNil() {
        setUpDefaultHormones(1)
        let actual = hormones[1]
        XCTAssertNil(actual)
    }

    func testSubscript_whenIndexInBounds_returnsHormone() {
        let mockHormones = setUpDefaultHormones(2)
        let expectedId = UUID()
        mockHormones[1].id = expectedId
        let actualId = hormones[1]?.id
        XCTAssertEqual(expectedId, actualId)
    }

    func testSubscript_whenHormoneDoesNotExist_returnsNil() {
        setUpDefaultHormones(2)
        XCTAssertNil(hormones[UUID()])
    }

    func testSubscript_returnsHormoneForGivenId() {
        let mockHormones = setUpDefaultHormones(2)
        let expectedId = UUID()
        mockHormones[1].id = expectedId
        let actualId = hormones[expectedId]?.id
        XCTAssertEqual(expectedId, actualId)
    }

    func testSet_whenGivenId_setsDateAndSiteOfHormoneWithGivenId() {
        let mockHormones = setUpDefaultHormones(1)
        let expectedId = UUID()
        mockHormones[0].id = expectedId
        let testDate = Date()
        let testSite = MockSite()
        testSite.id = UUID()
        hormones.set(by: expectedId, date: testDate, site: testSite)
        let actual = mockHormones[0]
        XCTAssertEqual(testDate, actual.date)
        XCTAssertEqual(testSite.id, actual.siteId)
    }

    func testSet_whenGivenId_callsPushWithExpectedArgs() {
        let mockHormones = setUpDefaultHormones(1)
        let testId = UUID()
        mockHormones[0].id = testId
        hormones.set(by: testId, date: Date(), site: MockSite())
        let callArgs = mockStore.pushLocalChangesCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(mockHormones[0].id, callArgs[0].0[0].id)
        XCTAssertTrue(callArgs[0].1)
    }

    func testSet_whenGivenIndex_setsDateAndSiteOfHormoneAtIndex() {
        let mockHormones = setUpDefaultHormones(1)
        let expectedId = UUID()
        mockHormones[0].id = expectedId
        let testSite = MockSite()
        testSite.id = UUID()
        let testDate = Date()
        let testIndex = 0
        hormones.set(at: testIndex, date: testDate, site: testSite)
        let actual = mockHormones[testIndex]
        XCTAssertEqual(testDate, actual.date)
        XCTAssertEqual(testSite.id, actual.siteId)
    }

    func testSet_whenGivenIndex_callsPushWithExpectedArgs() {
        let mockHormones = setUpDefaultHormones(1)
        let testId = UUID()
        mockHormones[0].id = testId
        hormones.set(at: 0, date: Date(), site: MockSite())
        let callArgs = mockStore.pushLocalChangesCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(mockHormones[0].id, callArgs[0].0[0].id)
        XCTAssertTrue(callArgs[0].1)
    }

    func testSet_validId_setsSiteIndexToIncrementedIndexFromSite() {
        let mockHormones = setUpDefaultHormones(1)
        let testId = UUID()
        mockHormones[0].id = testId
        let site = MockSite()
        site.order = 2
        hormones.set(at: 0, date: Date(), site: site)
        XCTAssertEqual(2, mockSettings.incrementStoredSiteIndexCallArgs[0])
    }

    func testSet_invalidId_doesNotBumpSiteIndex() {
        let mockHormones = setUpDefaultHormones(1)
        let testId = UUID()
        mockHormones[0].id = testId
        hormones.set(at: 2335252, date: Date(), site: MockSite())
        XCTAssertEqual(0, mockSettings.siteIndex.rawValue)
    }

    func testSetDate_withId_sets() {
        let mockHormones = setUpDefaultHormones(1)
        let testId = UUID()
        let testDate = Date()
        mockHormones[0].id = testId
        hormones.setDate(by: testId, with: testDate)
        XCTAssertEqual(mockHormones[0].date, testDate)
    }

    func testSetDate_withId_callsPushWithExpectedArgs() {
        let mockHormones = setUpDefaultHormones(1)
        let testId = UUID()
        mockHormones[0].id = testId
        hormones.setDate(by: testId, with: Date())
        let callArgs = mockStore.pushLocalChangesCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(mockHormones[0].id, callArgs[0].0[0].id)
        XCTAssertTrue(callArgs[0].1)
    }

    func testSetDate_withId_sharesData() {
        let testId = UUID()
        let mockHormones = setUpDefaultHormones(1)
        mockHormones[0].id = testId
        mockSharer.resetMock()
        hormones.setDate(by: testId, with: Date())
        let callArgs = mockSharer.shareCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(testId, callArgs[0].id)
    }

    func testSetDate_withIndex_sets() {
        let mockHormones = setUpDefaultHormones(1)
        let testDate = Date()
        hormones.setDate(at: 0, with: testDate)
        XCTAssertEqual(mockHormones[0].date, testDate)
    }

    func testSetDate_withIndex_callsPushWithExpectedArgs() {
        let mockHormones = setUpDefaultHormones(1)
        hormones.setDate(at: 0, with: Date())
        let callArgs = mockStore.pushLocalChangesCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(mockHormones[0].id, callArgs[0].0[0].id)
        XCTAssertTrue(callArgs[0].1)
    }

    func testSetDate_withIndex_sharesData() {
        let testId = UUID()
        let mockHormones = setUpDefaultHormones(1)
        mockHormones[0].id = testId
        mockSharer.resetMock()
        hormones.setDate(at: 0, with: Date())
        let callArgs = mockSharer.shareCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(testId, callArgs[0].id)
    }

    func testSet_whenGivenValidIndex_incrementSiteIndexFromSiteOrder() {
        setUpDefaultHormones(1)
        let site = MockSite()
        site.order = 1
        hormones.set(at: 0, date: Date(), site: site)
        XCTAssertEqual(1, mockSettings.incrementStoredSiteIndexCallArgs[0])
    }

    func testSet_whenNotGivenValidIndex_doesNotBumpSiteIndex() {
        setUpDefaultHormones(1)
        hormones.set(at: 2335252, date: Date(), site: MockSite())
        XCTAssertEqual(0, mockSettings.siteIndex.rawValue)
    }

    func testSetSite_withId_sets() {
        let mockHormones = setUpDefaultHormones(1)
        let testId = UUID()
        let testSite = MockSite()
        let testSiteId = UUID()
        testSite.id = testSiteId
        mockHormones[0].id = testId
        hormones.setSite(by: testId, with: testSite)
        XCTAssertEqual(mockHormones[0].siteId, testSiteId)
    }

    func testSetSite_withId_callsPushWithExpectedArgs() {
        let mockHormones = setUpDefaultHormones(1)
        let testId = UUID()
        mockHormones[0].id = testId
        hormones.setSite(by: testId, with: MockSite())
        let callArgs = mockStore.pushLocalChangesCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(mockHormones[0].id, callArgs[0].0[0].id)
        XCTAssertTrue(callArgs[0].1)
    }

    func testSetSite_withId_sharesData() {
        let mockHormones = setUpDefaultHormones(1)
        let testId = UUID()
        mockHormones[0].id = testId
        mockSharer.shareCallArgs = []
        hormones.setSite(by: testId, with: MockSite())
        let callArgs = mockSharer.shareCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(testId, callArgs[0].id)
    }

    func testSetSite_withIndex_sets() {
        let mockHormones = setUpDefaultHormones(1)
        let testSite = MockSite()
        let testSiteId = UUID()
        testSite.id = testSiteId
        hormones.setSite(at: 0, with: testSite)
        XCTAssertEqual(mockHormones[0].siteId, testSiteId)
    }

    func testSetSite_withIndex_callsPushWithExpectedArgs() {
        let mockHormones = setUpDefaultHormones(1)
        hormones.setSite(at: 0, with: MockSite())
        let callArgs = mockStore.pushLocalChangesCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(mockHormones[0].id, callArgs[0].0[0].id)
        XCTAssertTrue(callArgs[0].1)
    }

    func testSetSite_withIndex_sharesData() {
        let mockHormones = setUpDefaultHormones(1)
        let testId = UUID()
        mockHormones[0].id = testId
        mockSharer.shareCallArgs = []
        hormones.setSite(at: 0, with: MockSite())
        let callArgs = mockSharer.shareCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(testId, callArgs[0].id)
    }

    func testSetSite_validId_incrementsSiteIndexFromSiteIndexSetting() {
        let mockHormones = setUpDefaultHormones(1)
        let testId = UUID()
        mockHormones[0].id = testId
        let site = MockSite()
        site.order = 2
        hormones.setSite(by: testId, with: site)
        XCTAssertEqual(site.order, mockSettings.incrementStoredSiteIndexCallArgs[0])
    }

    func testSetSite_validIndex_incrementsSiteIndexFromSiteIndexSetting() {
        setUpDefaultHormones(1)
        let site = MockSite()
        site.order = 0
        hormones.setSite(at: 0, with: site)
        XCTAssertEqual(0, mockSettings.incrementStoredSiteIndexCallArgs[0])
    }

    func testSetSite_InvalidId_doesNotBumpSiteIndex() {
        setUpDefaultHormones(1)
        hormones.setSite(by: UUID(), with: MockSite())
        PDAssertEmpty(mockSettings.replaceSiteIndexCallArgs)
        XCTAssertEqual(0, mockSettings.siteIndex.rawValue)
    }

    func testSetSite_InvalidIndex_doesNotBumpSiteIndex() {
        setUpDefaultHormones(1)
        hormones.setSite(at: 23523, with: MockSite())
        PDAssertEmpty(mockSettings.replaceSiteIndexCallArgs)
        XCTAssertEqual(0, mockSettings.siteIndex.rawValue)
    }

    func testSetSiteName_clearsSite() {
        let mockHormones = setUpDefaultHormones(1)
        let testId = UUID()
        mockHormones[0].id = testId
        hormones.setSiteName(by: testId, with: "TEST")
        let actual = mockStore.clearSitesFromHormoneCallArgs[0]
        XCTAssertEqual(testId, actual)
    }

    func testIndexOf_whenGiveHormoneIsInSchedule_returnsIndexOfGivenHormone() {
        let mockHormones = setUpDefaultHormones(2)
        let expected = 1
        let actual = hormones.indexOf(mockHormones[1])
        XCTAssertEqual(expected, actual)
    }

    func testIndexOf_whenGivenHormoneThatIsNotInSchedule_returnsNil() {
        setUpDefaultHormones(2)
        let testHormone = MockHormone()
        let actual = hormones.indexOf(testHormone)
        XCTAssertNil(actual)
    }

    func testFillIn_whenWhenStopCountGreaterThanCurrentCount_createsNewHormonesToMakeCountEqualToStopCount() {
        setUpDefaultHormones(2)
        hormones.fillIn(to: 4)
        let expected = 4
        let actual = hormones.count
        XCTAssertEqual(expected, actual)
    }

    func testFillIn_whenStopCountIsEqualToCurrentCount_doesNotIncreaseCount() {
        setUpDefaultHormones(2)
        hormones.fillIn(to: 2)
        let expected = 2
        let actual = hormones.count
        XCTAssertEqual(expected, actual)
    }

    func testFillIn_whenStopCountIsLessThanCurrentCount_doesNotCreateMoreHormones() {
        setUpDefaultHormones(4)
        hormones.fillIn(to: 2)
        let expected = 4
        let actual = hormones.count
        XCTAssertEqual(expected, actual)
    }

    func testShareData_whenEmptySchedule_doesNotCallBroadcaster() {
        setUpEmptyHormones()
        hormones.shareData()
        PDAssertEmpty(mockSharer.shareCallArgs)
    }

    func testShareData_callSharerWithExpectedArg() {
        let testId = UUID()
        setUpDefaultHormones(1)[0].id = testId
        mockSharer.resetMock()
        hormones.shareData()
        let callArgs = mockSharer.shareCallArgs
        PDAssertSingle(callArgs)
        XCTAssertEqual(testId, callArgs[0].id)
    }
}
