//
//  PatchDayColors.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/26/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

class PatchDayColors {
    
    static var offWhite = UIColor(red: 1.0, green: 0.99, blue: 0.99, alpha: 1.0)
    static var lightBlue = UIColor(red: 0.86, green: 0.97, blue: 1.0, alpha: 0.25)
    static var cuteGray = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
    static var lighterCuteGray = UIColor(red: 0.98,green: 0.98, blue: 0.98, alpha: 1.0)
    static var pdPink = UIColor(red: 0.9923, green: 0.980036, blue: 1.0, alpha: 1.0)
    
    static var colorKeys = ["offWhite","lightBlue","cuteGray","lighterCuteGray"]
    
    static func getColor(from: String) -> UIColor {
        var color = UIColor()
        if from == colorKeys[0] {
            color = offWhite
        }
        else if from == colorKeys[1] {
            color = lightBlue
        }
        else if from == colorKeys[2] {
            color = cuteGray
        }
        else if from == colorKeys[3] {
            color = lighterCuteGray
        }
        return color
    }
    
}
