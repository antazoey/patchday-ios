//
//  Navigation.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/18/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

/// Wrapper for navigationController to improve testability.
public class Navigation: NavigationDelegate {

    func reflectTheme(theme: AppTheme) {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = theme[.button]
        navigationBarAppearance.barTintColor = theme[.navbar]
        if let textColor = theme[.text] {
            navigationBarAppearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : textColor
            ]
        }
    }

    func goToHormoneDetails(_ mone: Hormonal, source: UIViewController) {
        source.navigationController?.goToHormoneDetails(source: source, hormone: mone)
    }
    
    func goToPillDetails(_ pill: Swallowable, source: UIViewController) {
        if let sdk = app?.sdk {
            source.navigationController?.goToPillDetails(source: source, sdk: sdk, pill: pill)
        }
    }
    
    func goToSettings(source: UIViewController) {
        source.navigationController?.goToSettings(source: source)
    }

    func pop(source: UIViewController) {
        if let navCon = source.navigationController {
            navCon.popViewController(animated: true)
        }
    }
}

extension UINavigationController {
    
    func goToHormoneDetails(source: UIViewController, hormone: Hormonal) {
        if let vc = HormoneDetailVC.createHormoneDetailVC(source: source, hormone: hormone) {
            pushViewController(vc, animated: true)
        }
    }
    
    func goToPillDetails(source: UIViewController, sdk: PatchDataDelegate, pill: Swallowable) {
        if let vc = PillDetailVC.createPillDetailVC(source: source, sdk: sdk, pill: pill) {
            pushViewController(vc, animated: true)
        }
    }
    
    func goToSettings(source: UIViewController) {
        if let vc = SettingsVC.createSettingsVC(source: source),
            let n = navigationController {
            n.pushViewController(vc, animated: true)
        }
    }
}

extension UIStoryboard {
    
    static func createSettingsStoryboard() -> UIStoryboard {
        UIStoryboard(name: "SettingsAndSites", bundle: nil)
    }

    static func createHormoneDetailStoryboard() -> UIStoryboard {

    }
}