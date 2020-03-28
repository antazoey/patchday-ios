//
//  SiteImageHistory.swift
//  PatchDay
//
//  Created by Juliya Smith on 3/28/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class SiteImageHistory {
    
    private var history: [UIImage?] = [nil, nil]
    
    init(_ image: UIImage?=nil) {
        self.push(image)
    }
    
    @discardableResult
    func push(_ image: UIImage?) -> SiteImageHistory {
        history[0] = history[1]
        history[1] = image
        return self
    }
    
    func checkForChanges() -> AnimationCheckResult {
        logState()
        var result: AnimationCheckResult = .NoAnimationNeeded
        if history[0] == nil && history[1] != nil {
            result = .AnimateFromAdd
        } else if history[0] != nil && history[1] == nil {
            result = .AnimateFromRemove
        } else if history[0] != history[1] {
            result = .AnimateFromEdit
        }
        return result
    }
    
    private func logState() {
        let log = PDLog<SiteImageHistory>()
        let last = history[0]?.accessibilityIdentifier ?? "nil"
        let latest = history[1]?.accessibilityIdentifier ?? "nil"
        log.info("HormoneCell site image history last: \(last), Latest: \(latest)")
    }
}
