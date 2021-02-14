//
//  NewSiteAlert.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/16/19.
//  
//

import UIKit
import PDKit

class NewSiteAlert: PDAlert {

    private let handlers: NewSiteAlertActionHandling

    private var appendSiteAction: UIAlertAction {
        UIAlertAction(title: AlertStrings.newSiteAlertStrings.positiveActionTitle, style: .default) {
            _ in self.handlers.handleNewSite()
        }
    }

    private var declineAction: UIAlertAction {
        UIAlertAction(title: ActionStrings.Decline, style: .default)
    }

    init(style: UIAlertController.Style, handlers: NewSiteAlertActionHandling) {
        self.handlers = handlers
        let strings = AlertStrings.newSiteAlertStrings
        super.init(title: strings.title, message: "", style: style)
    }

    override func present() {
        super.present(actions: [appendSiteAction, declineAction])
    }
}
