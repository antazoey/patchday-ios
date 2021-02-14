//
//  CoreDataStore.swift
//  PatchData
//
//  Created by Juliya Smith on 12/24/19.
//  
//

import Foundation
import PDKit

public class EntityStore {

    let stack: PDCoreDataWrapping

    init(_ stack: PDCoreDataWrapping) {
        self.stack = stack
    }
}
