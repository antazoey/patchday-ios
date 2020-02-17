//
//  NewSiteAlertActionHandler.swift
//  PatchDay
//
//  Created by Juliya Smith on 2/17/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class NewSiteAlertActionHandler: NewSiteAlertActionHandling {
    
    private let newSiteAction: () -> ()
    
    init(_ handleNewSite: @escaping () -> ()) {
        self.newSiteAction = handleNewSite
    }
    
    func handleNewSite() {
        newSiteAction()
    }
}
