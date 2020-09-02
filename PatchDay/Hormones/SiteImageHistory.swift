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
    var row: Index

    init(_ row: Index, _ image: UIImage? = nil) {
        self.row = row
        self.push(image)
    }

    var current: UIImage? { history.tryGet(at: 1) ?? nil }

    @discardableResult
    func push(_ image: UIImage?) -> SiteImageHistory {
        history[0] = history.tryGet(at: 1) ?? nil
        history[1] = image
        return self
    }

    func differentiate() -> HormoneMutation {
        let penultimate = history.tryGet(at: 0) ?? nil
        let last = history.tryGet(at: 1) ?? nil
        if penultimate == nil && last == nil { return .Empty }
        if penultimate == nil && last != nil { return .Add }
        if penultimate != nil && last == nil { return .Remove }
        if penultimate != last { return .Edit }
        return .None
    }

    private func logState() {
        let log = PDLog<SiteImageHistory>()
        let last = history.tryGet(at: 0)??.accessibilityIdentifier ?? "nil"
        let latest = history.tryGet(at: 1)??.accessibilityIdentifier ?? "nil"
        log.info("HormoneCell site image history last: \(last), Latest: \(latest)")
    }
}
