//
//  HormoneDataBroadcasting.swift
//  PatchData
//
//  Created by Juliya Smith on 11/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public protocol HormoneDataBroadcasting {
    func broadcast(nextHormone: Hormonal?)
}
