//
//  SiteCellProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.

import Foundation

public protocol SiteCellProtocol {
    @discardableResult
    func configure(props: SiteCellProperties) -> SiteCellProtocol
    var backgroundColor: UIColor? { get set }
}
