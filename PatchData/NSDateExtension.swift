//
//  NSDateExtension.swift
//  PatchData
//
//  Created by Juliya Smith on 9/2/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

extension NSDate {
    
    func ge(_ other: NSDate) -> Bool {
        let r = self.compare(other as Date)
        return r == .orderedDescending || r == .orderedSame
    }
}
