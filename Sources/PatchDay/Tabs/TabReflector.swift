//
//  TabReflector.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/5/19.

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
        loadViewControllerTabTextAttributes()
    }

    var hormonesViewController: UIViewController? { viewControllers.tryGet(at: 0) }
    var pillsViewController: UIViewController? { viewControllers.tryGet(at: 1) }
    var sitesViewController: UIViewController? { viewControllers.tryGet(at: 2) }

    func reflect() {
        reflectHormones()
        reflectPills()
    }

    func reflectHormones() {
        guard let sdk = sdk else { return }
        guard let hormonesViewController = hormonesViewController else { return }
        sdk.hormones.reloadContext()
        let method = sdk.settings.deliveryMethod.value
        let icon = PDIcons[method]
        let expiredCount = sdk.hormones.totalExpired
        let title = PDTitleStrings.Hormones[method]
        let item = UITabBarItem(title: title, image: icon, selectedImage: icon)
        item.badgeValue = expiredCount > 0 ? "\(expiredCount)" : nil
        hormonesViewController.title = title
        hormonesViewController.tabBarItem = nil  // Set to nil first to force redraw
        hormonesViewController.tabBarItem = item
        hormonesViewController.awakeFromNib()
    }

    func reflectPills() {
        guard let pillsViewController = pillsViewController else { return }
        guard let sdk = sdk else { return }
        guard let item = pillsViewController.tabBarItem else { return }
        sdk.pills.reloadContext()
        let expiredCount = sdk.pills.totalDue
        item.badgeValue = expiredCount > 0 ? "\(expiredCount)" : nil
        pillsViewController.tabBarItem = nil  // Set to nil first to force redraw
        pillsViewController.tabBarItem = item
        pillsViewController.awakeFromNib()
    }

    func clearPills() {
        guard let pillsViewController = pillsViewController else { return }
        pillsViewController.tabBarItem.badgeValue = nil
        pillsViewController.awakeFromNib()
    }

    private func loadViewControllerTabTextAttributes() {
        let size: CGFloat = AppDelegate.isPad ? 25 : 9
        for i in 0..<viewControllers.count {
            let font = UIFont.systemFont(ofSize: size)
            let fontKey = [NSAttributedString.Key.font: font]
            viewControllers[i].tabBarItem.setTitleTextAttributes(fontKey, for: .normal)
        }
    }
}
