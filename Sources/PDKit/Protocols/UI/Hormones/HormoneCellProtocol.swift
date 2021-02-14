//
//  HormoneCellProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.

import Foundation

public protocol HormoneCellProtocol {
    @discardableResult func configure(_ viewModel: HormoneCellViewModelProtocol) -> HormoneCellProtocol
    func reflectSiteImage(_ history: SiteImageRecording) throws
}
