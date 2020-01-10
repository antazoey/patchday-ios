//
//  TabBarExtension.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/14/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit


extension UITabBar {
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        guard let window = KeyWindowFinder.keyWindw else {
            return super.sizeThatFits(size)
        }
        var sizeThatFits = super.sizeThatFits(size)
        let h: CGFloat = AppDelegate.isPad ? 100 : 44
        sizeThatFits.height = window.safeAreaInsets.bottom + h
        return sizeThatFits
    }
}
