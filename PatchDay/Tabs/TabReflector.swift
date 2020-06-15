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
		reflectHormones()
		reflectPills()
	}

	func reflectHormones() {
		guard let sdk = sdk else { return }
		guard let hormonesVC = hormonesVC else { return }
		let method = sdk.settings.deliveryMethod.value
		let icon = PDIcons[method]
		let expiredCount = sdk.hormones.totalExpired
		let title = PDTitleStrings.Hormones[method]
		let item = UITabBarItem(title: title, image: icon, selectedImage: icon)
		item.badgeValue = expiredCount > 0 ? "\(expiredCount)" : nil
		hormonesVC.title = title
		hormonesVC.tabBarItem = nil  // Set to nil first to force redraw
		hormonesVC.tabBarItem = item
		hormonesVC.awakeFromNib()
	}

	func reflectPills() {
		guard let pillsVC = pillsVC else { return }
		guard let sdk = sdk else { return }
		let currentItem = pillsVC.tabBarItem
		let item = UITabBarItem(
			title: currentItem?.title,
			image: currentItem?.image,
			selectedImage: currentItem?.selectedImage
		)
		let expiredCount = sdk.pills.totalDue
		item.badgeValue = expiredCount > 0 ? "\(expiredCount)" : nil
		let log = PDLog<TabReflector>()
		log.info("Settings pills tab to \(item.badgeValue ?? "nil")")
		pillsVC.tabBarItem = nil
		pillsVC.tabBarItem = item
		pillsVC.awakeFromNib()
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
