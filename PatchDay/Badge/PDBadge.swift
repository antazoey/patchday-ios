//
//  PDBadge.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/9/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit

class PDBadge : PDBadgeDelegate {
    
    private var badgeNumber = UIApplication.shared.applicationIconBadgeNumber

    var hasValue: Bool {
        badgeNumber > 0
    }
    
    func increment() {
        badgeNumber += 1
    }
    
    func decrement() {
        badgeNumber -= 1
    }
    
    func set(to newBadgeValue: Int) {
        badgeNumber = newBadgeValue
    }
}
