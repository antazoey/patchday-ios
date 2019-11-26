//
//  HormonesCodeBehind.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class HormonesCodeBehind: CodeBehindDependencies {
    
    public let HormoneMaxCount = 4

    var hormones: HormoneScheduling? {
        return sdk?.hormones
    }
    
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
        if let app = app, app.isFirstLaunch() {
            app.alerts.presentDisclaimerAlert()
            app.sdk.defaults.setMentionedDisclaimer(to: true)
        }
    }
    
    func loadAppTabs(source: UIViewController) {
        if let tabs = source.navigationController?.tabBarController,
            let vcs = source.navigationController?.viewControllers {
            app?.setTabs(tabBarController: tabs, appViewControllers: vcs)
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
}
