//
//  SitesViewModel.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/13/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class SitesModel: NSObject {
    
    private let sites: HormoneSiteScheduling?
    private let defaults: UserDefaultsManaging?
    
    override var description: String {
        "The code behind for the sites module."
    }
    
    init(sites: HormoneSiteScheduling?, defaults: UserDefaultsManaging?) {
        self.sites = sites
        self.defaults = defaults
    }
    
    func getSitesTitle() -> String {
        if let method = defaults?.deliveryMethod.value {
            return VCTitleStrings.getSitesTitle(for: method)
        }
        return VCTitleStrings.siteTitle
    }
}
