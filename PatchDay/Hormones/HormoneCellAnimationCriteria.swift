//
//  HormoneCellAnimationCriteria.swift
//  PatchDay
//
//  Created by Juliya Smith on 3/21/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


struct HormoneCellAnimationTrackingProperties {
    let siteId: UUID?
    let index: Index
}

typealias HormoneAnimationTracker = [UUID: HormoneCellAnimationTrackingProperties]


class HormoneCellAnimationCriteria {
    var tracker: HormoneAnimationTracker = [:]
    
    init(sdk: PatchDataSDK) {
        var i = 0
        for hormone in sdk.hormones.all {
            if let _ = tracker[hormone.id] {
                continue
            }
            tracker[hormone.id] = HormoneCellAnimationTrackingProperties(siteId: hormone.siteId, index: i)
            i += 1
        }
    }
    
    func shouldAnimate(hormoneId: UUID, siteId: UUID?, index: Index) -> Bool {
        guard let props = tracker[hormoneId] else { return false }
        return props.siteId != siteId || props.index != index
    }
}
