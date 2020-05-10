//
//  MockNav.swift
//  PDMock
//
//  Created by Juliya Smith on 5/10/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockNav: NavigationHandling {
	
	public init() {}
	
	public var goToHormoneDetailsCallArgs: [(Hormonal, UIViewController)] = []
	public func goToHormoneDetails(_ hormone: Hormonal, source: UIViewController) {
		goToHormoneDetailsCallArgs.append((hormone, source))
	}
	
	public var goToPillDetailsCallArgs: [(Swallowable, UIViewController)] = []
	public func goToPillDetails(_ pill: Swallowable, source: UIViewController) {
		goToPillDetailsCallArgs.append((pill, source))
	}
	
	public var goToSiteDetailsCallArgs: [(Bodily, UIViewController, SiteImageDeterminationParameters)] = []
	public func goToSiteDetails(_ site: Bodily, source: UIViewController, params: SiteImageDeterminationParameters) {
		goToSiteDetailsCallArgs.append((site, source, params))
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
