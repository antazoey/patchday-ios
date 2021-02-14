//
//  PDGenericAlert.swift
//  PatchDay
//
//  Created by Juliya Smith on 8/6/19.
//  
//

import UIKit
import PDKit

class PDGenericAlert: PDAlert {

    init(style: UIAlertController.Style) {
        let strings = AlertStrings.genericAlertStrings
        super.init(title: strings.title, message: strings.message, style: style)
    }

    override func present() {
        super.present(actions: [UIAlertAction(
            title: ActionStrings.Dismiss, style: UIAlertAction.Style.cancel, handler: nil)]
        )
    }
}
