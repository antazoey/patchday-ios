//
// Created by Juliya Smith on 1/6/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockPatchData: PDCoreDataWrapping {

    private var mockEntities: [MockEntity] = []

    public var saveCalls: [String] = []
    public var deleteCalls: [String] = []

    public init() { }

    public func save(saverName: String) {
        saveCalls.append(saverName)
    }

    public func getManagedObjects(entity: PDEntity) -> [Any]? {
        mockEntities
    }

    public func insert(_ entity: PDEntity) -> Any? {
        mockEntities.append(MockEntity(type: entity))
    }

    public func nuke() {
        mockEntities = []
        saveCalls = []
        deleteCalls = []
    }

    public func tryDelete(_ managedObject: Any) {
        deleteCalls.append(String(describing: managedObject))
    }
}
