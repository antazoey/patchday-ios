//
//  ChangeQuantityAlertHandler.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/17/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class QuantityMutationAlertHandler: QuantityMutationAlertActionHandling {

	private let continueAction: (_ newQuantity: Int) -> Void
	private let cancelAction: (_ oldQuantity: Int) -> Void
	private let setQuantity: (_ newQuantity: Int) -> Void

	init(
		cont: @escaping (_ newQuantity: Int) -> Void,
		cancel: @escaping (_ oldQuantity: Int) -> Void,
		setQuantity: @escaping (_ newQuantity: Int) -> Void
	) {
		self.continueAction = cont
		self.cancelAction = cancel
		self.setQuantity = setQuantity
	}

	func handleContinue(newQuantity: Int) {
		continueAction(newQuantity)
	}

	func handleCancel(oldQuantity: Int) {
		cancelAction(oldQuantity)
	}

	func handleSetQuantityWithoutAlert(newQuantity: Int) {
		setQuantity(newQuantity)
	}
}
