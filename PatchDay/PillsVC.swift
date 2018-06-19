//
//  PillsVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 12/16/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit

class PillsVC: UIViewController {
    
    // UI elements
    @IBOutlet weak var pillStack: UIStackView!
    @IBOutlet weak var tbStack: UIStackView!
    @IBOutlet weak var tb_title: UILabel!
    @IBOutlet weak var tbFracLabel: UILabel!
    @IBOutlet weak var tb_subtitle: UILabel!
    @IBOutlet weak var tb_time: UIButton!

    @IBOutlet weak var lineUnderTB2: UIView!
    @IBOutlet weak var tbUndoButton: UIButton!
    @IBOutlet weak var pgStack: UIStackView!
    @IBOutlet weak var pg_title: UILabel!
    @IBOutlet weak var pgFracLabel: UILabel!
    @IBOutlet weak var pg_subtitle: UILabel!
    @IBOutlet weak var pg_time: UIButton!
    @IBOutlet weak var pgUndoButton: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateFromBackground()
        // set time buttons disabled properties
        self.tbUndoButton.setTitleColor(UIColor.blue, for: .normal)
        self.tb_time.setTitleColor(UIColor.lightGray, for: .disabled)
        self.tbUndoButton.setTitleColor(UIColor.lightGray, for: .disabled)
        self.pgUndoButton.setTitleColor(UIColor.blue, for: .normal)
        self.pg_time.setTitleColor(UIColor.lightGray, for: .disabled)
        self.pgUndoButton.setTitleColor(UIColor.lightGray, for: .disabled)
        self.tbFracLabel.textColor = self.tb_title.textColor
        self.pgFracLabel.textColor = self.pg_title.textColor
        self.tbFracLabel.text = PillDataController.getFrac(mode: "TB")
        self.pgFracLabel.text = PillDataController.getFrac(mode: "PG")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // *** Load pill views ***
        appearViews()
    }
    
    private func appearViews() {
        // including tb
        if PillDataController.includingTB() {
            appear(including: PillDataController.includingTB(), stamps: PillDataController.tb_stamps, timesaday: PillDataController.getTBDailyInt(), first_t: PillDataController.getTB1Time(), second_t: PillDataController.getTB2Time(), mode: 0)
        }
            // not-including tb
        else {
            self.tbStack.isHidden = true
        }
        // including pg
        if PillDataController.includingPG() {
            appear(including: PillDataController.includingPG(), stamps: PillDataController.pg_stamps, timesaday: PillDataController.getPGDailyInt(), first_t: PillDataController.getPG1Time(), second_t: PillDataController.getPG2Time(), mode: 1)
        }
            // not including pg
        else {
            self.pgStack.isHidden = true
        }
    }

    // MARK: - IBActions
    
    @IBAction func tb_tapped(_ sender: Any) {
        
        // Perform "take" action - timestamp persists in storage
        let stamp = Stamp()
        PillDataController.take(this: &PillDataController.tb_stamps, at: stamp, timesaday: PillDataController.getTBDailyInt(), key: PDStrings.SettingsKey.tbStamp.rawValue)
        
        // Button stuff
        self.tbUndoButton.isEnabled = true
        self.tb_time.setTitle(PillDataController.format(date: stamp), for: .normal)
        if (PillDataController.tbIsDone()) {
            self.disableTB(stamp: stamp)
        }
        let color = (PillDataController.tbIsDue()) ? UIColor.red : UIColor.blue
        self.tb_time.setTitleColor(color, for: .normal)
        self.makeUndoButton(button: self.tbUndoButton)
        
        self.tbFracLabel.text = PillDataController.getFrac(mode: "TB")
        appDelegate.notificationsController.requestNotifyTakePill(mode: 0)
    }
    
    
    @IBAction func tbUndoTapped(_ sender: Any) {
        PillDataController.resetLaterTB()
        self.tb_time.isEnabled = true
        self.tbFracLabel.text = PillDataController.getFrac(mode: "TB")
        
        // Color red if due
        if (PillDataController.tbIsDue()) {
            self.tb_time.setTitleColor(UIColor.red, for: .normal)
        }
        
        // Revert to the "old stamp" date if it exists
        if let oldstamp = PillDataController.getOlderStamp(stamps: PillDataController.tb_stamps) {
            self.tb_time.setTitle(PillDataController.format(date: oldstamp), for: .normal)
        }
        else {
            self.tb_time.setTitle(PDStrings.placeholderStrings.nothing_yet, for: .normal)
        }
        
        // Disable "undo" if no stamps
        if PillDataController.noRecords(stamps: PillDataController.tb_stamps) {
            self.tbUndoButton.isEnabled = false
        }
    }
    
    @IBAction func pg_tapped(_ sender: Any) {
        
        // Perform "take" action - timestamp persists in storage
        let stamp = Stamp()
        PillDataController.take(this: &PillDataController.pg_stamps, at: stamp, timesaday: PillDataController.getPGDailyInt(), key: PDStrings.SettingsKey.pgStamp.rawValue)
 
        // Button stuff
        self.pgUndoButton.isEnabled = true
        self.pg_time.setTitle(PillDataController.format(date: stamp), for: .normal)
        self.pgUndoButton.isEnabled = true
        if PillDataController.pgIsDone() {
            self.disablePG(stamp: stamp)
        }
        let color = PillDataController.pgIsDue() ? UIColor.red : UIColor.blue
        self.pg_time.setTitleColor(color, for: .normal)
        self.makeUndoButton(button: self.pgUndoButton)
        
        self.pgFracLabel.text = PillDataController.getFrac(mode: "PG")
        appDelegate.notificationsController.requestNotifyTakePill(mode: 1)
        
    }
    
    @IBAction func pgUndoTapped(_ sender: Any) {
        self.pg_time.isEnabled = true
        PillDataController.resetLaterPG()
        self.pgFracLabel.text = PillDataController.getFrac(mode: "PG")
        
        // Color red if due
        if (PillDataController.pgIsDue()) {
            self.pg_time.setTitleColor(UIColor.red, for: .normal)
        }
        
        // Revert to the "old stamp" date if it exists
        if let oldstamp = PillDataController.getOlderStamp(stamps: PillDataController.pg_stamps) {
            self.pg_time.setTitle(PillDataController.format(date: oldstamp), for: .normal)
        }
        else {
            self.pg_time.setTitle(PDStrings.placeholderStrings.nothing_yet, for: .normal)
        }
        
        // Disable "undo" if no stamps
        if PillDataController.noRecords(stamps: PillDataController.pg_stamps) {
            self.pgUndoButton.isEnabled = false
        }
    }
    
    // MARK: - Private / Helpers
    
    private func makeUndoButton(button: UIButton) {
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle(PDStrings.actionStrings.undo, for: .normal)
    }
    
    private func disableTB(stamp: Stamp) {
        self.tb_time.setTitle(PillDataController.format(date: stamp), for: .disabled)
        self.tb_time.isEnabled = false
    }
    
    private func disablePG(stamp: Stamp) {
        self.pg_time.setTitle(PillDataController.format(date: stamp), for: .disabled)
        self.pg_time.isEnabled = false
    }
    
    // appear(including, stamps, timesaday, first_t, second_t, mode) : This function appears all the details of pill related UI features for either TB or PG, depending on if mode = 0 for TB or 1 for PG.  This function will indicate whether the pill is due for taking or has been fully taken for the day.
    private func appear(including: Bool, stamps: Stamps, timesaday: Int, first_t: Time, second_t: Time, mode: Int) {
        let timeButtons = [self.tb_time, self.pg_time]
        let undos = [self.tbUndoButton, self.pgUndoButton]
        if including, let tb = timeButtons[mode], let undo = undos[mode] {
            let isDue = PillDataController.isDue(timesaday: timesaday, stamps: stamps, time1: first_t, time2: second_t)
            let color = isDue ? UIColor.red : UIColor.blue
            tb.setTitleColor(color, for: .normal)
            if let laterStamp: Stamp = PillDataController.getLaterStamp(stamps: stamps) {
                
                // Undo button
                let takenToday = PillDataController.takenToday(stamps: stamps)
                if takenToday {
                    self.makeUndoButton(button: undo)
                }
                else {
                    undo.isEnabled = false
                }
                
                // Title
                tb.setTitle(PillDataController.format(date: laterStamp), for: .normal)
                if let earlierStamp: Stamp = PillDataController.getOlderStamp(stamps: stamps), PillDataController.allStampedToday(stamps: stamps, timesaday: timesaday)  {
                    if mode == 0 {
                        self.disableTB(stamp: earlierStamp)
                        self.makeUndoButton(button: self.tbUndoButton)
                    }
                    else {
                        self.disablePG(stamp: earlierStamp)
                        self.makeUndoButton(button: self.pgUndoButton)
                    }
                }
                return
            }
            // Never taken
            else {
                tb.setTitle(PDStrings.placeholderStrings.nothing_yet, for: .normal)
                undo.isEnabled = false
                return
            }
        }
        
        // problem loading view.
        mode == 0 ? self.tb_time.setTitle(PDStrings.placeholderStrings.nothing_yet, for: .normal) : self.pg_time.setTitle(PDStrings.placeholderStrings.nothing_yet, for: .normal)
    }
    
    internal func updateFromBackground() {
        // this part is for updating the pill views when VC is reloaded from a notification
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc internal func appWillEnterForeground() {
        self.appearViews()
    }

}
