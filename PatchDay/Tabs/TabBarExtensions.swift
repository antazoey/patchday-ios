//
//  TabBarExtension.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/14/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


extension UITabBar {
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        guard let window = KeyWindowFinder.keyWindw else {
            return super.sizeThatFits(size)
        }
        var sizeThatFits = super.sizeThatFits(size)
        let h: CGFloat = AppDelegate.isPad ? 100 : 44
        sizeThatFits.height = window.safeAreaInsets.bottom + h
        return sizeThatFits
    }
}

extension UITabBarItem {

    func reflectHormonesCharacteristics(sdk: PatchDataSDK) {
        let method = sdk.userDefaults.deliveryMethod.value
        reflectExpiredHormoneBadgeValue(sdk: sdk)
        reflectHormoneTabBarItemTitle(deliveryMethod: method)
        reflectHormoneTabBarItemIcon(deliveryMethod: method)
    }

    private func reflectExpiredHormoneBadgeValue(sdk: PatchDataSDK?) {
        let expCount = sdk?.hormones.totalExpired ?? 0
        setHormoneTabBarItemBadge(expiredCount: expCount)
    }

    private func reflectHormoneTabBarItemTitle(deliveryMethod: DeliveryMethod) {
        title = VCTitleStrings.getTitle(for: deliveryMethod)
    }

    private func reflectHormoneTabBarItemIcon(deliveryMethod: DeliveryMethod) {
        let icon = PDIcons.getDeliveryIcon(deliveryMethod)
        image = icon
        selectedImage = icon
    }

    private func setHormoneTabBarItemBadge(expiredCount: Int) {
        badgeValue = expiredCount > 0 ? "\(expiredCount)" : nil
    }
}
