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

    func reflectTheme(theme: PDAppTheme) {
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = theme[.button]
        navigationBarAppearace.barTintColor = theme[.navbar]
        if let textColor = theme[.text] {
            navigationBarAppearace.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : textColor
            ]
        }
    }
}
