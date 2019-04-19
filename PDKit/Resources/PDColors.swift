//
//  PDColors.swift
//  PDKit
//
//  Created by Juliya Smith on 5/26/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

public class PDColors: NSObject {
    
    override public var description: String {
        return "Read-only PatchDay Color class."
    }
    
    /// Returns UIColor based on key from PDStrings.
    public static func getColor(_ key: PDStrings.ColorKey) -> UIColor {
        let colorDict: [PDStrings.ColorKey: UIColor] =  [ PDStrings.ColorKey.OffWhite : pdOffWhite,
                                                          PDStrings.ColorKey.LightBlue : pdLightBlue,
                                                          PDStrings.ColorKey.Gray : pdCuteGray,
                                                          PDStrings.ColorKey.LightGray : pdLighterCuteGray,
                                                          PDStrings.ColorKey.Green : pdGreen,
                                                          PDStrings.ColorKey.Pink : pdPink,
                                                          PDStrings.ColorKey.Black : pdBlack,
                                                          PDStrings.ColorKey.Purple : pdPurple]
        return colorDict[key]!
    }
    
    
    // MAR: - Raw colors
    
    private static let pdBlack = {
        return UIColor(red:0.09, green:0.09, blue:0.10, alpha:1.0)
    }()
    
    private static let pdCuteGray = {
        return UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
    }()
    
    private static let pdLighterCuteGray = {
        return UIColor(red: 0.98,green: 0.98,blue: 0.98, alpha: 1.0)
    }()
    
    private static let pdLightLines = {
        return UIColor(red: 0.964251, green: 0.969299, blue: 0.969299, alpha: 1.0)
    }()
    
    private static let pdGreen = {
        return UIColor(hue: 0.3306, saturation: 1, brightness: 0.81, alpha: 1.0)
    }()
    
    private static let pdLightBlue = {
        return UIColor(red: 0.86, green: 0.97, blue: 1.0, alpha: 0.25)
    }()

    private static let pdPink = {
        return UIColor(red: 0.9923, green: 0.980036, blue: 1.0, alpha: 1.0)
    }()
    
    private static let pdPurple = {
        return UIColor(red: 0.579194, green: 0.128014, blue: 0.572686, alpha:1.0)
    }()
    
    private static let pdOffWhite = {
        return UIColor(red: 1.0, green: 0.99, blue: 0.99, alpha: 1.0)
    }()
}
