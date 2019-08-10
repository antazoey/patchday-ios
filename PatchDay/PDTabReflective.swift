//
//  PDTabReflective.swift
//  PatchDay
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

protocol PDTabReflective {
    var estrogenTab: UIViewController { get }
    var pillTab: UIViewController { get }
    var siteTab: UIViewController { get }
    func reflectExpirationCountAsBadgeValue()
    func reflectTheme(theme: PDThemeManager)
    func reflectEstrogen()
}
