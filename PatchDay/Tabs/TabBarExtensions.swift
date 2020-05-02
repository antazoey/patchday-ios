//
//  TabBarExtension.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/14/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

extension UITabBarItem {

	func reflectHormonesCharacteristics(sdk: PatchDataSDK) {
		let method = sdk.settings.deliveryMethod.value
		reflectExpiredHormoneBadgeValue(sdk: sdk)
		reflectHormoneTabBarItemTitle(deliveryMethod: method)
		reflectHormoneTabBarItemIcon(deliveryMethod: method)
	}

	private func reflectExpiredHormoneBadgeValue(sdk: PatchDataSDK?) {
		let expCount = sdk?.hormones.totalExpired ?? 0
		setHormoneTabBarItemBadge(expiredCount: expCount)
	}

	private func reflectHormoneTabBarItemTitle(deliveryMethod: DeliveryMethod) {
		title = ViewTitleStrings.getTitle(for: deliveryMethod)
	}

	private func reflectHormoneTabBarItemIcon(deliveryMethod: DeliveryMethod) {
		let icon = PDIcons[deliveryMethod]
		image = icon
		selectedImage = icon
	}

	private func setHormoneTabBarItemBadge(expiredCount: Int) {
		badgeValue = expiredCount > 0 ? "\(expiredCount)" : nil
	}
}
