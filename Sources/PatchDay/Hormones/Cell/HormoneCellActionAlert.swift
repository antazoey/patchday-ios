//
//  HormoneCellActionAlert.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/13/20.

import UIKit
import PDKit

class HormoneCellActionAlert: PDAlert {

    private let suggestedSite: SiteName?
    private let changeHormone: () -> Void
    private let nav: () -> Void

    private var changeHormoneTitle: String {
        let prefix = ActionStrings.Change
        var rest = ""
        if let name = suggestedSite {
            rest = "to \(name)"
        }
        return "\(prefix) \(rest)"
    }

    init(
        currentSite: SiteName,
        nextSite: SiteName?,
        changeHormone: @escaping () -> Void,
        nav: @escaping () -> Void
    ) {
        self.suggestedSite = nextSite
        self.changeHormone = changeHormone
        self.nav = nav
        super.init(title: currentSite, message: "", style: .actionSheet)
    }

    private var changeAction: UIAlertAction {
        let title = changeHormoneTitle
        return UIAlertAction(title: title, style: .default, handler: { _ in self.changeHormone() })
    }

    private var editAction: UIAlertAction {
        UIAlertAction(title: ActionStrings.Edit, style: .default, handler: { _ in self.nav() })
    }

    private var cancelAction: UIAlertAction {
        UIAlertAction(title: ActionStrings.Cancel, style: .cancel, handler: { _ in })
    }

    override func present() {
        let actions = [changeAction, editAction, cancelAction]
        super.present(actions: actions)
    }
}
