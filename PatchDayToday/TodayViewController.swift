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

    private let placeholderText = {
        PDStrings.PlaceholderStrings.dotDotDot
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nextHormone = PDSharedDataController.getNextHormone()
        let nextPill = PDSharedDataController.getNextPill()
        let usingPatches = PDSharedDataController.usingPatches()
        loadHormoneTitleLabel(usingPatches: usingPatches)
        loadHormoneSiteLabel(nextHormone)
        loadHormoneDateLabel(nextHormone)
        loadPillNameLabel(nextPill)
        loadPillDateLabel(nextPill)
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

    private func loadHormoneTitleLabel(usingPatches: Bool) {
        let nextHormoneText = usingPatches ? "Change:" : "Inject:"
        nextEstrogenLabel.text = NSLocalizedString(nextHormoneText, comment: "Short label on Today App")
    }

    private func loadHormoneSiteLabel(_ hormone: HormoneStruct) {
        if let n = hormone.siteName {
            estrogenSiteLabel.text = n
        } else {
            estrogenSiteLabel.text = placeholderText
        }
    }

    private func loadHormoneDateLabel(_ hormone: HormoneStruct) {
        if let d = hormone.date {
            estrogenDateLabel.text = DateHelper.format(date: d, useWords: true)
        } else {
            estrogenDateLabel.text = placeholderText
        }
    }

    private func loadPillNameLabel(_ pill: PillStruct) {
        if let n = pill.name {
            nextPillNameLabel.text = n
        } else {
            nextPillNameLabel.text = placeholderText
        }
    }

    private func loadPillDateLabel(_ pill: PillStruct) {
        if let d = pill.nextTakeDate {
            nextPillTakeDateLabel.text = DateHelper.format(date: d, useWords: true)
        } else {
            nextPillTakeDateLabel.text = placeholderText
        }
    }
}
