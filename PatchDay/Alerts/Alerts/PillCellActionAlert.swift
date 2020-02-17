//
// Created by Juliya Smith on 2/16/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import UIKit


class PillCellActionAlert: PDAlert {
    
    init(parent: UIViewController) {
        super.init(parent: parent, title: "Choose an option", message: "", style: .actionSheet)
    }
    
    private var pillDetailsAction: UIAlertAction {
        UIAlertAction(title: "View / Edit", style: .default)
    }
    
    private var takeAction: UIAlertAction {
        UIAlertAction(title: "Take pill", style: .default)
    }
    
    override func present() {
        self.present(actions: [pillDetailsAction, takeAction])
    }
}
