//
//  PDAlerting.swift
//  PDKit
//
//  Created by Juliya Smith on 6/16/19.
//  
//

import UIKit

public protocol PDAlerting {
    func present(actions: [UIAlertAction])
    func present()
}
