//
//  PDPillSwallowHandling.swift
//  PDKit
//
//  Created by Juliya Smith on 10/7/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol SwallowPillNotificationActionHandling {
    
    /// A handler for client-side code to execute in PatchData when you swallow a pill.
    func handleSwallow(_ : Swallowable)
}
