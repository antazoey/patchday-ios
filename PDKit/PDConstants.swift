//
//  File.swift
//  PDKit
//
//  Created by Juliya Smith on 11/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public let OnlySupportedInjectionsQuantity = 1
public let SupportedHormoneUpperQuantityLimit = 4
public let DefaultExpirationIntervalHours = 84
public let DefaultDeliveryMethod = DeliveryMethod.Patches
public let DefaultTheme = PDTheme.Light


public class DefaultPillAttributes {
    
    public static let time = { Calendar.current.date(bySetting: .hour, value: 9, of: Date()) }()
    public static let timesaday = 1
    public static let timesTakenToday = 0
    public static let notify = true
}

