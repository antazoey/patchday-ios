//
//  PDTabViewDelegate.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/5/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import UIKit
import PDKit
import PatchData

class PDTabViewDelegate {
    
    private var viewControllers: [UIViewController]?
    
    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }
    
    var estrogenTab: UIViewController?  {
        get {
            if let vcs = viewControllers, vcs.count > 0 {
                return vcs[0]
            }
            return nil
        }
    }
    
    var pillTab: UIViewController?  {
        get {
            if let vcs = viewControllers, vcs.count > 1 {
                return vcs[1]
            }
            return nil
        }
    }
    
    var siteTab: UIViewController?  {
        get {
            if let vcs = viewControllers, vcs.count > 2 {
                return vcs[2]
            }
            return nil
        }
    }
    
    func reflectEstrogen(expirationInterval: ExpirationIntervalUD? = nil,
                         deliveryMethod: DeliveryMethod? = nil,
                         expiredCount: Int? = -1) {
        let interval = expirationInterval ?? patchData.defaults.expirationInterval
        let deliv = deliveryMethod ?? patchData.defaults.deliveryMethod.value
        let c = expiredCount ?? patchData.schedule.totalDue(interval: interval)

        if let estroTab = estrogenTab {
            estroTab.tabBarItem.badgeValue = c > 0 ? String(c) : nil
            estroTab.tabBarItem.title = PDPickerStringsDelegate.getTitle(for: deliv)
            switch deliv {
            case .Patches:
                estroTab.tabBarItem.image = #imageLiteral(resourceName: "Patch Icon")
                estroTab.tabBarItem.selectedImage = #imageLiteral(resourceName: "Patch Icon")
            case .Injections:
                estroTab.tabBarItem.image = #imageLiteral(resourceName: "Injection Icon")
                estroTab.tabBarItem.selectedImage = #imageLiteral(resourceName: "Injection Icon")
            }
            estroTab.awakeFromNib()
        }
    }
}
