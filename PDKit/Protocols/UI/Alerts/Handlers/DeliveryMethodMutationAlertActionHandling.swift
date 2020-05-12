//
//  DeliveryMethodMutationAlertActionHandling.swift
//  PDKit
//
//  Created by Juliya Smith on 2/17/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

public protocol DeliveryMethodMutationAlertActionHandling {
	func handleDecline(originalMethod: DeliveryMethod, originalQuantity: Int)
}
