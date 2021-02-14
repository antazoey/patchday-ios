//
//  NewSiteAlertActionHandler.swift
//  PatchDay
//
//  Created by Juliya Smith on 2/17/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class NewSiteAlertActionHandler: NewSiteAlertActionHandling {

    private let newSiteAction: () -> Void

    init(_ handleNewSite: @escaping () -> Void) {
        self.newSiteAction = handleNewSite
    }

    func handleNewSite() {
        newSiteAction()
    }
}
