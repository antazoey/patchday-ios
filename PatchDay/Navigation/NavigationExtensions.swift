//
// Created by Juliya Smith on 1/5/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

extension UINavigationController {

	func goToHormoneDetails(_ hormone: Hormonal, _ source: UIViewController) {
		if let vc = HormoneDetailViewController.create(source, hormone) {
			pushViewController(vc, animated: true)
		} else {
			errorOnViewControllerCreationFailure(name: "Hormone Details")
		}
	}

	func goToPillDetails(_ pill: Swallowable, _ source: UIViewController) {
		if let vc = PillDetailViewController.createPillDetailVC(source, pill) {
			pushViewController(vc, animated: true)
		} else {
			errorOnViewControllerCreationFailure(name: "Pill Details")
		}
	}

	func goToSiteDetails(_ site: Bodily, _ source: UIViewController, params: SiteImageDeterminationParameters) {
		if let vc = SiteDetailViewController.createSiteDetailVC(source, site, params: params) {
			pushViewController(vc, animated: true)
		} else {
			errorOnViewControllerCreationFailure(name: "Site Details")
		}
	}

	func goToSettings() {
		pushViewController(SettingsViewController.create(), animated: true)
	}

	private func errorOnViewControllerCreationFailure(name: String) {
		let log = PDLog<Navigation>()
		log.error("Could not create \(name) View Controller")
	}
}

extension UIStoryboard {

	static func createSettingsStoryboard() -> UIStoryboard {
		UIStoryboard(name: "SettingsAndSites", bundle: Bundle(for: Navigation.self))
	}
}
