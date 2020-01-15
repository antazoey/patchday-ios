//
// Created by Juliya Smith on 1/6/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation


public class SimpleUserDefault<T> {
    public required init(_ val: T) { value = val }
    public var value: T
    public var rawValue: T { value }
}
