//
//  DisclaimerAlert.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/16/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class DisclaimerAlert: PDAlert {
    
    private var dismissAction: UIAlertAction {
        get {
            return UIAlertAction(title: PDActionStrings.dismiss,
                                 style: UIAlertAction.Style.cancel,
                                 handler: nil)
        }
    }
    
    private var goToUrlAction: UIAlertAction {
        get {
            return UIAlertAction(title: PDAlertStrings.disclaimerAlertStrings.supportPageActionTitle,
                                 style: .default) {
                void in
                if let url = URL(string: "http://www.patchdayhrt.com") {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
        }
    }
    
    public init(parent: UIViewController, style: UIAlertController.Style) {
        let strs = PDAlertStrings.disclaimerAlertStrings
        super.init(parent: parent, title: strs.title, message: strs.message, style: style)
    }
    
    override func present() {
        super.present(actions: [dismissAction, goToUrlAction])
    }
    
}
