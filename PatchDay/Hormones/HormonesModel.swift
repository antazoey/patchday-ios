//
//  HormoneController.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class HormonesModel {
    
    let sdk: PatchDataDelegate?
    
    convenience init() {
        self.init(sdk: app?.sdk)
        sdk?.state.reset()
    }
    
    init(sdk: PatchDataDelegate?) {
        self.sdk = sdk
    }
    
    var hormones: HormoneScheduling? {
        return sdk?.hormones
    }

    func presentDisclaimerAlert() {
        if let app = app, app.isFirstLaunch() {
            app.alerts.presentDisclaimerAlert()
            app.sdk.defaults.replaceStoredMentionedDisclaimer(to: true)
        }
    }
}
