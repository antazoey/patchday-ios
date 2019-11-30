//
// Created by Juliya Smith on 11/29/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class PillsCodeBehind: CodeBehindDependencies {

    var pills: PillScheduling? {
        sdk?.pills
    }

    func takePill(at index: Index) -> Swallowable? {
        if let pills = pills, let pill = pills.at(index) {
            pills.swallow(pill)
            return pill
        }
        tabs?.reflectDuePillBadgeValue()
    }
}
