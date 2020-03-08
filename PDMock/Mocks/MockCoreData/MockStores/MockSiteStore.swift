//
//  MockSiteStore.swift
//  PDMock
//
//  Created by Juliya Smith on 1/16/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class MockSiteStore: MockPatchDataStore<Bodily>, SiteStoring {
    
    public var getRelatedHormonesCallArgs: [UUID] = []
    public var getRelatedHormonesFactory: ((UUID) -> [HormoneStruct])?
    public var createNewSiteCallArgs: [Bool] = []

    public override init() {
        super.init()
        newObjectFactory = { () in MockSite() }
    }
    
    public var siteCount: Int = 0
    
    public override func resetMock() {
        super.resetMock()
        getRelatedHormonesCallArgs = []
        getRelatedHormonesFactory = nil
        createNewSiteCallArgs = []
    }

    public func getStoredSites() -> [Bodily] {
        getNextMockStoredObjects()
    }
    
    public func createNewSite(doSave: Bool) -> Bodily? {
        createNewSiteCallArgs.append(doSave)
        return newObjectFactory?()
    }
    
    public func getRelatedHormones(_ siteId: UUID) -> [HormoneStruct] {
        getRelatedHormonesFactory?(siteId) ?? []
    }
    
    public func delete(_ site: Bodily) {
        deleteCallArgs.append(site)
    }
    
    public func pushLocalChangesToManagedContext(_ sites: [Bodily], doSave: Bool) {
        pushLocalChangesCallArgs.append((sites, doSave))
    }
}
