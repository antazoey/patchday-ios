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
    
    func reflectTheme(theme: ThemeManager) {
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = theme.button_c
        navigationBarAppearace.barTintColor = theme.navbar_c
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor : theme.text_c]
    }
}
