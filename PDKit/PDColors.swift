//
//  PDColors.swift
//  PDKit
//
//  Created by Juliya Smith on 5/26/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

public class PDColors {
    
    public static var pdOffWhite = { return UIColor(red: 1.0, green: 0.99, blue: 0.99, alpha: 1.0) }()
    public static var pdLightBlue = { return UIColor(red: 0.86, green: 0.97, blue: 1.0, alpha: 0.25) }()
    public static var pdCuteGray = { return UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0) }()
    public static var pdLighterCuteGray = { return UIColor(red: 0.98,green: 0.98, blue: 0.98, alpha: 1.0) }()
    public static var pdPink = { return UIColor(red: 0.9923, green: 0.980036, blue: 1.0, alpha: 1.0) }()
    
    public static var pdDarkLines = { return UIColor(hue: 0.5194, saturation: 0, brightness: 0.54, alpha: 1.0) }()
    public static var pdLightLines = { return UIColor(red: 0.964251, green: 0.969299, blue: 0.969299, alpha: 1.0) }()
    public static var pdGreen = { return UIColor(hue: 0.3306, saturation: 1, brightness: 0.81, alpha: 1.0) }()
    
    public static func getColor(from: String) -> UIColor {
        let colorDict: [String: UIColor] = [PDStrings.ColorKeys.offWhite.rawValue: pdOffWhite, PDStrings.ColorKeys.lightBlue.rawValue: pdLightBlue, PDStrings.ColorKeys.gray.rawValue: pdCuteGray, PDStrings.ColorKeys.lightGray.rawValue: pdLighterCuteGray]
        return colorDict[from]!
    }
    
}
