//
//  DeliveryMethodMutationAlertActionHandling.swift
//  PDKit
//
//  Created by Juliya Smith on 2/17/20.

import Foundation

public protocol DeliveryMethodMutationAlertActionHandling {
    func handleDecline(originalMethod: DeliveryMethod, originalQuantity: Int)
}
