//
//  HormoneStoring.swift
//  PDKit
//
//  Created by Juliya Smith on 1/9/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation


public protocol HormoneStoring {
    
    /// Fetches all the hormones from storage.
    func getStoredHormones(_ scheduleProperties: HormoneScheduleProperties) -> [Hormonal]
    
    /// Creates a new stored hormone and returns it.
    func createNewHormone(_ scheduleProperties: HormoneScheduleProperties) -> Hormonal?
    
    /// Deletes the given hormone from storage.
    func delete(_ hormone: Hormonal)
    
    /// Pushes the given hormones to the managed context to stage changes for saving.
    func pushLocalChanges(_ hormones: [Hormonal], doSave: Bool)
}
