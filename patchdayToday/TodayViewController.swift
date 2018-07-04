//
//  TodayViewController.swift
//  patchdayToday
//
//  Created by Juliya Smith on 6/19/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import NotificationCenter
import PDKit

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var tbTodayLabel: UILabel!
    @IBOutlet weak var tbImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        PDTodayDataController.loadData()
        self.tbTodayLabel.text = PDTodayDataController.getTBTodayMessage()
        self.tbTodayLabel.textColor = UIColor.purple
 */
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
    }
    
}
