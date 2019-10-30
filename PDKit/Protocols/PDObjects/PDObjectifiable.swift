//
//  Deletable.swift
//  PDKit
//
//  Created by Juliya Smith on 9/6/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PDPbjectifiable {
    
    /// Delete object from storage.
    func delete()
    
    /// Set all attributes to default values.
    func reset()
}
