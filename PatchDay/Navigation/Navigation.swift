//
//  Navigation.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/18/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

public class Navigation: NavigationHandling {

	private lazy var log = PDLog<Navigation>()

	public func goToHormoneDetails(_ hormone: Hormonal, source: UIViewController) {
		log.info("Going to Hormone Details View")
		source.navigationController?.goToHormoneDetails(hormone, source)
	}

	public func goToPillDetails(_ pill: Swallowable, source: UIViewController) {
		log.info("Going to Pill Details View")
		source.navigationController?.goToPillDetails(pill, source)
	}

	public func goToSiteDetails(_ site: Bodily, source: UIViewController, params: SiteImageDeterminationParameters) {
		log.info("Going to Site Details View")
		source.navigationController?.goToSiteDetails(site, source, params: params)
	}

	public func goToSettings(source: UIViewController) {
		log.info("Going to Settings View")
		source.navigationController?.goToSettings()
	}

	public func pop(source: UIViewController) {
		guard let navCon = source.navigationController else { return }
		navCon.popViewController(animated: true)
	}
}
