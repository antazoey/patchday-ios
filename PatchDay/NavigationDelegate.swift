//
//  PDNavigationDelegate.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/9/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

protocol NavigationDelegate {
    func reflectTheme(theme: AppTheme)
    func goToHormoneDetails(_ mone: Hormonal, source: UIViewController)
    func goToPillDetails(_ pill: Swallowable, source: UIViewController)
}
