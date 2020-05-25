//
//  TabReflector.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/5/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import UIKit
import PDKit

class TabReflector: TabReflective {

	private let tabBarController: UITabBarController
	private let viewControllers: [UIViewController]
	private let sdk: PatchDataSDK?

	init(
		tabBarController: UITabBarController,
		viewControllers: [UIViewController],
		sdk: PatchDataSDK?
	) {
		self.tabBarController = tabBarController
		self.viewControllers = viewControllers
		self.sdk = sdk
		loadViewControllerTabTextAttributes()
	}

	var hormonesVC: UIViewController? { viewControllers.tryGet(at: 0) }
	var pillsVC: UIViewController? { viewControllers.tryGet(at: 1) }
	var sitesVC: UIViewController? { viewControllers.tryGet(at: 2) }

	func reflect() {
		reflectHormoneCharacteristics()
		reflectDuePillBadgeValue()
	}

	func reflectHormoneCharacteristics() {
		guard let sdk = sdk else { return }
		guard let hormonesVC = hormonesVC else { return }
		let method = sdk.settings.deliveryMethod.value
		let icon = PDIcons[method]
		guard icon != hormonesVC.tabBarItem.image else { return }
		let expiredCount = sdk.hormones.totalExpired
		let title = PDTitleStrings.Hormones[method]
		let item = UITabBarItem(title: title, image: icon, selectedImage: icon)
		item.badgeValue = expiredCount > 0 ? "\(expiredCount)" : nil
		hormonesVC.title = title
		hormonesVC.tabBarItem = nil
		hormonesVC.tabBarItem = item
		hormonesVC.awakeFromNib()
	}

	func reflectDuePillBadgeValue() {
		if let totalDue = sdk?.pills.totalDue, let pillTab = pillsVC?.tabBarItem {
			pillTab.badgeValue = String(totalDue)
		}
	}

	private func loadViewControllerTabTextAttributes() {
		let size: CGFloat = AppDelegate.isPad ? 25 : 9
		for i in 0..<viewControllers.count {
			let font = UIFont.systemFont(ofSize: size)
			let fontKey = [NSAttributedString.Key.font: font]
			viewControllers[i].tabBarItem.setTitleTextAttributes(fontKey, for: .normal)
		}
	}
}
