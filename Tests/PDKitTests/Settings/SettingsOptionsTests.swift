//
//  SettingsOptions.swift
//  PDKitTests
//
//  Created by Juliya Smith on 6/14/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

import XCTest
@testable
import PDKit

class SettingsOptionsTests: XCTestCase {
    func testGetExpirationInterval() {
        XCTAssertEqual(.OnceDaily, SettingsOptions.getExpirationInterval(for: "Once daily"))
        XCTAssertEqual(.TwiceWeekly, SettingsOptions.getExpirationInterval(for: "Twice weekly"))
        XCTAssertEqual(.OnceWeekly, SettingsOptions.getExpirationInterval(for: "Once weekly"))
        XCTAssertEqual(.EveryTwoWeeks, SettingsOptions.getExpirationInterval(
            for: "Once every two weeks")
        )
    }
}
