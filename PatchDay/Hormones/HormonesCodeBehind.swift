//
//  HormonesCodeBehind.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class HormonesCodeBehind {
    
    let sdk: PatchDataDelegate?
    let tabs: TabReflective?
    let navigation: PDNab
    
    convenience init() {
        self.init(sdk: app?.sdk, tabs: app?.tabs)
        sdk?.stateManager.reset()
    }
    
    init(sdk: PatchDataDelegate?, tabs: TabReflective) {
        self.sdk = sdk
        self.tabs = tabs
    }
    
    var hormones: HormoneScheduling? {
        return sdk?.hormones
    }

    func presentDisclaimerAlert() {
        if let app = app, app.isFirstLaunch() {
            app.alerts.presentDisclaimerAlert()
            app.sdk.defaults.setMentionedDisclaimer(to: true)
        }
    }
}
