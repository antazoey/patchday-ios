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
    var hormonesVC: UIViewController? { get }
    var pillsVC: UIViewController? { get }
    var sitesVC: UIViewController? { get }
    func reflectTheme(theme: PDAppTheme)
    func reflectHormone()
    func reflectExpiredHormoneBadgeValue()
    func reflectDuePillBadgeValue()
}
