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

class UserDefaultsWriteHandlerTests: XCTestCase {

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

    private func createHandler() -> UserDefaultsWriteHandler {
        UserDefaultsWriteHandler(
            baseDefaults: mockUserDefaults, dataSharer: mockDataSharer
        )
    }
}
