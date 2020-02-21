//
// Created by Juliya Smith on 2/16/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class PillCellActionAlert: PDAlert {
    
    init(parent: UIViewController, handlers: PillCellActionHandling) {
        super.init(parent: parent, title: "Pill Actions", message: "", style: .actionSheet)
    }
    
    private var pillDetailsAction: UIAlertAction {
        UIAlertAction(title: "Edit Details", style: .default)
    }
    
    private var takeAction: UIAlertAction {
        UIAlertAction(title: "Take Pill", style: .default)
    }
    
    override func present() {
        self.present(actions: [pillDetailsAction, takeAction])
    }
}
