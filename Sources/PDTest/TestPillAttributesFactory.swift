//
//  TestPillAttributesFactory.swift
//  PDTest
//
//  Created by Juliya Smith on 8/4/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class TestPillAttributesFactory {
    public static func createForXDaysOnXDaysOff(
        daysOne: Int?=nil, daysTwo: Int?=nil, isOn: Bool?=nil, daysPosition: Int?=nil
    ) -> PillAttributes {
        let attributes = PillAttributes()
        attributes.expirationInterval.value = .XDaysOnXDaysOff
        attributes.expirationInterval.daysOne = daysOne
        attributes.expirationInterval.daysTwo = daysTwo
        attributes.expirationInterval.xDaysIsOn = isOn
        attributes.expirationInterval.xDaysPosition = daysPosition
        return attributes
    }
}
