//
//  HormoneDatePicker.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/14/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import UIKit

class HormoneDatePicker: UIDatePicker {

    var setDateSideEffect: () -> () = {}

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        setDateSideEffect()
    }
}
