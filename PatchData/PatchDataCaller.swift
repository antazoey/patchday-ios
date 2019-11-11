//
//  PDPatchDataSecretary.swift
//  PatchData
//
//  Created by Juliya Smith on 9/17/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class PatchDataCaller: PatchDataCalling {

    public func save() {
        PatchData.save()
    }
    
    public func createPill(named name: String) -> Swallowable? {
        if let mo = PatchData.insert(.pill) as? MOPill {
            return PDPill(pill: mo, name: name)
        }
        return nil
    }
    
    public func createPills() -> [Swallowable] {
        PatchData.createPills()
    }
}
