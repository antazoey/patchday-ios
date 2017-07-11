//
//  PatchData.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/11/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation

class PatchData {
    
    public var location = ""
    public var datePlaced: Date?
    
    static func < (lhs: PatchData, rhs: PatchData) -> Bool {
        if let l_date = lhs.datePlaced, let r_date = rhs.datePlaced {
            return l_date < r_date
        }
        else if lhs.datePlaced == nil {
            return false
        }
        else {
            return true
        }
    }
    
    static func > (lhs: PatchData, rhs: PatchData) -> Bool {
        if let l_date = lhs.datePlaced, let r_date = rhs.datePlaced {
            return l_date > r_date
        }
        else if lhs.datePlaced == nil {
            return true
        }
        else {
            return false
        }
    }
    
    static func == (lhs: PatchData, rhs: PatchData) -> Bool {
        if let l_date = lhs.datePlaced, let r_date = rhs.datePlaced {
            return l_date == r_date
        }
        return false
    }
    
    
}
