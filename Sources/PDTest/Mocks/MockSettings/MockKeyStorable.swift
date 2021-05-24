//
//  MockKeyStorable.swift
//  PDTest
//
//  Created by Juliya Smith on 5/23/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockKeyStorable: KeyStorable {
    public typealias Value = String
    public typealias RawValue = String
    public var rawValue: String
    public var setting: PDSetting = .DeliveryMethod

    public required init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public var value: String {
        rawValue
    }

    public var displayableString: String {
        "\(rawValue)"
    }
}
