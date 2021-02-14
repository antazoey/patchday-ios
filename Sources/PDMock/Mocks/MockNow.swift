//
//  MockNow.swift
//  PDMock
//
//  Created by Juliya Smith on 9/6/20.

import Foundation
import PDKit

public class MockNow: NowProtocol {

    public init() {}

    public var now = Date()

    public var isInYesterdayCallArgs: [Date] = []
    public var isInYesterdayReturnValue = false
    public func isInYesterday(_ date: Date) -> Bool {
        isInYesterdayCallArgs.append(date)
        return isInYesterdayReturnValue
    }
}
