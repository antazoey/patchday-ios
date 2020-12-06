//
// Created by Juliya Smith on 2/16/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
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
        !pill.isDone ? UIAlertAction(title: ActionStrings.Take, style: .default) {
            _ in self.handlers.takePill()
        } : nil
    }

    override func present() {
        var actions = [pillDetailsAction, cancelAction]
        if let take = takeAction {
            actions.append(take)
        }
        super.present(actions: actions)
    }
}
