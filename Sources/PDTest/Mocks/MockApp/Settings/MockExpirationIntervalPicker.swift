//
//  MockExpirationIntervalPicker.swift
//  PDTest
//
//  Created by Juliya Smith on 5/5/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockExpirationIntervalPicker: MockSettingsPicker, ExpirationIntervalSettingsPicking {
    public var forIntervals: SettingsPicking = MockSettingsPicker()
    public var forXDays: SettingsPicking = MockSettingsPicker()
}
