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

class PDTabViewDelegate: PDTabReflective {
    
    private let tabController: UITabBarController
    private let viewControllers: [UIViewController]
    private let defaults: PDDefaultManaging
    private let estrogenSchedule: EstrogenScheduling
    private let totalDueAnnoyance: TotalDueAnnoying
    
    convenience init(tabController: UITabBarController, viewControllers: [UIViewController]) {
        self.init(tabController: tabController,
                  viewControllers: viewControllers,
                  defaults: patchData.sdk.defaults,
                  estrogenSchedule: patchData.sdk.estrogenSchedule,
                  totalDueAnnoyance: patchData.sdk.schedule)
    }
    
    init(tabController: UITabBarController,
         viewControllers: [UIViewController],
         defaults: PDDefaultManaging,
         estrogenSchedule: EstrogenScheduling,
         totalDueAnnoyance: TotalDueAnnoying) {
        self.tabController = tabController
        self.viewControllers = viewControllers
        self.defaults = defaults
        self.estrogenSchedule = estrogenSchedule
        self.totalDueAnnoyance = totalDueAnnoyance
    }
    
    var estrogenTab: UIViewController {
        get { return viewControllers[0] }
    }
    
    var pillTab: UIViewController {
        get { return viewControllers[1] }
    }
    
    var siteTab: UIViewController {
        get { return viewControllers[2] }
    }
    
    func reflectExpirationCountAsBadgeValue() {
        if viewControllers.count > 0 {
            let interval = defaults.expirationInterval
            let c = estrogenSchedule.totalDue(interval)
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
        let interval = defaults.expirationInterval
        let deliv = defaults.deliveryMethod.value
        let c = totalDueAnnoyance.totalDue(interval: interval)

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
