//
//  MockDataSharer.swift
//  PDMock
//
//  Created by Juliya Smith on 1/16/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class MockDataSharer: DataSharing {
    
    public var defaults: UserDefaults?
    
    public func shareRelevantHormoneData(oldestHormone: Hormonal, displayedSiteName: SiteName, interval: ExpirationIntervalUD, deliveryMethod: DeliveryMethodUD) {
        <#code#>
    }
    
    public func shareRelevantPillData(nextPill: Swallowable) {
        <#code#>
    }
}
