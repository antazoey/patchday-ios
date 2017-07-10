//
//  SuggestedPatchLocationTest.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/22/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import XCTest
@testable import PatchDay

class SuggestedPatchLocationTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        
        // order of general locations = [RS, LS, RB, LB]
        let testLocationArray = PatchDayStrings.patchLocationNames
        
        PatchDataController.resetPatchData()
        
        // I.) FOUR PATCHES
        SettingsController.setNumberOfPatches(with: 4)
        
        XCTAssert(SettingsController.getNumberOfPatchesInt() == PatchDataController.getNumberOfPatches() && PatchDataController.getNumberOfPatches() == 4)
        
            // a.) Existing custom locations
        
            // i.) 4 customs
            PatchDataController.setPatch(patchIndex: 0, patchDate: Date(), location: "Custom")
            PatchDataController.setPatch(patchIndex: 1, patchDate: Date(), location: "Custom")
            PatchDataController.setPatch(patchIndex: 2, patchDate: Date(), location: "Custom")
            PatchDataController.setPatch(patchIndex: 3, patchDate: Date(), location: "Custom")
        
        print(SuggestedPatchLocation.suggest(patchIndex: 0))
        
        
            XCTAssert(SuggestedPatchLocation.suggest(patchIndex: 0) == testLocationArray[0])
            XCTAssert(PatchDataController.patches.count == 4)
        
        
            // ii.) three customs
            PatchDataController.setPatchLocation(patchIndex: 1, with: testLocationArray[0])
        
            XCTAssert(SuggestedPatchLocation.suggest(patchIndex: 1) == testLocationArray[1])
            // cuz the Right Buttock is taken
            XCTAssert(SuggestedPatchLocation.suggest(patchIndex: 0) == testLocationArray[1])
        
            // sets the patch location to the suggested one, and the new suggested one should +1 an index down
            // in this case, changes locaiton from Right Buttock to Left Buttock, and suggested Location from Left Buttock to Right Stomach
            PatchDataController.setPatchLocation(patchIndex: 1, with: SuggestedPatchLocation.suggest(patchIndex: 1))
            XCTAssert(PatchDataController.getPatch(forIndex: 1)?.getLocation() == testLocationArray[1])
            XCTAssert(SuggestedPatchLocation.suggest(patchIndex: 1) == testLocationArray[2])
        
            PatchDataController.resetPatchData()
        
            // b.) No existing custom locations
        
                // i.) all 4 locations are different default locations
        
                // if all patch locations are different, then the suggested location should equal the current location
                PatchDataController.setPatch(patchIndex: 0, patchDate: Date(), location: testLocationArray[0])
                PatchDataController.setPatch(patchIndex: 1, patchDate: Date(), location: testLocationArray[1])
                PatchDataController.setPatch(patchIndex: 2, patchDate: Date(), location: testLocationArray[2])
                PatchDataController.setPatch(patchIndex: 3, patchDate: Date(), location: testLocationArray[3])
        
                XCTAssert(PatchDataController.getPatch(forIndex: 0)!.getLocation() == testLocationArray[0])
                XCTAssert(PatchDataController.getPatch(forIndex: 1)!.getLocation() == testLocationArray[1])
                XCTAssert(PatchDataController.getPatch(forIndex: 2)!.getLocation() == testLocationArray[2])
                XCTAssert(PatchDataController.getPatch(forIndex: 3)!.getLocation() == testLocationArray[3])
    
                XCTAssert(PatchDataController.makeArrayOfLocations() == testLocationArray)
                XCTAssert(SuggestedPatchLocation.suggest(patchIndex: 0) == PatchDataController.getPatch(forIndex: 0)!.getLocation())
                XCTAssert(SuggestedPatchLocation.suggest(patchIndex: 1) == PatchDataController.getPatch(forIndex: 1)!.getLocation())
                XCTAssert(SuggestedPatchLocation.suggest(patchIndex: 2) == PatchDataController.getPatch(forIndex: 2)!.getLocation())
                XCTAssert(SuggestedPatchLocation.suggest(patchIndex: 3) == PatchDataController.getPatch(forIndex: 3)!.getLocation())
                XCTAssert(PatchDataController.patches.count == 4)
        
                    // interlude - test modular index system
                    XCTAssert(SuggestedPatchLocation.getNextGeneralIndex(fromIndex: 0, totalNumberOfGeneralLocationOptions: testLocationArray.count) == 1)
                    XCTAssert(SuggestedPatchLocation.getNextGeneralIndex(fromIndex: testLocationArray.count-1, totalNumberOfGeneralLocationOptions: testLocationArray.count) == 0)
        
                // all the same location
        
                PatchDataController.setPatch(patchIndex: 0, patchDate: Date(), location: testLocationArray[0])
                PatchDataController.setPatch(patchIndex: 1, patchDate: Date(), location: testLocationArray[0])
                PatchDataController.setPatch(patchIndex: 2, patchDate: Date(), location: testLocationArray[0])
                PatchDataController.setPatch(patchIndex: 3, patchDate: Date(), location: testLocationArray[0])
        
                XCTAssert(PatchDataController.getPatch(forIndex: 0)!.getLocation() == testLocationArray[0])
                XCTAssert(PatchDataController.getPatch(forIndex: 1)!.getLocation() == testLocationArray[0])
                XCTAssert(PatchDataController.getPatch(forIndex: 2)!.getLocation() == testLocationArray[0])
                XCTAssert(PatchDataController.getPatch(forIndex: 3)!.getLocation() == testLocationArray[0])
        
                // three / four are the same location
        
                // cuz Left Buttock is next indexed after Right Buttock
                XCTAssert(SuggestedPatchLocation.suggest(patchIndex: 0) == testLocationArray[1])
                XCTAssert(SuggestedPatchLocation.suggest(patchIndex: 1) == testLocationArray[1])
        
                PatchDataController.setPatchLocation(patchIndex: 2, with: testLocationArray[2])
        
                // cuz Left Stomach is next next indexed after Right Stomach
                XCTAssert(SuggestedPatchLocation.suggest(patchIndex: 2) == testLocationArray[3])
        
                // two groups of two
                PatchDataController.setPatch(patchIndex: 0, patchDate: Date(), location: testLocationArray[3])
                PatchDataController.setPatch(patchIndex: 1, patchDate: Date(), location: testLocationArray[3])
                PatchDataController.setPatch(patchIndex: 2, patchDate: Date(), location: testLocationArray[1])
                PatchDataController.setPatch(patchIndex: 3, patchDate: Date(), location: testLocationArray[1])
        
                XCTAssert(SuggestedPatchLocation.suggest(patchIndex: 0) == testLocationArray[0])
                XCTAssert(SuggestedPatchLocation.suggest(patchIndex: 3) == testLocationArray[2])
        
                // cuz even tho Right Buttock is next, it's current already in the schedule, so Left Buttock is chosen
                PatchDataController.setPatch(patchIndex: 0, patchDate: Date(), location: testLocationArray[0])
                PatchDataController.setPatch(patchIndex: 1, patchDate: Date(), location: testLocationArray[0])
                PatchDataController.setPatch(patchIndex: 2, patchDate: Date(), location: testLocationArray[3])
                PatchDataController.setPatch(patchIndex: 3, patchDate: Date(), location: testLocationArray[3])
        if testLocationArray.count == 4 {
                XCTAssert(SuggestedPatchLocation.suggest(patchIndex: 2) == testLocationArray[1])
        }
        
                PatchDataController.setPatchLocation(patchIndex: 0, with: testLocationArray[1])
        
                // cuz tho Right Buttock is next, its taken, and so Left Buttock, so the last option then is Right Stomach
                XCTAssert(SuggestedPatchLocation.suggest(patchIndex: 3) == testLocationArray[2])

        
        PatchDataController.resetPatchData()
        
        // II.) THREE PATCHES
        SettingsController.setNumberOfPatches(with: 3)
        XCTAssert(SettingsController.getNumberOfPatchesInt() == PatchDataController.getNumberOfPatches() && PatchDataController.getNumberOfPatches() == 3 && SuggestedPatchLocation.getCurrentLocationsCount() == 3)
        
            // all spaced filled with general locations
            PatchDataController.setPatch(patchIndex: 0, patchDate: Date(), location: testLocationArray[1])
            PatchDataController.setPatch(patchIndex: 1, patchDate: Date(), location: testLocationArray[0])
            PatchDataController.setPatch(patchIndex: 2, patchDate: Date(), location: testLocationArray[2])
        
            XCTAssert(SuggestedPatchLocation.suggest(patchIndex: 0) == testLocationArray[3])
            XCTAssert(SuggestedPatchLocation.suggest(patchIndex: 1) == testLocationArray[3])
            XCTAssert(SuggestedPatchLocation.suggest(patchIndex: 2) == testLocationArray[3])
        
            // all custom
            PatchDataController.setPatch(patchIndex: 0, patchDate: Date(), location: "custom")
            PatchDataController.setPatch(patchIndex: 1, patchDate: Date(), location: "custom")
            PatchDataController.setPatch(patchIndex: 2, patchDate: Date(), location: "custom")
        
            // cuz Right Buttock is taken
            XCTAssert(SuggestedPatchLocation.suggest(patchIndex: 0) == testLocationArray[0])
            PatchDataController.setPatchLocation(patchIndex: 0, with: testLocationArray[0])
            XCTAssert(SuggestedPatchLocation.suggest(patchIndex: 1) == testLocationArray[1])
        
            // all same general location
            PatchDataController.setPatch(patchIndex: 0, patchDate: Date(), location: testLocationArray[0])
            PatchDataController.setPatch(patchIndex: 1, patchDate: Date(), location: testLocationArray[0])
            PatchDataController.setPatch(patchIndex: 2, patchDate: Date(), location: testLocationArray[0])
        
            // this is an example of the SuggestPatchLocation algthm spreading out a schedule of patches congested in one location
            PatchDataController.setPatchLocation(patchIndex: 0, with: SuggestedPatchLocation.suggest(patchIndex: 0))
            XCTAssert(PatchDataController.getPatch(forIndex: 0)!.getLocation() == testLocationArray[1])
            PatchDataController.setPatchLocation(patchIndex: 1, with: SuggestedPatchLocation.suggest(patchIndex: 1))
            XCTAssert(PatchDataController.getPatch(forIndex: 1)!.getLocation() == testLocationArray[2])
            PatchDataController.setPatchLocation(patchIndex: 2, with: SuggestedPatchLocation.suggest(patchIndex: 2))
            XCTAssert(PatchDataController.getPatch(forIndex: 2)?.getLocation() == testLocationArray[3])
        
        // III.) TWO PATCHES
        SettingsController.setNumberOfPatches(with: 2)
                XCTAssert(SettingsController.getNumberOfPatchesInt() == PatchDataController.getNumberOfPatches() && PatchDataController.getNumberOfPatches() == 2 && SuggestedPatchLocation.getCurrentLocationsCount() == 2)
        
        // I.) ONE PATCH
        SettingsController.setNumberOfPatches(with: 1)
        XCTAssert(SettingsController.getNumberOfPatchesInt() == PatchDataController.getNumberOfPatches() && PatchDataController.getNumberOfPatches() == 1 && SuggestedPatchLocation.getCurrentLocationsCount() == 1)
        
        PatchDataController.setPatch(patchIndex: 0, patchDate: Date(), location: testLocationArray[2])
        
        
        PatchDataController.setPatchLocation(patchIndex: 1, with: SuggestedPatchLocation.suggest(patchIndex: 1))
        
        
        PatchDataController.setPatchLocation(patchIndex: -1, with: SuggestedPatchLocation.suggest(patchIndex: -1))
        
        
        PatchDataController.setPatchLocation(patchIndex: 0, with: SuggestedPatchLocation.suggest(patchIndex: 0))
        XCTAssert(PatchDataController.getPatch(forIndex: 0)!.getLocation() == testLocationArray[3])
        PatchDataController.setPatchLocation(patchIndex: 0, with: SuggestedPatchLocation.suggest(patchIndex: 0))
        XCTAssert(PatchDataController.getPatch(forIndex: 0)!.getLocation() == testLocationArray[0])
        PatchDataController.setPatchLocation(patchIndex: 0, with: SuggestedPatchLocation.suggest(patchIndex: 0))
        XCTAssert(PatchDataController.getPatch(forIndex: 0)!.getLocation() == testLocationArray[1])
        PatchDataController.setPatchLocation(patchIndex: 0, with: SuggestedPatchLocation.suggest(patchIndex: 0))
 
        
    }
    
}
