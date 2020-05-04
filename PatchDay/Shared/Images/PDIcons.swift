//
// Created by Juliya Smith on 12/14/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

public typealias UIIcon = UIImage

class PDIcons {

	private static var patchIcon: UIIcon { UIIcon(named: "Patch Icon")! }
	private static var injectionIcon: UIIcon { UIIcon(named: "Injection Icon")! }
	private static var pillIcon: UIIcon { UIIcon(named: "Pill Icon")! }
	private static var gelIcon: UIIcon { UIIcon(named: "Gel Icon")! }
	static var siteIndexIcon: UIIcon { UIIcon(named: "Site Index Icon")! }
	static var settingsIcon: UIIcon { UIIcon(named: "Settings Icon")! }

	static subscript(method: DeliveryMethod) -> UIIcon {
		switch method {
			case .Patches: return patchIcon
			case .Injections: return injectionIcon
			case .Pills: return pillIcon
			case .Gel: return gelIcon
		}
	}
}
