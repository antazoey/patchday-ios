//
//  PDTabReflector.swift
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
    
    convenience init(
        tabBarController: UITabBarController,
        viewControllers: [UIViewController]
    ) {
        self.init(
            tabBarController: tabBarController, viewControllers: viewControllers, sdk: app?.sdk
        )
    }

    init(
        tabBarController: UITabBarController,
        viewControllers: [UIViewController],
        sdk: PatchDataDelegate?
    ) {
        self.tabBarController = tabBarController
        self.viewControllers = viewControllers
        self.sdk = sdk
    }
    
    var hormonesVC: UIViewController? { return viewControllers.tryGet(at: 0) }
    var pillsVC: UIViewController? { return viewControllers.tryGet(at: 1) }
    var sitesVC: UIViewController? { return viewControllers.tryGet(at: 2) }
    
    func reflectTheme(theme: AppTheme) {
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.tintColor = theme[.button]
        tabBarAppearance.barTintColor = theme[.navbar]
    }
    
    func reflectHormone() {
        if let sdk = sdk, let hormonesVC = hormonesVC {
            let total = sdk.totalAlerts
            let method = sdk.defaults.deliveryMethod.value
            let title = VCTitleStrings.getTitle(for: method)
            hormonesVC.tabBarItem.title = title
            hormonesVC.tabBarItem.badgeValue = total > 0 ? String(total) : nil
            let icon = PDImages.getDeliveryIcon(method)
            hormonesVC.tabBarItem.image = icon
            hormonesVC.tabBarItem.selectedImage = icon
            hormonesVC.awakeFromNib()
        }
    }
    
    func reflectExpiredHormoneBadgeValue() {
        if let hormoneTab = hormonesVC?.tabBarItem {
            let exp = sdk?.hormones.totalExpired ?? 0
            hormoneTab.badgeValue = exp > 0 ? "\(exp)" : nil
        }
    }
    
    func reflectDuePillBadgeValue() {
        if let totalDue = sdk?.pills.totalDue, let pillTab = pillsVC?.tabBarItem {
            pillTab.badgeValue = String(totalDue)
        }
    }
}
