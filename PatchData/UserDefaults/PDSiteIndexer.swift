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
    
    let defaults: UserDefaultsWriting
    
    public init(defaults: UserDefaultsWriting) {
        self.defaults = defaults
    }

    func rebound(upon attempted: Index, lessThan bound: Index) -> Int {
        defaults.replaceStoredSiteIndex(to: attempted, siteCount: bound)
    }
}
