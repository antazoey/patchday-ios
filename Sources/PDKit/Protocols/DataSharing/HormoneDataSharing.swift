//
//  HormoneDataBroadcasting.swift
//  PatchData
//
//  Created by Juliya Smith on 11/10/19.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public protocol HormoneDataSharing {
    func share(nextHormone: Hormonal)
}
