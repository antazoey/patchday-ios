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

class PDTabReflector: PDTabReflective {
    
    private let tabController: UITabBarController
    private let viewControllers: [UIViewController]
    private let sdk: PatchDataDelegate
    
    convenience init(tabController: UITabBarController,
                     viewControllers: [UIViewController]) {
        self.init(tabController: tabController,
                  viewControllers: viewControllers,
                  sdk: app.sdk)
    }

    init(tabController: UITabBarController,
         viewControllers: [UIViewController],
         sdk: PatchDataDelegate) {
        self.tabController = tabController
        self.viewControllers = viewControllers
        self.sdk = sdk
    }
    
    var hormonalTab: UIViewController { return viewControllers[0] }
    
    var swallowableTab: UIViewController { return viewControllers[1] }
    
    var bodilyTab: UIViewController { return viewControllers[2] }
    
    func reflectExpirationCountAsBadgeValue() {
        if viewControllers.count > 0 {
            let exp = sdk.totalEstrogensExpired
            let item = hormonalTab.navigationController?.tabBarItem
            item?.badgeValue = (exp > 0) ? "\(exp)" : nil
        }
    }
    
    func reflectTheme(theme: PDAppTheme) {
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.tintColor = theme[.button]
        tabBarAppearance.barTintColor = theme[.navbar]
    }
    
    func reflectHormone() {
        let total = sdk.totalDue
        let method = sdk.deliveryMethod
        let title = PDViewControllerTitleStrings.getTitle(for: method)
        hormonalTab.tabBarItem.title = title
        hormonalTab.tabBarItem.badgeValue = total > 0 ? String(total) : nil
        let icon = PDImages.getDeliveryIcon(method)
        hormonalTab.tabBarItem.image = icon
        hormonalTab.tabBarItem.selectedImage = icon
        hormonalTab.awakeFromNib()
    }
}
