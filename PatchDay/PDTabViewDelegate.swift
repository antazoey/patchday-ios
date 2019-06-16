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
import PatchData

class PDTabViewDelegate {
    
    private var tabController: UITabBarController
    private var viewControllers: [UIViewController]
    
    init(tabController: UITabBarController, viewControllers: [UIViewController]) {
        self.tabController = tabController
        self.viewControllers = viewControllers
    }
    
    var estrogenTab: UIViewController  {
        get { return viewControllers[0] }
    }
    
    var pillTab: UIViewController  {
        get { return viewControllers[1] }
    }
    
    var siteTab: UIViewController?  {
        get { return viewControllers[2] }
    }
    
    func reflectExpirationCountAsBadgeValue() {
        if  viewControllers.count > 0 {
            let interval = patchData.defaults.expirationInterval
            let c = patchData.estrogenSchedule.totalDue(interval)
            let item = estrogenTab.navigationController?.tabBarItem
            item?.badgeValue = (c > 0) ? "\(c)" : nil
        }
    }
    
    func reflectTheme(theme: ThemeManager) {
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.tintColor = theme.button_c
        tabBarAppearance.barTintColor = theme.navbar_c
    }
    
    func reflectEstrogen(expirationInterval: ExpirationIntervalUD? = nil,
                         deliveryMethod: DeliveryMethod? = nil,
                         expiredCount: Int? = -1) {
        let interval = expirationInterval ?? patchData.defaults.expirationInterval
        let deliv = deliveryMethod ?? patchData.defaults.deliveryMethod.value
        let c = expiredCount ?? patchData.schedule.totalDue(interval: interval)

        estrogenTab.tabBarItem.badgeValue = c > 0 ? String(c) : nil
        estrogenTab.tabBarItem.title = PDViewControllerTitleStrings.getTitle(for: deliv)
        switch deliv {
        case .Patches:
            estrogenTab.tabBarItem.image = #imageLiteral(resourceName: "Patch Icon")
            estrogenTab.tabBarItem.selectedImage = #imageLiteral(resourceName: "Patch Icon")
        case .Injections:
            estrogenTab.tabBarItem.image = #imageLiteral(resourceName: "Injection Icon")
            estrogenTab.tabBarItem.selectedImage = #imageLiteral(resourceName: "Injection Icon")
        }
        estrogenTab.awakeFromNib()
    }
}
