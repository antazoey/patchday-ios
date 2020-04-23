//
//  DeliveryMethodMutationAlert.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/16/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class DeliveryMethodMutationAlert: PDAlert {

	private var sdk: PatchDataSDK?
	private let tabs: TabReflective?

	private let oldDeliveryMethod: DeliveryMethod
	private let newDeliveryMethod: DeliveryMethod
	private let handlers: DeliveryMethodMutationAlertActionHandling

	private lazy var continueAction: UIAlertAction = {
		UIAlertAction(title: ActionStrings.Continue, style: .destructive) {
			void in
			self.sdk?.settings.setDeliveryMethod(to: self.newDeliveryMethod)
			self.tabs?.reflectHormoneCharacteristics()
		}
	}()

	private lazy var declineAction: UIAlertAction = {
		UIAlertAction(title: ActionStrings.Decline, style: .cancel) {
			void in self.handlers.handleDecline(oldMethod: self.oldDeliveryMethod)
		}
	}()

	init(
		parent: UIViewController,
		style: UIAlertController.Style,
		sdk: PatchDataSDK?,
		tabs: TabReflective?,
		oldDeliveryMethod: DeliveryMethod,
		newDeliveryMethod: DeliveryMethod,
		handlers: DeliveryMethodMutationAlertActionHandling
	) {
		self.sdk = sdk
		self.tabs = tabs
		self.handlers = handlers
		let strings = AlertStrings.loseDataAlertStrings
		self.oldDeliveryMethod = oldDeliveryMethod
		self.newDeliveryMethod = newDeliveryMethod
		super.init(
			parent: parent, title: strings.title, message: strings.message, style: style
		)
	}

	override func present() {
		super.present(actions: [continueAction, declineAction])
	}
}
