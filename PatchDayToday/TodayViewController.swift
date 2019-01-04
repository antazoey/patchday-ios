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
    
    @IBOutlet weak var nextEstrogenLabel: UILabel!
    @IBOutlet weak var estrogenSiteLabel: UILabel!
    @IBOutlet weak var estrogenDateLabel: UILabel!
    @IBOutlet weak var nextPillNameLabel: UILabel!
    @IBOutlet weak var nextPillTakeDateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nextEstro = PDSharedDataController.getNextEstrogen()
        let nextPill = PDSharedDataController.getNextPill()
        let usingPatches = PDSharedDataController.usingPatches()
        let comment = "Short label on Today App"
        let title = (usingPatches) ? "Change:" : "Inject:"
        let dots = PDStrings.PlaceholderStrings.dotdotdot
        nextEstrogenLabel.text = NSLocalizedString(title, comment: comment)
        
        if let n = nextEstro.siteName {
            estrogenSiteLabel.text = n
        } else {
            estrogenSiteLabel.text = dots
        }
        if let d = nextEstro.date {
            estrogenDateLabel.text = PDDateHelper.format(date: d,
                                                         useWords: true)
        } else {
            estrogenDateLabel.text = dots
        }
        if let n = nextPill.name {
            nextPillNameLabel.text = n
        } else {
            nextPillNameLabel.text = dots
        }
        if let d = nextPill.nextTakeDate {
            nextPillTakeDateLabel.text = PDDateHelper.format(date: d,
                                                             useWords: true)
        } else {
            nextPillTakeDateLabel.text = dots
        }
    }
    
    @IBAction func widgetTapped(_ sender: Any) {
        let myAppUrl = NSURL(string: "PatchDay://")!
        extensionContext?.open(myAppUrl as URL, completionHandler: {
            (success) in
            if (!success) {
                print("Failure to open PatchDay")
            }
        })
    }
}
