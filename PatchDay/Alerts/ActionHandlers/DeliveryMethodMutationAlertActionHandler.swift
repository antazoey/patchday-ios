//
//  DeliveryMethodMutationAlertActionHandler.swift
//  PatchDay
//
//  Created by Juliya Smith on 2/17/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class DeliveryMethodMutationAlertActionHandler: DeliveryMethodMutationAlertActionHandling {

	private let declineAction: (_ originalMethod: DeliveryMethod) -> Void

	init(decline: @escaping (_ originalMethod: DeliveryMethod) -> Void) {
		self.declineAction = decline
	}

	func handleDecline(originalMethod: DeliveryMethod) {
		self.declineAction(originalMethod)
	}
}
