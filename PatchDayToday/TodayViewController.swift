//
//  TodayViewController.swift
//  PatchDayToday
//
//  Created by Juliya Smith on 6/19/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//
import UIKit
import NotificationCenter
import PDKit

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var nextEstrogenLabel: UILabel!
    @IBOutlet weak var estrogenSiteLabel: UILabel!
    @IBOutlet weak var estrogenDateLabel: UILabel!
    @IBOutlet weak var nextPillNameLabel: UILabel!
    @IBOutlet weak var nextPillTakeDateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewModel = TodayAppViewModel()
        estrogenSiteLabel.text = viewModel.hormoneSiteName
        nextEstrogenLabel.text = viewModel.hormoneTitle
        estrogenDateLabel.text = viewModel.hormoneDateText
        nextPillNameLabel.text = viewModel.nextPillName
        nextPillTakeDateLabel.text = viewModel.nextPillDateText
    }
    
    @IBAction func widgetTapped(_ sender: Any) {
        let myAppUrl = NSURL(string: "PatchDay://")!
        extensionContext?.open(myAppUrl as URL, completionHandler: {
            (success) in
            if (!success) {
                print("Failure to open PatchDayToday")
            }
        })
    }
}
