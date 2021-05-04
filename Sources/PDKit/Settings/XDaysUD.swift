//
//  XDays.swift
//  PDKit
//
//  Created by Juliya Smith on 5/2/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public class XDays {

    private var xDaysValue: String?

    public var rawValue: String? {
        get { xDaysValue }
        set { xDaysValue = newValue }
    }

    public var ud: XDaysUD {
        XDaysUD(rawValue ?? DefaultSettings.XDaysRawValue)
    }

    public var value: Int? {
        get {
            guard let val = xDaysValue else { return nil }
            return Int(val)
        }
        set {
            if let val = newValue {
                xDaysValue = "\(val)"
            } else {
                xDaysValue = nil
            }
        }
    }
}
