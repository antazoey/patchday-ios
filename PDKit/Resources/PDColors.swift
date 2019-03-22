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
    
    public static func getCellColor(for theme: String, index: Int) -> UIColor {
        if (index % 2 != 0) {
            return getEvenCellColor(for: theme)
        } else {
            return getOddCellColor(for: theme)
        }
    }
    
    public static func getOddCellColor(for theme: String) -> UIColor {
        switch theme {
        case PDStrings.Themes.dark :
            return UIColor.black
        default :
            return pdLightBlue
        }
    }
    
    public static func getEvenCellColor(for theme: String) -> UIColor {
        switch theme {
        case PDStrings.Themes.dark :
            return UIColor.lightGray
        default :
            return UIColor.white
        }
    }
    
    public static let pdCuteGray = { return UIColor(red: 0.96,
                                                    green: 0.96,
                                                    blue: 0.96,
                                                    alpha: 1.0) }()
    
    public static let pdLighterCuteGray = { return UIColor(red: 0.98,
                                                           green: 0.98,
                                                           blue: 0.98,
                                                           alpha: 1.0) }()
    
    public static let pdDarkLines = { return UIColor(hue: 0.5194,
                                                     saturation: 0,
                                                     brightness: 0.54,
                                                     alpha: 1.0) }()
    public static let pdLightLines = { return UIColor(red: 0.964251,
                                                      green: 0.969299,
                                                      blue: 0.969299,
                                                      alpha: 1.0) }()
    public static let pdGreen = { return UIColor(hue: 0.3306,
                                                 saturation: 1,
                                                 brightness: 0.81,
                                                 alpha: 1.0) }()
    
    // MARK : - Private raw colors
    
    private static let pdLightBlue = { return UIColor(red: 0.86,
                                                     green: 0.97,
                                                     blue: 1.0,
                                                     alpha: 0.25) }()

    public static let pdPink = { return UIColor(red: 0.9923,
                                                green: 0.980036,
                                                blue: 1.0,
                                                alpha: 1.0) }()
    
    /// Returns UIColor based on key from PDStrings.
    public static func getColor(from key: String) -> UIColor {
        let colorDict: [String: UIColor] = [PDStrings.ColorKeys.lightBlue.rawValue: pdLightBlue,
                                            PDStrings.ColorKeys.gray.rawValue: pdCuteGray,
                                            PDStrings.ColorKeys.lightGray.rawValue: pdLighterCuteGray]
        return colorDict[key]!
    }
    
}
