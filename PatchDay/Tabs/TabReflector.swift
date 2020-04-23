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
        loadViewControllerTabTexts()
    }
    
    var hormonesVC: UIViewController? { viewControllers.tryGet(at: 0) }
    var pillsVC: UIViewController? { viewControllers.tryGet(at: 1) }
    var sitesVC: UIViewController? { viewControllers.tryGet(at: 2) }

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
            viewControllers[i].tabBarItem.setTitleTextAttributes(fontKey, for: .normal)
        }
    }
}
