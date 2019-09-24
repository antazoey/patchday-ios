//
//  PDTabViewDelegate.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/5/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import UIKit
import PDKit

class PDTabViewDelegate: PDTabReflective {
    
    private let tabController: UITabBarController
    private let viewControllers: [UIViewController]
    private let sdk: PatchDataDelegate

    init(tabController: UITabBarController,
         viewControllers: [UIViewController],
         sdk: PatchDataDelegate) {
        self.tabController = tabController
        self.viewControllers = viewControllers
        self.sdk = sdk
    }
    
    var estrogenTab: UIViewController { return viewControllers[0] }
    
    var pillTab: UIViewController { return viewControllers[1] }
    
    var siteTab: UIViewController { return viewControllers[2] }
    
    func reflectExpirationCountAsBadgeValue() {
        if viewControllers.count > 0 {
            let interval = sdk.defaults.expirationInterval
            let c = sdk.estrogens.totalDue(interval)
            let item = estrogenTab.navigationController?.tabBarItem
            item?.badgeValue = (c > 0) ? "\(c)" : nil
        }
    }
    
    func reflectTheme(theme: PDThemeManager) {
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.tintColor = theme.buttonColor
        tabBarAppearance.barTintColor = theme.navbarColor
    }
    
    func reflectEstrogen() {
        let deliv = sdk.deliveryMethod
        let c = sdk.totalDue

        estrogenTab.tabBarItem.badgeValue = c > 0 ? String(c) : nil
        estrogenTab.tabBarItem.title = PDViewControllerTitleStrings.getTitle(for: deliv)
        switch deliv {
        case .Patches:
            estrogenTab.tabBarItem.image = UIImage(named: "Patch Icon")
            estrogenTab.tabBarItem.selectedImage = UIImage(named: "Patch Icon")
        case .Injections:
            estrogenTab.tabBarItem.image = UIImage(named: "Injection Icon")
            estrogenTab.tabBarItem.selectedImage = UIImage(named: "Injection Icon")
        }
        estrogenTab.awakeFromNib()
    }
}
