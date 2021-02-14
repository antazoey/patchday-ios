//
//  File.swift
//  PDKit
//
//  Created by Juliya Smith on 11/4/20.
//  
//

import Foundation

public protocol SiteImageRecording {
    var current: UIImage? { get }
    @discardableResult
    func push(_ image: UIImage?) -> SiteImageRecording
    func differentiate() -> HormoneMutation
}
