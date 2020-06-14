//
//  AlertDispatcher.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/20/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class AlertDispatcher: NSObject, AlertDispatching {
	override var description: String { "Controls alerts." }

	private let sdk: PatchDataSDK?
	private let factory: AlertProducing
	private let tabs: TabReflective?
	private let log = PDLog<AlertDispatcher>()

	private lazy var style: UIAlertController.Style = {
		AppDelegate.isPad ? .alert : .actionSheet
	}()

	init(sdk: PatchDataSDK?, factory: AlertProducing, tabs: TabReflective? = nil) {
		self.sdk = sdk
		self.factory = factory
		self.tabs = tabs
	}

	/// Alert that occurs when the delivery method has changed because data could now be lost.
	func presentDeliveryMethodMutationAlert(
		newMethod: DeliveryMethod, handlers: DeliveryMethodMutationAlertActionHandling
	) {
		guard let sdk = sdk else { return }
		let originalMethod = sdk.settings.deliveryMethod.value
		let tabs = self.tabs ?? AppDelegate.current?.tabs
		DeliveryMethodMutationAlert(
			style: self.style,
			sdk: sdk,
			tabs: tabs,
			originalDeliveryMethod: originalMethod,
			originalQuantity: sdk.settings.quantity.rawValue,
			newDeliveryMethod: newMethod,
			handlers: handlers
		).present()
	}

	/// Alert for changing the count of hormones causing a loss of data.
	func presentQuantityMutationAlert(
		oldQuantity: Int, newQuantity: Int, handlers: QuantityMutationAlertActionHandling
	) {
		if newQuantity > oldQuantity {
			handlers.setQuantityWithoutAlert(newQuantity: newQuantity)
			return
		}
		QuantityMutationAlert(
			style: self.style,
			actionHandler: handlers,
			oldQuantity: oldQuantity,
			newQuantity: newQuantity
		).present()
	}

	func presentUnsavedAlert(
		_ parent: UIViewController,
		saveAndContinueHandler: @escaping () -> Void,
		discardHandler: @escaping () -> Void
	) {
		UnsavedChangesAlert(
			parent: parent,
			saveAndContinueHandler: saveAndContinueHandler,
			discardHandler: discardHandler
		).present()
	}

	func presentHormoneActions(
		at row: Index,
		reload: @escaping () -> Void,
		nav: @escaping () -> Void
	) {
		let nextSite = sdk?.sites.suggested
		let changeHormone = {
			guard let sdk = self.sdk else { return }
			guard let hormoneId = sdk.hormones[row]?.id else { return }
			sdk.hormones.setDate(by: hormoneId, with: Date())
			guard let site = nextSite else { return }
			sdk.hormones.setSite(by: hormoneId, with: site)
			reload()
		}
		let alert = self.factory.createHormoneActions(nextSite?.name, changeHormone, nav)
		alert.present()
	}

	private func getSuggestedSite() {
		
	}

	func presentPillActions(for pill: Swallowable, handlers: PillCellActionHandling) {
		PillCellActionAlert(pill: pill, handlers: handlers).present()
	}

	/// Alert that displays a quick tutorial and disclaimer on installation.
	func presentDisclaimerAlert() {
		DisclaimerAlert(style: style).present()
	}

	/// Alert that gives the user the option to add a new site they typed out in the UI.
	func presentNewSiteAlert(handlers: NewSiteAlertActionHandling) {
		NewSiteAlert(style: style, handlers: handlers).present()
	}

	func presentGenericAlert() {
		PDGenericAlert(style: style).present()
	}
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(
	_ input: [String: Any]
) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	Dictionary(uniqueKeysWithValues: input.map {
		key, value in
		(UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)
	})
}
