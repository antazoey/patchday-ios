//
//  MockNav.swift
//  PDTest
//
//  Created by Juliya Smith on 5/10/20.

import Foundation
import PDKit

public class MockNav: NavigationHandling {

    public init() {}

    public var goToHormoneDetailsCallArgs: [(Index, UIViewController)] = []
    public func goToHormoneDetails(_ index: Index, source: UIViewController) {
        goToHormoneDetailsCallArgs.append((index, source))
    }

    public var goToPillDetailsCallArgs: [(Index, UIViewController)] = []
    public func goToPillDetails(_ index: Index, source: UIViewController) {
        goToPillDetailsCallArgs.append((index, source))
    }

    public var goToSiteDetailsCallArgs: [(Index, UIViewController, SiteImageDeterminationParameters)]
        = []

    public func goToSiteDetails(
        _ index: Index, source: UIViewController, params: SiteImageDeterminationParameters
    ) {
        goToSiteDetailsCallArgs.append((index, source, params))
    }

    public var goToSettingsCallArgs: [UIViewController] = []
    public func goToSettings(source: UIViewController) {
        goToSettingsCallArgs.append(source)
    }

    public var popCallArgs: [UIViewController] = []
    public func pop(source: UIViewController) {
        popCallArgs.append(source)
    }
}
