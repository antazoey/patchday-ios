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

enum AnimationCheckResult {
    case NoAnimationNeeded
    case AnimateFromEdit
    case AnimateFromAdd
    case AnimateFromRemove
}


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
    
    func shouldAnimate(hormone: Hormonal, siteId: UUID?, index: Index) -> AnimationCheckResult {
        guard let props = tracker[hormone.id] else {
            tracker[hormone.id] = HormoneCellAnimationTrackingProperties(siteId: siteId, index: index)
            return .AnimateFromAdd
        }
        return shouldAnimateFromEdit(props, siteId, index)
    }
    
    private func shouldAnimateFromEdit(
        _ props: HormoneCellAnimationTrackingProperties,
        _ siteId: UUID?,
        _ index: Index
    ) -> AnimationCheckResult {
        props.siteId != siteId || props.index != index ? .AnimateFromEdit : .NoAnimationNeeded
    }
}
