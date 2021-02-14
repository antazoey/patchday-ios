//
//  HormoneDataBroadcasting.swift
//  PatchData
//
//  Created by Juliya Smith on 11/10/19.

import Foundation

public protocol HormoneDataSharing {
    func share(nextHormone: Hormonal)
}
