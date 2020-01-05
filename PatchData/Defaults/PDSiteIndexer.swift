//
//  SiteIndexRebouncePlayMaker.swift
//  PatchData
//
//  Created by Juliya Smith on 9/18/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class SiteIndexer: PDIndexRebounce  {
    
    let defaults: UserDefaultsStoring
    
    public init(defaults: UserDefaultsStoring) {
        self.defaults = defaults
    }

    func rebound(upon attempted: Index, lessThan bound: Index) -> Int {
        defaults.replaceStoredSiteIndex(to: attempted, siteCount: bound)
    }
}
