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
    
    func reflectTheme(theme: PDThemeManager) {
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.tintColor = theme.buttonColor
        tabBarAppearance.barTintColor = theme.navbarColor
    }
    
    func reflectHormone() {
        let deliv = sdk.deliveryMethod
        let c = sdk.totalDue

        hormonalTab.tabBarItem.badgeValue = c > 0 ? String(c) : nil
        hormonalTab.tabBarItem.title = PDViewControllerTitleStrings.getTitle(for: deliv)
        switch deliv {
        case .Patches:
            hormonalTab.tabBarItem.image = UIImage(named: "Patch Icon")
            hormonalTab.tabBarItem.selectedImage = UIImage(named: "Patch Icon")
        case .Injections:
            hormonalTab.tabBarItem.image = UIImage(named: "Injection Icon")
            hormonalTab.tabBarItem.selectedImage = UIImage(named: "Injection Icon")
        }
        hormonalTab.awakeFromNib()
    }
}
