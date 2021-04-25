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

    var lastTakenMap: [Int: [Date?]] = [:]

    subscript(index: Index) -> [Date?]? {
        lastTakenMap[index] ?? nil
    }

    func put(at index: Index, lastTaken: Date?) {
        if var lastTakenList = lastTakenMap[index] {
            lastTakenList.append(lastTaken)
            lastTakenMap[index] = lastTakenList
        } else {
            lastTakenMap[index] = [lastTaken]
        }
    }

    func popLastTaken(index: Index) -> Date? {
        lastTakenMap[index]?.popLast() ?? nil
    }
}
