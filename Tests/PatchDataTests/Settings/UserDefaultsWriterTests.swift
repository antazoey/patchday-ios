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
        guard let actual = setCallArgs.last(where: { $0.1 == setting.rawValue})?.0 as? T else {
            XCTFail("\(setting) was never set to \(expected).")
            return
        }
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

    func testDeliveryMethod_whenLoadsValue_usesLoadedValue() {
        defaults.mockObjectMap[PDSetting.DeliveryMethod.rawValue] = DeliveryMethodUD.GelKey
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let actual = writer.deliveryMethod.rawValue
        let expected = DeliveryMethodUD.GelKey
        XCTAssertEqual(expected, actual)
    }

    func testDeliveryMethod_whenNoStoredValue_usesDefaultValue() {
        defaults.mockObjectMap[PDSetting.DeliveryMethod.rawValue] = nil
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let actual = writer.deliveryMethod.rawValue
        let expected = DeliveryMethodUD.PatchesKey
        XCTAssertEqual(expected, actual)
    }

    func testExpirationInterval_whenLoadsValue_usesLoadedValue() {
        let key = ExpirationIntervalUD.EveryTwoWeeksKey
        defaults.mockObjectMap[PDSetting.ExpirationInterval.rawValue] = key
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let actual = writer.expirationInterval.rawValue
        let expected = ExpirationIntervalUD.EveryTwoWeeksKey
        XCTAssertEqual(expected, actual)
    }

    func testExpirationInterval_whenNoStoredValue_usesDefaultValue() {
        defaults.mockObjectMap[PDSetting.ExpirationInterval.rawValue] = nil
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let actual = writer.expirationInterval.rawValue
        let expected = DefaultSettings.ExpirationIntervalRawValue
        XCTAssertEqual(expected, actual)
    }

    func testExpirationInterval_whenHasStoredXDaysValueAndIsEveryXDaysInterval_setsXDays() {
        let xDaysExp = ExpirationIntervalUD.EveryXDaysKey
        defaults.mockObjectMap[PDSetting.ExpirationInterval.rawValue] = xDaysExp
        defaults.mockObjectMap[PDSetting.XDays.rawValue] = "11.5"
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let actual = writer.expirationInterval.xDays.value
        let expected = "11.5"
        XCTAssertEqual(expected, actual)
    }

    func testExpirationInterval_whenDoesNotHaveStoredXDaysValueAndIsEveryXDaysInterval_usesDefault() {
        let xDaysExp = ExpirationIntervalUD.EveryXDaysKey
        defaults.mockObjectMap[PDSetting.ExpirationInterval.rawValue] = xDaysExp
        defaults.mockObjectMap[PDSetting.XDays.rawValue] = nil  // Does not have
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let actual = writer.expirationInterval.xDays.value
        let expected = DefaultSettings.XDaysRawValue
        XCTAssertEqual(expected, actual)
    }

    func testExpirationInterval_whenIsOnceDaily_setsToOne() {
        let xDaysExp = ExpirationIntervalUD.OnceDailyKey
        defaults.mockObjectMap[PDSetting.ExpirationInterval.rawValue] = xDaysExp

        // Set stored value to prove that it doesn't matter.
        defaults.mockObjectMap[PDSetting.XDays.rawValue] = "2.5"

        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let actual = writer.expirationInterval.xDays.value
        let expected = "1.0"
        XCTAssertEqual(expected, actual)
    }

    func testExpirationInterval_whenIsTwiceWeekly_setsToThreePointFive() {
        let xDaysExp = ExpirationIntervalUD.TwiceWeeklyKey
        defaults.mockObjectMap[PDSetting.ExpirationInterval.rawValue] = xDaysExp

        // Set stored value to prove that it doesn't matter.
        defaults.mockObjectMap[PDSetting.XDays.rawValue] = "2.5"

        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let actual = writer.expirationInterval.xDays.value
        let expected = "3.5"
        XCTAssertEqual(expected, actual)
    }

    func testExpirationInterval_whenIsOnceWeekly_setsToSeven() {
        let xDaysExp = ExpirationIntervalUD.OnceWeeklyKey
        defaults.mockObjectMap[PDSetting.ExpirationInterval.rawValue] = xDaysExp

        // Set stored value to prove that it doesn't matter.
        defaults.mockObjectMap[PDSetting.XDays.rawValue] = "2.5"

        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let actual = writer.expirationInterval.xDays.value
        let expected = "7.0"
        XCTAssertEqual(expected, actual)
    }

    func testExpirationInterval_whenIsEveryTwoWeeks_setsToFourteen() {
        let xDaysExp = ExpirationIntervalUD.EveryTwoWeeksKey
        defaults.mockObjectMap[PDSetting.ExpirationInterval.rawValue] = xDaysExp

        // Set stored value to prove that it doesn't matter.
        defaults.mockObjectMap[PDSetting.XDays.rawValue] = "2.5"

        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let actual = writer.expirationInterval.xDays.value
        let expected = "14.0"
        XCTAssertEqual(expected, actual)
    }

    func testQuantity_whenLoadsValue_usesLoadedValue() {
        defaults.mockObjectMap[PDSetting.Quantity.rawValue] = 2
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let actual = writer.quantity.rawValue
        let expected = 2
        XCTAssertEqual(expected, actual)
    }

    func testQuantity_whenNoStoredValue_usesDefaultValue() {
        defaults.mockObjectMap[PDSetting.Quantity.rawValue] = nil
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let actual = writer.quantity.rawValue
        let expected = DefaultSettings.QuantityRawValue
        XCTAssertEqual(expected, actual)
    }

    func testNotifications_whenLoadsValue_usesLoadedValue() {
        defaults.mockObjectMap[PDSetting.Notifications.rawValue] = false
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let actual = writer.notifications.rawValue
        let expected = false
        XCTAssertEqual(expected, actual)
    }

    func testNotifications_whenNoStoredValue_usesDefaultValue() {
        defaults.mockObjectMap[PDSetting.Notifications.rawValue] = nil
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let actual = writer.notifications.rawValue
        let expected = DefaultSettings.NotificationsRawValue
        XCTAssertEqual(expected, actual)
    }

    func testNotificationsMinutesBefore_whenLoadsValue_usesLoadedValue() {
        defaults.mockObjectMap[PDSetting.NotificationsMinutesBefore.rawValue] = 20
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let actual = writer.notificationsMinutesBefore.rawValue
        let expected = 20
        XCTAssertEqual(expected, actual)
    }

    func testNotificationsMinutesBefore_whenNoStoredValue_usesDefaultValue() {
        defaults.mockObjectMap[PDSetting.Notifications.rawValue] = nil
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let actual = writer.notificationsMinutesBefore.rawValue
        let expected = DefaultSettings.NotificationsMinutesBeforeRawValue
        XCTAssertEqual(expected, actual)
    }

    func testMentionedDisclaimer_whenLoadsValue_usesLoadedValue() {
        defaults.mockObjectMap[PDSetting.MentionedDisclaimer.rawValue] = true
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let actual = writer.mentionedDisclaimer.rawValue
        let expected = true
        XCTAssertEqual(expected, actual)
    }

    func testMentionedDisclaimer_whenNoStoredValue_usesDefaultValue() {
        defaults.mockObjectMap[PDSetting.Notifications.rawValue] = nil
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let actual = writer.mentionedDisclaimer.rawValue
        let expected = DefaultSettings.MentionedDisclaimerRawValue
        XCTAssertEqual(expected, actual)
    }

    func testSiteIndex_whenLoadsValue_usesLoadedValue() {
        defaults.mockObjectMap[PDSetting.SiteIndex.rawValue] = 2
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let actual = writer.siteIndex.rawValue
        let expected = 2
        XCTAssertEqual(expected, actual)
    }

    func testSiteIndex_whenNoStoredValue_usesDefaultValue() {
        defaults.mockObjectMap[PDSetting.SiteIndex.rawValue] = nil
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let actual = writer.siteIndex.rawValue
        let expected = DefaultSettings.SiteIndexRawValue
        XCTAssertEqual(expected, actual)
    }

    func testPillsEnabled_whenLoadsValue_usesLoadedValue() {
        defaults.mockObjectMap[PDSetting.PillsEnabled.rawValue] = false
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let actual = writer.pillsEnabled.rawValue
        let expected = false
        XCTAssertEqual(expected, actual)
    }

    func testPillsEnabled_whenNoStoredValue_usesDefaultValue() {
        defaults.mockObjectMap[PDSetting.PillsEnabled.rawValue] = nil
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let actual = writer.pillsEnabled.rawValue
        let expected = DefaultSettings.PillsEnabledRawValue
        XCTAssertEqual(expected, actual)
    }

    func testReset() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        writer.reset()

        defaults.assertSettingWasSet(
            expected: DefaultSettings.DeliveryMethodRawValue, setting: .DeliveryMethod
        )
        defaults.assertSettingWasSet(
            expected: DefaultSettings.QuantityRawValue, setting: .Quantity
        )
        defaults.assertSettingWasSet(
            expected: DefaultSettings.ExpirationIntervalRawValue,
            setting: .ExpirationInterval
        )
        defaults.assertSettingWasSet(
            expected: DefaultSettings.MentionedDisclaimerRawValue,
            setting: .MentionedDisclaimer
        )
        defaults.assertSettingWasSet(
            expected: DefaultSettings.NotificationsMinutesBeforeRawValue,
            setting: .NotificationsMinutesBefore
        )
        defaults.assertSettingWasSet(
            expected: DefaultSettings.NotificationsRawValue, setting: .Notifications
        )
        defaults.assertSettingWasSet(
            expected: DefaultSettings.SiteIndexRawValue, setting: .SiteIndex
        )
    }

    func testReplaceStoredDeliveryMethod_replaces() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        defaults.mockObjectMap[PDSetting.DeliveryMethod.rawValue] = 2  // Not default
        writer.replaceStoredDeliveryMethod(to: .Patches)
        defaults.assertSettingWasSet(
            expected: DeliveryMethodUD.PatchesKey, setting: .DeliveryMethod
        )
    }

    func testReplaceStoredQuantity_replaces() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        defaults.mockObjectMap[PDSetting.Quantity.rawValue] = 2  // Not default
        writer.replaceStoredQuantity(to: 2)
        defaults.assertSettingWasSet(expected: 2, setting: .Quantity)
    }

    func testReplaceStoredExpirationInterval_replaces() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        defaults.mockObjectMap[PDSetting.ExpirationInterval.rawValue] = "not default"
        writer.replaceStoredExpirationInterval(to: ExpirationInterval.EveryTwoWeeks)
        let expected = ExpirationIntervalUD.EveryTwoWeeksKey
        defaults.assertSettingWasSet(expected: expected, setting: .ExpirationInterval)
    }

    func testReplaceStoredXDays_replaces() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        defaults.mockObjectMap[PDSetting.XDays.rawValue] = "not default"
        writer.replaceStoredXDays(to: "5.5")
        defaults.assertSettingWasSet(expected: "5.5", setting: .XDays)
    }

    func testReplaceStoredNotifications_replaces() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        defaults.mockObjectMap[PDSetting.Notifications.rawValue] = false
        writer.replaceStoredNotifications(to: true)
        defaults.assertSettingWasSet(expected: true, setting: .Notifications)
    }

    func testReplaceStoredNotificationsMinutesBefore_replaces() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        defaults.mockObjectMap[PDSetting.NotificationsMinutesBefore.rawValue] = 22
        writer.replaceStoredNotificationsMinutesBefore(to: 23)
        defaults.assertSettingWasSet(expected: 23, setting: .NotificationsMinutesBefore)
    }

    func testReplaceStoredMentionedDisclaimer_replaces() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        defaults.mockObjectMap[PDSetting.MentionedDisclaimer.rawValue] = false
        writer.replaceStoredMentionedDisclaimer(to: true)
        defaults.assertSettingWasSet(expected: true, setting: .MentionedDisclaimer)
    }

    func testReplaceStoredPillsEnabled_replaces() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        defaults.mockObjectMap[PDSetting.PillsEnabled.rawValue] = false
        writer.replaceStoredPillsEnabled(to: true)
        defaults.assertSettingWasSet(expected: true, setting: .PillsEnabled)
    }

   // func testReplaceStoredPills

    func testReplaceStoredSiteIndex_whenIndexGreaterThanCount_replacesToZero() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 0)
        )
        let expected = 0
        let r = writer.replaceStoredSiteIndex(to: 50)
        XCTAssertEqual(expected, r)
        defaults.assertSettingWasSet(expected: expected, setting: .SiteIndex)
    }

    func testIncrementStoredSiteIndex_whenRoomToIncrementAndNextIsFree_incrementsNormally() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 2)
        )
        defaults.mockObjectMap[PDSetting.SiteIndex.rawValue] = 1
        let expected = 2
        let res = writer.incrementStoredSiteIndex()
        XCTAssertEqual(expected, res)
        defaults.assertSettingWasSet(expected: expected, setting: .SiteIndex)
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
        defaults.assertSettingWasSet(expected: expected, setting: .SiteIndex)
    }

    func testIncrementStoredSiteIndex_whenSiteIndexGreaterThanCount_setsToFirstFreeHormoneIndex() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 2)
        )
        defaults.mockObjectMap[PDSetting.SiteIndex.rawValue] = 7
        let expected = 2
        let r = writer.incrementStoredSiteIndex()
        XCTAssertEqual(expected, r)
        defaults.assertSettingWasSet(expected: expected, setting: .SiteIndex)
    }

    func testIncrementSiteIndex_whenSiteCountZero_setsToFirstFreeHormoneIndex() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 0, freeHormoneIndex: 0)
        )
        defaults.mockObjectMap[PDSetting.SiteIndex.rawValue] = 7
        let expected = 0
        let r = writer.incrementStoredSiteIndex()
        XCTAssertEqual(expected, r)
        defaults.assertSettingWasSet(expected: expected, setting: .SiteIndex)
    }

    func testIncrementSiteIndex_whenSiteIndexAtLastIndex_setsToFreeHormoneIndex() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 5, freeHormoneIndex: 0)
        )
        defaults.mockObjectMap[PDSetting.SiteIndex.rawValue] = 5
        let expected = 0
        let r = writer.incrementStoredSiteIndex()
        XCTAssertEqual(expected, r)
        defaults.assertSettingWasSet(expected: expected, setting: .SiteIndex)
    }

    func testIncrementSiteIndex_whenSiteIndexNegative_setsToFirstFreeHormoneIndex() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 5, freeHormoneIndex: 0)
        )
        defaults.mockObjectMap[PDSetting.SiteIndex.rawValue] = -4
        let expected = 0
        let r = writer.incrementStoredSiteIndex()
        XCTAssertEqual(expected, r)
        defaults.assertSettingWasSet(expected: expected, setting: .SiteIndex)
    }

    func testIncrementSiteIndex_whenSiteIndexZeroAndNextIsFree_setsToOne() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 1)
        )
        defaults.mockObjectMap[PDSetting.SiteIndex.rawValue] = 0
        let expected = 1
        let r = writer.incrementStoredSiteIndex()
        XCTAssertEqual(expected, r)
        defaults.assertSettingWasSet(expected: expected, setting: .SiteIndex)
    }

    func testIncrementSiteIndex_whenGivenStartAndIndexAfterIsFree_usesGivenStart() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 3)
        )
        defaults.mockObjectMap[PDSetting.SiteIndex.rawValue] = 0
        let expected = 3
        let r = writer.incrementStoredSiteIndex(from: 2)
        XCTAssertEqual(expected, r)
        defaults.assertSettingWasSet(expected: expected, setting: .SiteIndex)
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
        defaults.assertSettingWasSet(expected: expected, setting: .SiteIndex)
    }

    func testIncrementSiteIndex_whenFromSiteIndexIsOccupied_returnsFirstIndexThatIsNotOccupied() {
        let writer = UserDefaultsWriter(
            handler: handler, siteStore: createMockSiteStore(count: 4, freeHormoneIndex: 3)
        )
        defaults.mockObjectMap[PDSetting.SiteIndex.rawValue] = 0
        let expected = 3
        let actual = writer.incrementStoredSiteIndex(from: 1)
        XCTAssertEqual(expected, actual)
        defaults.assertSettingWasSet(expected: expected, setting: .SiteIndex)
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
        defaults.assertSettingWasSet(expected: expected, setting: .SiteIndex)
    }
}
