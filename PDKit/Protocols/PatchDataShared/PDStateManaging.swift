//
//  PDStateManaging.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public protocol PDStateManaging {
    func stampQuantity()
    func reset()
    func hormoneRecentlyMutated(at index: Index) -> Bool 
    func markSiteForImageMutation(site: Bodily)
}
