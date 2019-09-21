//
//  KeyStorableHelper.swift
//  PDKit
//
//  Created by Juliya Smith on 9/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public class PDKeyStorableHelper {
    
    public static func defaultQuantity(for deliveryMethod: DeliveryMethod) -> Int {
        switch deliveryMethod {
        case .Injections:
            return 1
        case .Patches:
            return 3
        }
    }
}
