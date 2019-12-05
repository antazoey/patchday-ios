//
//  HormonesViewModel.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class HormonesViewModel: CodeBehindDependencies {
    
    public let HormoneMaxCount = 4

    private var isFirstLaunch: Bool {
        !(sdk?.defaults.mentionedDisclaimer.value ?? false)
    }

    var hormones: HormoneScheduling? { sdk?.hormones }
    
    var mainViewControllerTitle: String {
        if let method = sdk?.defaults.deliveryMethod.value {
            return VCTitleStrings.getTitle(for: method)
        }
        return VCTitleStrings.hormonesTitle
    }
    
    var expiredHormoneBadgeValue: String? {
        if let numExpired = hormones?.totalExpired, numExpired > 0 {
            return "\(numExpired)"
        }
        return nil
    }

    func presentDisclaimerAlert() {
        if isFirstLaunch {
            alerts?.presentDisclaimerAlert()
            sdk?.defaults.setMentionedDisclaimer(to: true)
        }
    }

    func goToHormoneDetails(hormoneIndex: Index, hormonesViewController: UIViewController) {
        if let hormone = hormones?.at(hormoneIndex) {
            nav?.goToHormoneDetails(hormone, source: hormonesViewController)
        }
    }
    
    func loadAppTabs(source: UIViewController) {
        if let tabs = source.navigationController?.tabBarController,
            let vcs = source.navigationController?.viewControllers {
            
            setTabs(tabBarController: tabs, appViewControllers: vcs)
        }
    }
    
    func watchHormonesForChanges(selector: Selector) {
        NotificationCenter.default.addObserver(
            self,
            selector: selector,
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    func reflectThemeInTabBar() {
        if let theme = styles?.theme {
            tabs?.reflectTheme(theme: theme)
        }
    }

    func getCellRowHeight(viewHeight: CGFloat) -> CGFloat {
        viewHeight * 0.24
    }

    private func setTabs(tabBarController: UITabBarController, appViewControllers: [UIViewController]) {
        app?.tabs = TabReflector(tabBarController: tabBarController, viewControllers: appViewControllers)
    }
}
