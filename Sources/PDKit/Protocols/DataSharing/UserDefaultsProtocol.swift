//
//  DataSharing.swift
//  PDKit
//
//  Created by Juliya Smith on 1/18/20.
//  
//

import Foundation

public protocol UserDefaultsProtocol {
    func set(_ value: Any?, for key: String)
    func object(for key: String) -> Any?
}
