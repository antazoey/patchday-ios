//
//  NewSiteAlertActionHandler.swift
//  PatchDay
//
//  Created by Juliya Smith on 2/17/20.
//  
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
