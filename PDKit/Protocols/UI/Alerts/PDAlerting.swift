//
//  PDAlerting.swift
//  PDKit
//
//  Created by Juliya Smith on 6/16/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit

public protocol PDAlerting {
    func present(actions: [UIAlertAction])
    func present()
}
