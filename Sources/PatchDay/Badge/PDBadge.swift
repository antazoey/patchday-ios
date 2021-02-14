//
//  PDBadge.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/9/19.
//  
//

import UIKit
import PDKit

public class PDBadge: PDBadgeReflective {

    private let sdk: PatchDataSDK?

    public init(sdk: PatchDataSDK?) {
        self.sdk = sdk
    }

    public func reflect() {
        let newValue = sdk?.totalAlerts ?? 0
        UIApplication.shared.applicationIconBadgeNumber = newValue
        PDLog<PDBadge>().info("Badge number set to \(newValue)")
    }

    public func clear() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    public var value: Int {
        UIApplication.shared.applicationIconBadgeNumber
    }
}
