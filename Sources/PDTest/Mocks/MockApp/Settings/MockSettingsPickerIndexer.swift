//
//  MockSettingsPickerIndexer.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/16/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockSettingsPickerIndexer: SettingsPickerIndexing {
    public init() {}
    public var deliveryMethodStartIndex = 0
    public var quantityStartIndex = 0
    public var expirationIntervalStartIndex = 0
    public var xDaysStartIndex = 0
}
