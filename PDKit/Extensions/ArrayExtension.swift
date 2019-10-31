//
//  ArrayExtension.swift
//  PDKit
//
//  Created by Juliya Smith on 10/29/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public extension Array {

    func tryGet(at index: Index) -> Element? {
        if index < count && index >= 0 {
            return self[index]
        }
        return nil
    }
}
