//
//  UserDefaultsWriteHandlerTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 5/23/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDTest

@testable
import PatchData

class UserDefaultsWriteHandlerTests: PDTestCase {

    private var mockUserDefaults: MockUserDefaults!
    private var mockDataSharer: MockUserDefaults!
    private var mockKeyStorable: MockKeyStorable!
    private let testValue = "this_is_a_setting_raw_value"

    override func setUp() {
        mockUserDefaults = MockUserDefaults()
        mockDataSharer = MockUserDefaults()
        mockKeyStorable = MockKeyStorable(testValue)
    }

    func testReplace_setsInUserDefaultsUsingSettingsKey() {
        let handler = createHandler()
        let newValue = "new_setting_raw_value"
        handler.replace(mockKeyStorable, to: newValue)
        let callArgs = mockUserDefaults.setCallArgs
        PDAssertSingle(callArgs)

        guard let actualValue = callArgs[0].0 as? String else {
            XCTFail("Value did not get set as a string")
            return
        }
        let actualKey = callArgs[0].1
        XCTAssertEqual(newValue, actualValue)
        XCTAssertEqual(mockKeyStorable.setting.rawValue, actualKey)
    }

    func testReplace_setsInSharedDataUsingSettingsKey() {
        let handler = createHandler()
        let newValue = "new_setting_raw_value"
        handler.replace(mockKeyStorable, to: newValue)
        let callArgs = mockDataSharer.setCallArgs

        guard let actualValue = callArgs[0].0 as? String else {
            XCTFail("Value did not get set as a string")
            return
        }
        let actualKey = callArgs[0].1
        XCTAssertEqual(newValue, actualValue)
        XCTAssertEqual(mockKeyStorable.setting.rawValue, actualKey)
    }

    func testLoad_usesDataSharerFirst() {
        let handler = createHandler()
        let testSetting = mockKeyStorable.setting
        mockUserDefaults.mockObjectMap[testSetting.rawValue] = "foo"
        mockDataSharer.mockObjectMap[testSetting.rawValue] = "bar"
        guard let actual: String = handler.load(mockKeyStorable.setting) else {
            XCTFail("Value was nil or not the correct type")
            return
        }
        let expected = "bar"
        XCTAssertEqual(expected, actual)
    }

    func testLoad_whenNilInSharedData_usesUserDefaultsData() {
        let handler = createHandler()
        let testSetting = mockKeyStorable.setting
        mockUserDefaults.mockObjectMap[testSetting.rawValue] = "foo"
        mockDataSharer.mockObjectMap[testSetting.rawValue] = nil
        guard let actual: String = handler.load(mockKeyStorable.setting) else {
            XCTFail("Value was nil or not the correct type")
            return
        }
        let expected = "foo"
        XCTAssertEqual(expected, actual)
    }

    // MARK: - iCloud sync (KVS) routing

    func testReplace_whenSyncEnabledAndKeyWhitelisted_writesToKVS() {
        let kvs = MockUbiquitousKVStore()
        let handler = createHandler(kvs: kvs, syncEnabled: true)
        let storable = MockKeyStorable(testValue)
        storable.setting = .DeliveryMethod
        handler.replace(storable, to: "Patches")
        XCTAssertEqual(1, kvs.setCalls.count)
        XCTAssertEqual(PDSetting.DeliveryMethod.rawValue, kvs.setCalls.first?.key)
    }

    func testReplace_whenSyncDisabled_doesNotWriteToKVS() {
        let kvs = MockUbiquitousKVStore()
        let handler = createHandler(kvs: kvs, syncEnabled: false)
        let storable = MockKeyStorable(testValue)
        storable.setting = .DeliveryMethod
        handler.replace(storable, to: "Patches")
        XCTAssertEqual(0, kvs.setCalls.count)
    }

    func testReplace_whenKeyNotWhitelisted_doesNotWriteToKVS() {
        let kvs = MockUbiquitousKVStore()
        let handler = createHandler(kvs: kvs, syncEnabled: true)
        let storable = MockKeyStorable(testValue)
        storable.setting = .MentionedDisclaimer
        handler.replace(storable, to: "true")
        XCTAssertEqual(0, kvs.setCalls.count)
    }

    func testLoad_whenSyncEnabledAndOnlyKVSHasValue_returnsKVSValue() {
        let kvs = MockUbiquitousKVStore()
        kvs.storage[PDSetting.DeliveryMethod.rawValue] = "Patches"
        let handler = createHandler(kvs: kvs, syncEnabled: true)
        let actual: String? = handler.load(.DeliveryMethod)
        XCTAssertEqual("Patches", actual)
    }

    func testLoad_whenSyncDisabled_doesNotFallBackToKVS() {
        let kvs = MockUbiquitousKVStore()
        kvs.storage[PDSetting.DeliveryMethod.rawValue] = "Patches"
        let handler = createHandler(kvs: kvs, syncEnabled: false)
        let actual: String? = handler.load(.DeliveryMethod)
        XCTAssertNil(actual)
    }

    func testIngestKVSChanges_mirrorsWhitelistedValuesIntoBaseAndDataSharer() {
        let kvs = MockUbiquitousKVStore()
        kvs.storage[PDSetting.Quantity.rawValue] = 4
        let handler = createHandler(kvs: kvs, syncEnabled: true)
        handler.ingestKVSChanges([
            PDSetting.Quantity.rawValue,
            PDSetting.MentionedDisclaimer.rawValue
        ])
        XCTAssertTrue(
            mockUserDefaults.setCallArgs.contains(where: { $0.1 == PDSetting.Quantity.rawValue })
        )
        XCTAssertTrue(
            mockDataSharer.setCallArgs.contains(where: { $0.1 == PDSetting.Quantity.rawValue })
        )
        // Non-whitelisted key was not mirrored.
        XCTAssertFalse(
            mockUserDefaults.setCallArgs.contains(
                where: { $0.1 == PDSetting.MentionedDisclaimer.rawValue }
            )
        )
    }

    // MARK: - Helpers

    private func createHandler() -> UserDefaultsWriteHandler {
        UserDefaultsWriteHandler(
            baseDefaults: mockUserDefaults, dataSharer: mockDataSharer
        )
    }

    private func createHandler(
        kvs: UbiquitousKeyValueStoring,
        syncEnabled: Bool
    ) -> UserDefaultsWriteHandler {
        UserDefaultsWriteHandler(
            baseDefaults: mockUserDefaults,
            dataSharer: mockDataSharer,
            kvs: kvs,
            isSyncEnabled: { syncEnabled }
        )
    }
}
