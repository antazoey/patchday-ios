//
//  PillCellProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PillCellProtocol {
    @discardableResult func configure(_ params: PillCellConfigurationParameters) -> PillCellProtocol
    @discardableResult func stamp() -> PillCellProtocol
    func loadBackground()
}
