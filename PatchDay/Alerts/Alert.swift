//
//  Alert.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/16/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit

public class Alert: Alerting {
    
    let controller: UIAlertController
    let parent: UIViewController
    let style: UIAlertController.Style
    
    init(parent: UIViewController, title: String, message: String, style: UIAlertController.Style) {
        self.controller = UIAlertController(title: title, message: message, preferredStyle: style)
        self.parent = parent
        self.style = style
    }
    
    public func present(actions: [UIAlertAction]) {
        for a in actions {
            controller.addAction(a)
        }
        parent.present(controller, animated: true, completion: nil) 
    }
    
    public func present() {
        parent.present(controller, animated: true, completion: nil) 
    }
}
