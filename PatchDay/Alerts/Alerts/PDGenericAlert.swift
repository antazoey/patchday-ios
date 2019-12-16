//
//  PDGenericAlert.swift
//  PatchDay
//
//  Created by Juliya Smith on 8/6/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class PDGenericAlert: Alert {
    
    init(parent: UIViewController, style: UIAlertController.Style) {
        let strings = AlertStrings.genericAlertStrings
        super.init(parent: parent, title: strings.title, message: strings.message, style: style)
    }
    
    override func present() {
        super.present(actions: [UIAlertAction(
            title: ActionStrings.dismiss, style: UIAlertAction.Style.cancel, handler: nil)]
        )
    }
}
