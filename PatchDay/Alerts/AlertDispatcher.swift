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
	private let tabs: TabReflective?
	private let log = PDLog<AlertDispatcher>()

	private lazy var style: UIAlertController.Style = {
		AppDelegate.isPad ? .alert : .actionSheet
	}()

	init(sdk: PatchDataSDK, tabs: TabReflective?, factory: AlertProducing? = nil) {
		self.sdk = sdk
		self.tabs = tabs
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

	func presentDisclaimerAlert() {
		DisclaimerAlert(style: style).present()
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
