//
// Created by Juliya Smith on 12/1/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation


class TimesadaySliderDefinition {

    static let Max: Float = 4.0
    static let Min: Float = 0.0
    static let GreaterThanOneMarker: Float = 2.0

    /// Converts a pill's timesaday value to a float for a slider in the UI
    //       *
    /// ---- | ------ | ----
    ///     1.0      3.0
    /// --------------------
    static func convertToSliderValue(timesaday: Int) -> Float {
        let timesadayFloat = Float(timesaday)
        return timesadayFloat == 1.0 ? timesadayFloat : timesadayFloat  + 2.0
    }

    static func valueIsGreaterThanOne(timesday: Float) -> Bool {
        timesday >= GreaterThanOneMarker
    }
}
