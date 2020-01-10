//
//  HormoneStoring.swift
//  PDKit
//
//  Created by Juliya Smith on 1/9/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation


public protocol HormoneStoring {
    
    /// Retrieve the stored hormones
    func getStoredHormones(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> [Hormonal]
    
    /// Create a new hormone to keep in storage and return it.
    func createNewHormone(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> Hormonal?
    
    /// Delete the given stored hormone from storage.
    func delete(_ hormone: Hormonal)
    
    /// Send the hormones to have their changes staged for saving and optionally write-through.
    func pushLocalChanges(_ hormones: [Hormonal], doSave: Bool)
}
