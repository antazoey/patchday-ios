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
	var factory: AlertProducing
	private let tabs: TabReflective?
	private let log = PDLog<AlertDispatcher>()

	private lazy var style: UIAlertController.Style = {
		AppDelegate.isPad ? .alert : .actionSheet
	}()

	init(sdk: PatchDataSDK, tabs: TabReflective?, factory: AlertProducing? = nil) {
		self.sdk = sdk
		self.factory = factory ?? AlertFactory(sdk: sdk, tabs: tabs)
		self.tabs = tabs
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
		guard let hormone = sdk?.hormones[row] else { return }
		let nextSite = sdk?.sites.suggested
		let changeHormone = {
			guard let sdk = self.sdk else {
				reload()
				return
			}
			sdk.hormones.setDate(by: hormone.id, with: Date())
			if let site = nextSite {
				sdk.hormones.setSite(by: hormone.id, with: site)
			}
			reload()
		}
		let alert = self.factory.createHormoneActions(
			hormone.siteName, nextSite?.name, changeHormone, nav
		)
		alert.present()
	}

	func presentPillActions(for pill: Swallowable, handlers: PillCellActionHandling) {
		PillCellActionAlert(pill: pill, handlers: handlers).present()
	}

	func presentDisclaimerAlert() {
		DisclaimerAlert(style: style).present()
	}

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
