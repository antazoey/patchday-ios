//
//  PDScheduleProtocol.swift
//  PatchData
//
//  Created by Juliya Smith on 12/28/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData

@objc protocol PDScheduling: NSObjectProtocol {

    /// Return the number of Managed Objects in the schedule
    func count() -> Int

    /// Create + Insert a new Managed Object
    func insert(completion: (() -> ())?) -> NSManagedObject?

    /// Reset the schedule to a default
    func reset(completion: (() -> ())?)
    
    @objc optional func delete(at index: Index)
    
    /// To be called upon a default initialization of the schedule
    func new()
    
    @objc optional func sort()
    
    @objc optional func filterEmpty()
}
