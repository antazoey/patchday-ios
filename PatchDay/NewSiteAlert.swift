//
//  AlertForNewSite.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/16/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class NewSiteAlert: PDAlert {
    
    private var appendSiteAction: UIAlertAction {
        get {
            return UIAlertAction(title: PDAlertStrings.newSiteAlertStrings.positiveActionTitle, style: .default) {
                void in
                if let site = patchData.schedule.siteSchedule.insert() as? MOSite {
                    site.setName(name)
                    estroVC.sitePicker.reloadAllComponents()
                }
            }
        }
    }
    
    init(parent: UIViewController, style: UIAlertController.Style) {
        var strs = PDAlertStrings.newSiteAlertStrings
        super.init(parent: parent, title: strs.title, message: "", style: style)
    }
    
    override func present() {
        self.present(actions: [appendSiteAction])
    }
}
