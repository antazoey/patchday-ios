//
//  PDEstrogenHelperTests.swift
//  PDKitTests
//
//  Created by Juliya Smith on 12/21/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import XCTest
@testable import PDKit

class PDEstrogenHelperTests: XCTestCase {
    var estrogens: [MOEstrogen] = []
    
    override func setUp() {
        super.setUp()
        for _ in 0..<4 {
            let estro = MOEstrogen()
            print("HERE")
            print(estro.getID())
            //estrogens.append(estro)
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGetEstrogen() {
        //let actual = PDEstrogenHelper.getEstrogen(for: estrogens[0].getID(), estrogenArray: estrogens)
        //XCTAssertEqual(actual, estrogens[0])
    }
}
