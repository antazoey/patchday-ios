//
//  DeliveryMethodMutationAlertActionHandler.swift
//  PatchDay
//
//  Created by Juliya Smith on 2/17/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class DeliveryMethodMutationAlertActionHandler: DeliveryMethodMutationAlertActionHandling {

    private let declineAction: (_ originalMethod: DeliveryMethod, _ originalQuantity: Int) -> Void

    init(decline: @escaping (_ originalMethod: DeliveryMethod, _ originalQuantity: Int) -> Void) {
        self.declineAction = decline
    }

    func handleDecline(originalMethod: DeliveryMethod, originalQuantity: Int) {
        self.declineAction(originalMethod, originalQuantity)
    }
}
