//
//  Navigation.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/18/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


public class Navigation: NavigationDelegate {

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
        source.navigationController?.goToHormoneDetails(hormone, source)
    }
    
    func goToPillDetails(_ pill: Swallowable, source: UIViewController) {
        source.navigationController?.goToPillDetails(pill, source)
    }

    func goToSiteDetails(_ site: Bodily, source: UIViewController, params: SiteImageDeterminationParameters) {
        source.navigationController?.goToSiteDetails(site, source, params: params)
    }
    
    func goToSettings(source: UIViewController) {
        source.navigationController?.goToSettings(source)
    }

    func pop(source: UIViewController) {
        if let navCon = source.navigationController {
            navCon.popViewController(animated: true)
        }
    }
}

extension UINavigationController {
    
    func goToHormoneDetails(_ hormone: Hormonal, _ source: UIViewController) {
        if let vc = HormoneDetailVC.createHormoneDetailVC(source, hormone) {
            pushViewController(vc, animated: true)
        }
    }
    
    func goToPillDetails(_ pill: Swallowable, _ source: UIViewController) {
        if let vc = PillDetailVC.createPillDetailVC(source, pill) {
            pushViewController(vc, animated: true)
        }
    }

    func goToSiteDetails(_ site: Bodily, _ source: UIViewController, params: SiteImageDeterminationParameters) {
        if let vc = SiteDetailVC.createSiteDetailVC(source, site, params: params) {
            pushViewController(vc, animated: true)
        }
    }
    
    func goToSettings(_ source: UIViewController) {
        if let vc = SettingsVC.createSettingsVC(source),
            let n = navigationController {
            n.pushViewController(vc, animated: true)
        }
    }
}

extension UIStoryboard {
    
    static func createSettingsStoryboard() -> UIStoryboard {
        UIStoryboard(name: "SettingsAndSites", bundle: nil)
    }
}
