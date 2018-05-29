//
//  PDColors.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/26/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit

class PDColors {
    
    static internal var offWhite = UIColor(red: 1.0, green: 0.99, blue: 0.99, alpha: 1.0)
    static internal var lightBlue = UIColor(red: 0.86, green: 0.97, blue: 1.0, alpha: 0.25)
    static internal var cuteGray = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
    static internal var lighterCuteGray = UIColor(red: 0.98,green: 0.98, blue: 0.98, alpha: 1.0)
    static internal var pdPink = UIColor(red: 0.9923, green: 0.980036, blue: 1.0, alpha: 1.0)
    
    static internal var darkLines = UIColor(hue: 0.5194, saturation: 0, brightness: 0.54, alpha: 1.0) 
    // for settings
    
    /*
    static internal var darkLines = UIColor(white: 0.682134, alpha: 1.0)
 */
    static internal var lightLines = UIColor(red: 0.964251, green: 0.969299, blue: 0.969299, alpha: 1.0)
    
    // pills
    static internal var pdGreen = UIColor(red: 0.10, green: 0.54, blue: 0.13, alpha: 1.0)
    
    static internal func getColor(from: String) -> UIColor {
        let colorDict: [String: UIColor] = [PDStrings.offWhite(): offWhite, PDStrings.lightBlue(): lightBlue, PDStrings.cuteGray(): cuteGray, PDStrings.lighterCuteGray(): lighterCuteGray]
        return colorDict[from]!
    }
    
}
