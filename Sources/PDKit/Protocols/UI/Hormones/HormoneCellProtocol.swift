//
//  HormoneCellProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public protocol HormoneCellProtocol {
    @discardableResult func configure(_ viewModel: HormoneCellViewModelProtocol) -> HormoneCellProtocol
    func reflectSiteImage(_ history: SiteImageRecording) throws
}
