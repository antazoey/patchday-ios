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
    
    public enum Theme {
        case Light
        case Dark
    }
    
    public static func getTheme(from key: String) -> Theme {
        switch key {
        case PDStrings.PickerData.themes[1] :
            return .Dark
        default : // light
            return .Light
        }
    }
    
    public static func getCellColor(_ theme: Theme, index: Int) -> UIColor {
        if (index % 2 != 0) {
            return getEvenCellColor(theme)
        } else {
            return getOddCellColor(theme)
        }
    }
    
    public static func getOddCellColor(_ theme: Theme) -> UIColor {
        switch theme {
        case .Dark :
            return pdBlack
        default :
            return pdLightBlue
        }
    }
    
    public static func getEvenCellColor(_ theme: Theme) -> UIColor {
        switch theme {
        case .Dark :
            return UIColor.lightGray
        default :
            return UIColor.white
        }
    }
    
    public static func getBackgroundColor(_ theme: Theme) -> UIColor {
        switch theme {
        case .Dark :
            return pdBlack
        default:
            return UIColor.white
        }
    }
    
    public static func getBorderColor(_ theme: Theme) -> UIColor {
        switch theme {
        case .Dark:
            return UIColor.white
        default:
            return pdCuteGray
        }
    }
    
    /// Returns UIColor based on key from PDStrings.
    public static func getColor(_ key: PDStrings.ColorKey) -> UIColor {
        let colorDict: [PDStrings.ColorKey: UIColor] =  [ PDStrings.ColorKey.OffWhite : pdOffWhite,
                                                          PDStrings.ColorKey.LightBlue : pdLightBlue,
                                                          PDStrings.ColorKey.Gray : pdCuteGray,
                                                          PDStrings.ColorKey.LightGray : pdLighterCuteGray,
                                                          PDStrings.ColorKey.Green : pdGreen,
                                                          PDStrings.ColorKey.Pink : pdPink ]
        return colorDict[key]!
    }
    
    
    // MAR: - Raw colors
    
    private static let pdBlack = {
        return UIColor(red:0.23, green:0.23, blue:0.23, alpha:1.0)
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
    
    private static var pdOffWhite = {
        return UIColor(red: 1.0, green: 0.99, blue: 0.99, alpha: 1.0)
    }()
}
