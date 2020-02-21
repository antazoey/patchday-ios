//
// Created by Juliya Smith on 1/6/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation


public protocol BooleanKeyStorable: KeyStorable where Value == Bool, RawValue == Bool {}
public protocol IntKeyStorable: KeyStorable where Value == Int, RawValue == Int {}
public protocol StringKeyStorable: KeyStorable where Value == String, RawValue == String {}
