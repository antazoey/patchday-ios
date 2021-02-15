//
//  PillCellProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.

import Foundation

public protocol PillCellProtocol {
    @discardableResult func configure(_ params: PillCellConfigurationParameters) -> PillCellProtocol
    func loadBackground()
}
