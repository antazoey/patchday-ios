//
//  PDAlertPresenting.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public protocol AlertDispatching {
    func presentPillActions(for PillName: String, handlers: PillCellActionHandling)
    func presentDeliveryMethodMutationAlert(
        newMethod: DeliveryMethod, handlers: DeliveryMethodMutationAlertActionHandling
    )
    func presentQuantityMutationAlert(
        oldQuantity: Int, newQuantity: Int, handlers: QuantityMutationAlertActionHandling
    )
    func presentDisclaimerAlert()
    func presentNewSiteAlert(handlers: NewSiteAlertActionHandling)
    func presentGenericAlert()
}
