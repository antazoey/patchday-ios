//
//  PDNavigationDelegate.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/18/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import UIKit

public class PDNavigationDelegate {
    
    func reflectTheme(theme: PDThemeManager) {
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = theme.buttonColor
        navigationBarAppearace.barTintColor = theme.navbarColor
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor : theme.textColor]
    }
}
