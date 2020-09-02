//
//  MockSDK.swift
//  PDMock
//
//  Created by Juliya Smith on 4/26/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockSDK: PatchDataSDK {

    public init() {
        self.settings = MockSettings()
        self.hormones = MockHormoneSchedule()
        self.sites = MockSiteSchedule()
        self.pills = MockPillSchedule()
    }

    public var isFresh: Bool = false
    public var settings: PDSettingsManaging
    public var hormones: HormoneScheduling
    public var sites: SiteScheduling
    public var pills: PillScheduling
    public var totalAlerts: Int = 0

	var resetAllCallCount = 0
	public func resetAll() {
		resetAllCallCount += 1
	}
}
