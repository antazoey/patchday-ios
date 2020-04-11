//
//  PDColors.swift
//  PDKit
//
//  Created by Juliya Smith on 5/26/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

public class PDColors: NSObject {
    
    override public var description: String {
        "Read-only PatchDay Color class."
    }

    public static func get(_ key: ColorKey) -> UIColor {
        let colorDict: [ColorKey: UIColor] =  [
            ColorKey.OffWhite: offWhite,
            ColorKey.LightBlue: lightBlue,
            ColorKey.Gray: gray,
            ColorKey.LightGray: lighterGray,
            ColorKey.Green: green,
            ColorKey.Pink: pink,
            ColorKey.Black: black,
            ColorKey.Purple: purple
        ]
        return colorDict[key]!
    }
    
    private static var black: UIColor {
        UIColor(red:0.09, green:0.09, blue:0.10, alpha:1.0)
    }
    
    private static var gray: UIColor {
        UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
    }
    
    private static var lighterGray: UIColor {
        UIColor(red: 0.98,green: 0.98,blue: 0.98, alpha: 1.0)
    }
    
    private static var green: UIColor {
        UIColor(hue: 0.3306, saturation: 1, brightness: 0.81, alpha: 1.0)
    }
    
    private static var lightBlue: UIColor {
        UIColor(red: 0.86, green: 0.97, blue: 1.0, alpha: 0.25)
    }

    private static var pink: UIColor {
        UIColor(red: 0.9923, green: 0.980036, blue: 1.0, alpha: 1.0)
    }
    
    private static var purple: UIColor {
        UIColor(red: 0.579194, green: 0.128014, blue: 0.572686, alpha:1.0)
    }
    
    private static var offWhite: UIColor {
        UIColor(red: 1.0, green: 0.99, blue: 0.99, alpha: 1.0)
    }
}
