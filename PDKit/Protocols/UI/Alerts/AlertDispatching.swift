//
//  PDAlertPresenting.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol AlertDispatching {

	func presentDisclaimerAlert()
	func presentGenericAlert()
	func presentUnsavedAlert(
		_ parent: UIViewController,
		saveAndContinueHandler: @escaping () -> Void,
		discardHandler: @escaping () -> Void
	)
}
