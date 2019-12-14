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
    private let sdk: PatchDataDelegate?
    
    convenience init(tabBarController: UITabBarController, viewControllers: [UIViewController]) {
        self.init(tabBarController: tabBarController, viewControllers: viewControllers, sdk: app?.sdk)
    }

    init(
        tabBarController: UITabBarController,
        viewControllers: [UIViewController],
        sdk: PatchDataDelegate?
    ) {
        self.tabBarController = tabBarController
        self.viewControllers = viewControllers
        self.sdk = sdk
        loadViewControllerTabTexts()
    }
    
    var hormonesVC: UIViewController? { viewControllers.tryGet(at: 0) }
    var pillsVC: UIViewController? { viewControllers.tryGet(at: 1) }
    var sitesVC: UIViewController? { viewControllers.tryGet(at: 2) }
    
    func reflectTheme(theme: AppTheme) {
        let tabBar = tabBarController.tabBar
        tabBar.unselectedItemTintColor = theme[.unselected]
        tabBar.tintColor = theme[.purple]
    }
    
    func reflectHormoneCharacteristics() {
        if let sdk = sdk, let hormonesVC = hormonesVC, let tabItem = hormonesVC.tabBarItem {
            tabItem.reflectHormonesCharacteristics(sdk: sdk)
            hormonesVC.awakeFromNib()
        }
    }
    
    func reflectDuePillBadgeValue() {
        if let totalDue = sdk?.pills.totalDue, let pillTab = pillsVC?.tabBarItem {
            pillTab.badgeValue = String(totalDue)
        }
    }

    private func loadViewControllerTabTexts() {
        let size: CGFloat = AppDelegate.isPad ? 25 : 9
        for i in 0..<viewControllers.count {
            let font = UIFont.systemFont(ofSize: size)
            let fontKey = [NSAttributedString.Key.font: font]
            viewControllers[i].tabBarItem.setTitleTextAttributes(fontKey)
        }
    }
}

extension UITabBarItem {

    func reflectHormonesCharacteristics(sdk: PatchDataDelegate) {
        let method = sdk.defaults.deliveryMethod.value
        reflectExpiredHormoneBadgeValue(sdk: sdk)
        reflectHormoneTabBarItemTitle(deliveryMethod: method)
        reflectHormoneTabBarItemIcon(deliveryMethod: method)
    }

    private func reflectExpiredHormoneBadgeValue(sdk: PatchDataDelegate?) {
        let expCount = sdk?.hormones.totalExpired ?? 0
        setHormoneTabBarItemBadge(expiredCount: expCount)
    }

    private func reflectHormoneTabBarItemTitle(deliveryMethod: DeliveryMethod) {
        title = VCTitleStrings.getTitle(for: deliveryMethod)
    }

    private func reflectHormoneTabBarItemIcon(deliveryMethod: DeliveryMethod) {
        let icon = PDImages.getDeliveryIcon(deliveryMethod)
        image = icon
        selectedImage = icon
    }

    private func setHormoneTabBarItemBadge(expiredCount: Int) {
        badgeValue = expiredCount > 0 ? "\(expiredCount)" : nil
    }
}
