//
//  PDAlertPresenting.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public protocol AlertDispatching {
    func presentPillActions()
    func presentDeliveryMethodMutationAlert(
        newMethod: DeliveryMethod, handler: DeliveryMethodMutationAlertActionHandling
    )
    func presentQuantityMutationAlert(
        oldQuantity: Int, newQuantity: Int, handler: QuantityMutationAlertActionHandling
    )
    func presentDisclaimerAlert()
    func presentNewSiteAlert(handler: NewSiteAlertActionHandling)
    func presentGenericAlert()
}
