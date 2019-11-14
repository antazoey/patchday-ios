//
//  PDNavigationDelegate.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/18/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

public class Navigation : NavigationDelegate {

    func reflectTheme(theme: AppTheme) {
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = theme[.button]
        navigationBarAppearace.barTintColor = theme[.navbar]
        if let textColor = theme[.text] {
            navigationBarAppearace.titleTextAttributes = [
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
}
