//
//  PDNotification.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/27/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PDNotifying {
    
    var title: String { get }
    
    var body: String? { get }
    
    func send()
}
