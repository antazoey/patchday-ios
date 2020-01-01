//
//  PatchDataCalling.swift
//  PDKit
//
//  Created by Juliya Smith on 9/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public protocol PDCoreDataDelegate: Saving {
    func getManagedObjects(entity: PDEntity) -> [Any]?
    func insert(_ entity: PDEntity) -> Any?
    func nuke()
    func tryDelete(_ managedObject: Any)
}
