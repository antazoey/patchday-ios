//
// Created by Juliya Smith on 2/16/20.
// Copyright (c) 2021 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class PillCellActionAlert: PDAlert {

    private let pill: Swallowable
    private let handlers: PillCellActionHandling

    init(pill: Swallowable, handlers: PillCellActionHandling) {
        self.pill = pill
        self.handlers = handlers
        super.init(title: pill.name, message: "", style: .actionSheet)
    }

    private var cancelAction: UIAlertAction {
        UIAlertAction(title: ActionStrings.Cancel, style: .default)
    }

    private var pillDetailsAction: UIAlertAction {
        UIAlertAction(title: ActionStrings.Edit, style: .default) {
            _ in self.handlers.goToDetails()
        }
    }

    private var takeAction: UIAlertAction? {
        guard !pill.isDone else { return nil }
        return UIAlertAction(title: ActionStrings.Take, style: .default) {
            _ in self.handlers.takePill()
        }
    }

    private var undoTakeAction: UIAlertAction? {
        guard pill.timesTakenToday >= 1 else { return nil }
        guard pill.lastTaken != nil else { return nil }
        let title = NSLocalizedString("Undo Take", comment: "Notification button string")
        return UIAlertAction(title: title, style: .destructive) {
            _ in self.handlers.undoTakePill()
        }
    }

    override func present() {
        var actions = [pillDetailsAction, cancelAction]
        if let take = takeAction {
            actions.append(take)
        }
        if let undo = undoTakeAction {
            actions.append(undo)
        }
        super.present(actions: actions)
    }
}
