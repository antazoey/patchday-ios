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
        UIAlertAction(title: ActionStrings.Dismiss, style: UIAlertAction.Style.cancel)
    }

    private var goToUrlAction: UIAlertAction {
        let supportTitle = AlertStrings.disclaimerAlertStrings.supportPageActionTitle
        return UIAlertAction(title: supportTitle, style: .default) {
            _ in
            if let url = URL(string: "http://www.patchdayhrt.com") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }

    public init(style: UIAlertController.Style) {
        let strings = AlertStrings.disclaimerAlertStrings
        super.init(title: strings.title, message: strings.message, style: style)
    }

    override func present() {
        super.present(actions: [dismissAction, goToUrlAction])
    }
}
