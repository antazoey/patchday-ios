//
//  PDStateManaging.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public protocol PDStateManaging {
    func reset()
    func checkHormoneForStateChanges(at index: Index) -> Bool
    func markQuantityAsOld()

    /// Records the given site as having changed its image, useful for reflecting state in UIs.
    func markSiteAsHavingImageMutation(site: Bodily)
}
