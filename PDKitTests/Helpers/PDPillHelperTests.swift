//
//  PDPillHelperTests.swift
//  PDKitTests
//
//  Created by Juliya Smith on 12/23/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import XCTest
@testable import PDKit

class PDPillHelperTests: XCTestCase {
    var dates: [NSDate] = []
    var timesaday = 1
    var times_takes = 0
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testNextDueDate() {
        // Test one-a-day
        let d1 = NSDate()
        dates.append(d1)
        
    }
}
