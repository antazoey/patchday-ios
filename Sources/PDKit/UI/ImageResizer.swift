//
//  ModiiImageResizer.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/6/19.

import Foundation
import UIKit

// Original code by Kirit Modi
// https://iosdevcenters.blogspot.com/2015/12/how-to-resize-image-in-swift-in-ios.html
/// Resizes an image to the target size.

public class ImageResizer {

    public static func resize(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        let newSize: CGSize
        if widthRatio > heightRatio {
            let w = size.width * heightRatio
            let h = size.height * heightRatio
            newSize = CGSize(width: w, height: h)
        } else {
            let w = size.width * widthRatio
            let h = size.height * widthRatio
            newSize = CGSize(width: w, height: h)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? image
    }
}
