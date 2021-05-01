//
//  PillTestsUtil.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 1/22/20.

import Foundation
import PDKit
import PDMock

@testable
import PatchData

class PillTestsUtil {

    private var mockStore: MockPillStore
    private var mockDataSharer: MockPillDataSharer

    static let testId = UUID()
    static let testHour = 12
    static let testMinute = 51
    static let testSeconds = 10
    static let testTimeString = "\(testHour):\(testMinute):\(testSeconds)"
    static let testTime = DateFactory.createTimesFromCommaSeparatedString(testTimeString)[0]

    init(_ mockStore: MockPillStore, _ mockDataSharer: MockPillDataSharer) {
        self.mockStore = mockStore
        self.mockDataSharer = mockDataSharer
    }

    static func createTimeString(hour: Int, minute: Int, second: Int) -> String {
        let hourString = hour <= 9 ? "0\(hour)" : String(hour)
        let minString = minute <= 9 ? "0\(minute)" : String(minute)
        let secString = second <= 9 ? "0\(second)" : String(second)
        return "\(hourString):\(minString):\(secString)"
    }

    func createThreePills() -> [MockPill] {
        [MockPill(), MockPill(), MockPill()]
    }

    func didSave(with pills: [MockPill]) -> Bool {
        if let lastCall = getMostRecentCallToPush() {
            for pill in pills {
                if !lastCall.0.contains(where: { (_ p: Swallowable) -> Bool in p.id == pill.id }) {
                    return false
                }
            }
            return lastCall.1
        }
        return false
    }

    func getMostRecentCallToPush() -> ([Swallowable], Bool)? {
        let args = mockStore.pushLocalChangesCallArgs
        if args.count == 0 {
            return nil
        }
        return args[args.count - 1]
    }

    func nextPillDueWasShared(_ pills: PillSchedule) -> Bool {
        let args = mockDataSharer.shareCallArgs
        if args.count <= 0 {
            return false
        }
        if pills.nextDue == nil {
            return false
        }
        return pills.nextDue!.id == args[0].id
    }
}
