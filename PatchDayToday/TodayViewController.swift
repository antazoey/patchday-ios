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

    @IBOutlet weak var nextHormoneLabel: UILabel!
    @IBOutlet weak var hormoneSiteLabel: UILabel!
    @IBOutlet weak var hormoneDateLabel: UILabel!
    @IBOutlet weak var nextPillNameLabel: UILabel!
    @IBOutlet weak var nextPillTakeDateLabel: UILabel!

    private lazy var log = PDLog<TodayViewController>()

    override func viewDidLoad() {
        super.viewDidLoad()
        let viewModel = TodayViewModel()
        hormoneSiteLabel.text = viewModel.hormoneSiteName
        nextHormoneLabel.text = viewModel.hormoneTitle
        hormoneDateLabel.text = viewModel.hormoneDateText
        nextPillNameLabel.text = viewModel.nextPillName
        nextPillTakeDateLabel.text = viewModel.nextPillDateText
    }

    @IBAction func widgetTapped(_ sender: Any) {
        let myAppUrl = NSURL(string: "PatchDay://")!
        extensionContext?.open(myAppUrl as URL, completionHandler: {
            (success) in
            if !success {
                self.log.warn("Failure to open PatchDay")
            }
        })
    }
}
