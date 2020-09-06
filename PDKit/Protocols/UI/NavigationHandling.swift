//
//  NavigationDelegate.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/9/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit

public protocol NavigationHandling {
    func goToHormoneDetails(_ index: Index, source: UIViewController)
    func goToPillDetails(_ index: Index, source: UIViewController)
    func goToSiteDetails(_ index: Index, source: UIViewController, params: SiteImageDeterminationParameters)
    func goToSettings(source: UIViewController)
    func pop(source: UIViewController)
}
