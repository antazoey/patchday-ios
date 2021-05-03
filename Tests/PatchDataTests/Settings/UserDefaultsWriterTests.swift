//
//  UserDefaultsWriterTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 5/9/20.

import XCTest
import PDKit
import PDTest

@testable
import PatchData

extension MockUserDefaults {
    func assertSettingWasSet<T>(expected: T, setting: PDSetting) where T: Equatable {
        let actual = setCallArgs.last(where: { $0.1 == setting.rawValue})!.0 as! T
        XCTAssertEqual(expected, actual)
    }
}

class UserDefaultsWriterTests: XCTestCase {

    private let defaults = MockUserDefaults()
    private let numOfHandlers = 2  // baseDefaults + dataSharer

    private var handler: UserDefaultsWriteHandler {
        UserDefaultsWriteHandler(baseDefaults: defaults, dataSharer: defaults)
    }

    private func createMockSiteStore(count: Int, freeHormoneIndex: Index) -> MockSiteStore {
        let store = MockSiteStore()
        store.siteCount = count
        var sites: [Bodily] = []
        if count > 0 {
            for i in 0..<count {
                let site = MockSite()
                site.order = i
                sites.append(site)
                // Sets all but one of the sites to have hormones
                if site.order != freeHormoneIndex {
                    site.hormoneCount = 1
                }
            }
        }
        store.getStoredCollectionReturnValues.append(sites)
        return store
    }

    func testReset() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        writer.reset()

