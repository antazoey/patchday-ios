//
//  KeyWindowFinder.swift
//  PatchDay
//
//  Created by Juliya Smith on 1/9/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class KeyWindowFinder {

    static let keyWindow: UIWindow? = {
        let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        guard let _ = window else {
            let log = PDLog<KeyWindowFinder>()
            log.error("Unable to find key window")
            return nil
        }
        return window
    }()
}
