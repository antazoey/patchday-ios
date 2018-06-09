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
    @IBOutlet weak var tb_subtitle: UILabel!
    @IBOutlet weak var tb_time: UIButton!
    @IBOutlet weak var tb_button: UIButton!
    @IBOutlet weak var lineUnderTB2: UIView!
    
    @IBOutlet weak var pgStack: UIStackView!
    @IBOutlet weak var pg_title: UILabel!
    @IBOutlet weak var pg_subtitle: UILabel!
    @IBOutlet weak var pg_time: UIButton!
    @IBOutlet weak var pg_button: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateFromBackground()
        // set time buttons disabled properties
        self.tb_button.setTitleColor(UIColor.blue, for: .normal)
        self.tb_time.setTitleColor(UIColor.lightGray, for: .disabled)
        self.tb_button.setTitleColor(UIColor.lightGray, for: .disabled)
        self.pg_button.setTitleColor(UIColor.blue, for: .normal)
        self.pg_time.setTitleColor(UIColor.lightGray, for: .disabled)
        self.pg_button.setTitleColor(UIColor.lightGray, for: .disabled)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // *** Load pill views ***
        appearViews()
        
    }
    
    private func appearViews() {
        // TBLOCK
        // including tb
        if PillDataController.includingTB() {
            appear(including: PillDataController.includingTB(), stamps: PillDataController.tb_stamps, timesaday: PillDataController.getTBDailyInt(), first_t: PillDataController.getTB1Time(), second_t: PillDataController.getTB2Time(), mode: 0)
        }
            // not-including tb
        else {
            self.tbStack.isHidden = true
        }
        // PG
        // including pg
        if PillDataController.includingPG() {
            appear(including: PillDataController.includingPG(), stamps: PillDataController.pg_stamps, timesaday: PillDataController.getPGDailyInt(), first_t: PillDataController.getPG1Time(), second_t: PillDataController.getPG2Time(), mode: 1)
        }
            // not including pg
        else {
            self.pgStack.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions
    
    @IBAction func tb_tapped(_ sender: Any) {
        
        // undo tapped
        if let b = sender as? UIButton, b.accessibilityIdentifier == "tbundo", b.titleLabel?.text == PDStrings.undo {
            PillDataController.resetLaterTB()
            if (PillDataController.tbIsDue()) {
                self.tb_time.setTitleColor(UIColor.red, for: .normal)
                if let oldstamp = PillDataController.getOlderStamp(stamps: PillDataController.tb_stamps) {
                    self.tb_time.setTitle(PillDataController.format(date: oldstamp) + " - " + PDStrings.due, for: .normal)
                }
                else {
                    self.tb_time.setTitle(PDStrings.nothing_yet_placeholder + " - " + PDStrings.due, for: .normal)
                }
                self.tb_time.isEnabled = true
            }
            else {
                if let oldstamp = PillDataController.getOlderStamp(stamps: PillDataController.tb_stamps) {
                    self.tb_time.setTitle(PillDataController.format(date: oldstamp), for: .normal)
                }
                else {
                    self.tb_time.setTitle(PDStrings.nothing_yet_placeholder, for: .normal)
                }
                self.tb_time.isEnabled = true
            }
            
            if PillDataController.noRecords(stamps: PillDataController.tb_stamps) {
                self.tb_button.isEnabled = false
            }
        }
        else {
            let stamp = Stamp()
            PillDataController.take(this: &PillDataController.tb_stamps, at: stamp, timesaday: PillDataController.getTBDailyInt(), key: PDStrings.tbStamp_key())
            self.tb_button.isEnabled = true
            self.tb_time.setTitle(PillDataController.format(date: stamp), for: .normal)
            if (PillDataController.tbIsDone()) {
                self.disableTB(stamp: stamp)
            }
            appDelegate.notificationsController.requestNotifyTakePill(mode: 0)
            
            self.makeUndoButton(button: self.tb_button)
        }
    }
    
    @IBAction func pg_tapped(_ sender: Any) {
        
        // undo tapped
        if let b = sender as? UIButton, b.accessibilityIdentifier == "pgundo", b.titleLabel?.text == PDStrings.undo {
            PillDataController.resetLaterPG()
            if (PillDataController.pgIsDue()) {
                self.pg_time.setTitleColor(UIColor.red, for: .normal)
                if let oldstamp = PillDataController.getOlderStamp(stamps: PillDataController.pg_stamps) {
                    self.pg_time.setTitle(PillDataController.format(time: oldstamp) + " - " + PDStrings.due, for: .normal)
                }
                else {
                    self.pg_time.setTitle(PDStrings.nothing_yet_placeholder + " - " + PDStrings.due, for: .normal)
                }
                self.pg_time.isEnabled = true
            }
            else {
                if let oldstamp = PillDataController.getOlderStamp(stamps: PillDataController.pg_stamps) {
                    self.pg_time.setTitle(PillDataController.format(time: oldstamp), for: .normal)
                }
                else {
                    self.pg_time.setTitle(PDStrings.nothing_yet_placeholder, for: .normal)
                }
                self.pg_time.isEnabled = true
            }
            
            if PillDataController.noRecords(stamps: PillDataController.pg_stamps) {
                self.pg_button.isEnabled = false
            }
        }
        else {
            let stamp = Stamp()
            PillDataController.take(this: &PillDataController.pg_stamps, at: stamp, timesaday: PillDataController.getPGDailyInt(), key: PDStrings.pgStamp_key())
            self.pg_time.setTitle(PillDataController.format(date: stamp), for: .normal)
            self.pg_button.isEnabled = true
            if PillDataController.pgIsDone() {
                self.disablePG(stamp: stamp)
            }
            appDelegate.notificationsController.requestNotifyTakePill(mode: 1)
            
            self.makeUndoButton(button: self.pg_button)
        }
    }
    
    // MARK: - Private / Helpers
    
    private func makeUndoButton(button: UIButton) {
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle(PDStrings.undo, for: .normal)
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
        let timeArrows = [self.tb_button, self.pg_button]
        if including, let tb = timeButtons[mode], let ta = timeArrows[mode] {
            let isDue = PillDataController.isDue(timesaday: timesaday, stamps: stamps, time1: first_t, time2: second_t)
            if let laterStamp: Stamp = PillDataController.getLaterStamp(stamps: stamps) {
                
                let takenToday = PillDataController.takenToday(stamps: stamps)
                if takenToday {
                    self.makeUndoButton(button: ta)
                }
                
                //**********************************
                // RED w/ " - due"
                // Uses a "time" instead of a "stamp" when due
                if isDue {
                    let time: Time = (PillDataController.useSecondTime(timesaday: timesaday, stamp: laterStamp)) ? second_t : first_t
                    tb.setTitle(PillDataController.format(time: time) + " - " + PDStrings.due, for: .normal)
                    tb.setTitleColor(UIColor.red, for: .normal)
                    if !takenToday {
                        ta.isEnabled = false
                    }
                    return
                }
                    
                //**********************************
                // GRAY w/ disabled: Both pills taken today
                else if let earlierStamp: Stamp = PillDataController.getOlderStamp(stamps: stamps), PillDataController.allStampedToday(stamps: stamps, timesaday: timesaday)  {
                    if mode == 0 {
                        self.disableTB(stamp: earlierStamp)
                        self.makeUndoButton(button: self.tb_button)
                    }
                    else {
                        self.disablePG(stamp: earlierStamp)
                        self.makeUndoButton(button: self.pg_button)
                    }
                    return
                }
                    
                //**********************************
                // BLUE: w/ enabled
                else {
                    tb.setTitle(PillDataController.format(date: laterStamp), for: .normal)
                    return
                }
            }
            // Never taken
            else if isDue {
                tb.setTitle(PDStrings.nothing_yet_placeholder + " - " + PDStrings.due, for: .normal)
                tb.setTitleColor(UIColor.red, for: .normal)
                ta.isEnabled = false
                return
            }
        }
        // problem loading view.
        mode == 0 ? self.tb_time.setTitle(PDStrings.nothing_yet_placeholder, for: .normal) : self.pg_time.setTitle(PDStrings.nothing_yet_placeholder, for: .normal)
    }
    
    internal func updateFromBackground() {
        // this part is for updating the pill views when VC is reloaded from a notification
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc internal func appWillEnterForeground() {
        self.appearViews()
    }

}
