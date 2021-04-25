//
//  PillUndoState.swift
//  PDKit
//
//  Created by Juliya Smith on 4/25/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class PillUndoState {

    private var lastTakenMap: [Int: [Date?]] = [:]

    func popLastTaken(index: Index) -> Date? {
        return lastTakenMap[index]?.popLast() ?? nil
    }

    func set(at index: Index, lastTaken: Date?) {
        if var lastTakenList = lastTakenMap[index] {
            lastTakenList.append(lastTaken)
        } else {
            lastTakenMap[index] = [lastTaken]
        }
    }
}
