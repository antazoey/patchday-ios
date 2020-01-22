//
//  Navigation.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/18/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


public class Navigation: NavigationHandling {
    
    private let log = PDLog<Navigation>()

    func reflectTheme(theme: AppTheme) {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = theme[.button]
        navigationBarAppearance.barTintColor = theme[.navBar]
        if let textColor = theme[.text] {
            navigationBarAppearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : textColor
            ]
        }
    }

    func goToHormoneDetails(_ hormone: Hormonal, source: UIViewController) {
        log.info("Going to Hormone Details View")
        source.navigationController?.goToHormoneDetails(hormone, source)
    }
    
    func goToPillDetails(_ pill: Swallowable, source: UIViewController) {
        log.info("Going to Pill Details View")
        source.navigationController?.goToPillDetails(pill, source)
    }

    func goToSiteDetails(_ site: Bodily, source: UIViewController, params: SiteImageDeterminationParameters) {
        log.info("Going to Site Details View")
        source.navigationController?.goToSiteDetails(site, source, params: params)
    }
    
    func goToSettings(source: UIViewController) {
        log.info("Going to Settings View")
        source.navigationController?.goToSettings()
    }

    func pop(source: UIViewController) {
        if let navCon = source.navigationController {
            navCon.popViewController(animated: true)
        }
    }
}