        defaults.assertSettingWasSet(
            expected: DefaultSettings.DeliveryMethodRawValue, setting: PDSetting.DeliveryMethod
        )
        defaults.assertSettingWasSet(
            expected: DefaultSettings.QuantityRawValue, setting: PDSetting.Quantity
        )
        defaults.assertSettingWasSet(
            expected: DefaultSettings.ExpirationIntervalRawValue,
            setting: PDSetting.ExpirationInterval
        )
        defaults.assertSettingWasSet(
            expected: DefaultSettings.MentionedDisclaimerRawValue,
            setting: PDSetting.MentionedDisclaimer
        )
        defaults.assertSettingWasSet(
            expected: DefaultSettings.NotificationsMinutesBeforeRawValue,
            setting: PDSetting.NotificationsMinutesBefore
        )
        defaults.assertSettingWasSet(
            expected: DefaultSettings.NotificationsRawValue, setting: PDSetting.Notifications
        )
        defaults.assertSettingWasSet(
            expected: DefaultSettings.SiteIndexRawValue, setting: PDSetting.SiteIndex
        )
    }

    func testSetDeliveryMethod_whenSettingsToPatches_setsQuantityToDefault() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        defaults.mockObjectMap[PDSetting.DeliveryMethod.rawValue] = 2  // Not default
        writer.replaceStoredDeliveryMethod(to: .Patches)
        defaults.assertSettingWasSet(
            expected: DefaultSettings.DeliveryMethodRawValue, setting: PDSetting.DeliveryMethod
        )
    }

    func testReplaceStoredSiteIndex_whenIndexGreaterThanCount_replacesToZero() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let expected = 0
        let r = writer.replaceStoredSiteIndex(to: 50)
        XCTAssertEqual(expected, r)
        defaults.assertSettingWasSet(expected: expected, setting: PDSetting.SiteIndex)
    }

    func testIncrementStoredSiteIndex_whenRoomToIncrementAndNextIsFree_incrementsNormally() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 2)
        )
        defaults.mockObjectMap[PDSetting.SiteIndex.rawValue] = 1
        let expected = 2
        let res = writer.incrementStoredSiteIndex()
        XCTAssertEqual(expected, res)
        defaults.assertSettingWasSet(expected: expected, setting: PDSetting.SiteIndex)
    }

    func testIncrementStoredSiteIndex_whenSiteIndexEqualsCount_setsToFirstFreeHormoneIndex() {
        let siteCount = 4
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: siteCount, freeHormoneIndex: 1)
        )
        defaults.mockObjectMap[PDSetting.SiteIndex.rawValue] = siteCount
        let expected = 1
        let res = writer.incrementStoredSiteIndex()
        XCTAssertEqual(expected, res)
        defaults.assertSettingWasSet(expected: expected, setting: PDSetting.SiteIndex)
    }

    func testIncrementStoredSiteIndex_whenSiteIndexGreaterThanCount_setsToFirstFreeHormoneIndex() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 2)
        )
        defaults.mockObjectMap[PDSetting.SiteIndex.rawValue] = 7
        let expected = 2
        let r = writer.incrementStoredSiteIndex()
        XCTAssertEqual(expected, r)
        defaults.assertSettingWasSet(expected: expected, setting: PDSetting.SiteIndex)
    }

    func testIncrementSiteIndex_whenSiteCountZero_setsToFirstFreeHormoneIndex() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 0, freeHormoneIndex: 0)
        )
        defaults.mockObjectMap[PDSetting.SiteIndex.rawValue] = 7
        let expected = 0
        let r = writer.incrementStoredSiteIndex()
        XCTAssertEqual(expected, r)
        defaults.assertSettingWasSet(expected: expected, setting: PDSetting.SiteIndex)
    }

    func testIncrementSiteIndex_whenSiteIndexAtLastIndex_setsToFreeHormoneIndex() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 5, freeHormoneIndex: 0)
        )
        defaults.mockObjectMap[PDSetting.SiteIndex.rawValue] = 5
        let expected = 0
        let r = writer.incrementStoredSiteIndex()
        XCTAssertEqual(expected, r)
        defaults.assertSettingWasSet(expected: expected, setting: PDSetting.SiteIndex)
    }

    func testIncrementSiteIndex_whenSiteIndexNegative_setsToFirstFreeHormoneIndex() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 5, freeHormoneIndex: 0)
        )
        defaults.mockObjectMap[PDSetting.SiteIndex.rawValue] = -4
        let expected = 0
        let r = writer.incrementStoredSiteIndex()
        XCTAssertEqual(expected, r)
        defaults.assertSettingWasSet(expected: expected, setting: PDSetting.SiteIndex)
    }

    func testIncrementSiteIndex_whenSiteIndexZeroAndNextIsFree_setsToOne() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 1)
        )
        defaults.mockObjectMap[PDSetting.SiteIndex.rawValue] = 0
        let expected = 1
        let r = writer.incrementStoredSiteIndex()
        XCTAssertEqual(expected, r)
        defaults.assertSettingWasSet(expected: expected, setting: PDSetting.SiteIndex)
    }

    func testIncrementSiteIndex_whenGivenStartAndIndexAfterIsFree_usesGivenStart() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 3)
        )
        defaults.mockObjectMap[PDSetting.SiteIndex.rawValue] = 0
        let expected = 3
        let r = writer.incrementStoredSiteIndex(from: 2)
        XCTAssertEqual(expected, r)
        defaults.assertSettingWasSet(expected: expected, setting: PDSetting.SiteIndex)
    }

    func testIncrementSiteIndex_whenNextSiteIndexIsOccupied_returnsFirstIndexThatIsNotOccupied() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 3)
        )
        // Thinks it should be 0+1 but actually should be 3
        defaults.mockObjectMap[PDSetting.SiteIndex.rawValue] = 0
        let actual = writer.incrementStoredSiteIndex()
        let expected = 3
        XCTAssertEqual(expected, actual)
        defaults.assertSettingWasSet(expected: expected, setting: PDSetting.SiteIndex)
    }

    func testIncrementSiteIndex_whenFromSiteIndexIsOccupied_returnsFirstIndexThatIsNotOccupied() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 3)
        )
        defaults.mockObjectMap[PDSetting.SiteIndex.rawValue] = 0
        let expected = 3
        let actual = writer.incrementStoredSiteIndex(from: 1)
        XCTAssertEqual(expected, actual)
        defaults.assertSettingWasSet(expected: expected, setting: PDSetting.SiteIndex)
    }

    func testIncrementSiteIndex_whenCountIsMax_returnsSuggested() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 3)
        )
        defaults.mockObjectMap[PDSetting.Quantity.rawValue] = SupportedHormoneUpperQuantityLimit
        defaults.mockObjectMap[PDSetting.SiteIndex.rawValue] = 0
        let expected = 1
        let actual = writer.incrementStoredSiteIndex()
        XCTAssertEqual(expected, actual)
        defaults.assertSettingWasSet(expected: expected, setting: PDSetting.SiteIndex)
    }
}
