//
//  PillVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 12/16/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

class PillVC: UIViewController {
    
    // times
    var tbt1 = SettingsDefaultsController.getTB1Time()
    var tbt2 = SettingsDefaultsController.getTB2Time()
    var pgt1 = SettingsDefaultsController.getPG1Time()
    var pgt2 = SettingsDefaultsController.getPG2Time()
    
    // time strings
    var tbt1_s: NSMutableAttributedString = NSMutableAttributedString(string: SettingsDefaultsController.formatTime(time: SettingsDefaultsController.getTB1Time()), attributes:[NSAttributedStringKey.foregroundColor : UIColor.darkGray])
    var tbt2_s: NSMutableAttributedString = NSMutableAttributedString(string: SettingsDefaultsController.formatTime(time: SettingsDefaultsController.getTB2Time()), attributes:[NSAttributedStringKey.foregroundColor : UIColor.darkGray])
    var pgt1_s: NSMutableAttributedString = NSMutableAttributedString(string: SettingsDefaultsController.formatTime(time: SettingsDefaultsController.getPG1Time()), attributes:[NSAttributedStringKey.foregroundColor : UIColor.darkGray])
    var pgt2_s: NSMutableAttributedString = NSMutableAttributedString(string: SettingsDefaultsController.formatTime(time: SettingsDefaultsController.getPG2Time()), attributes:[NSAttributedStringKey.foregroundColor : UIColor.darkGray])
    
    // UI elements
    @IBOutlet weak var pillStack: UIStackView!
    @IBOutlet weak var tb_title: UILabel!
    @IBOutlet weak var tb1_button: UIButton!
    @IBOutlet weak var lineUnderTB1: UIView!
    @IBOutlet weak var tb1_title: UILabel!
    @IBOutlet weak var tb1_time: UIButton!
    @IBOutlet weak var tb2_button: UIButton!
    @IBOutlet weak var tb2_stack: UIStackView!
    @IBOutlet weak var tb2_time: UIButton!
    @IBOutlet weak var lineUnderTB2: UIView!
    @IBOutlet weak var pg_title: UILabel!
    @IBOutlet weak var pg1_title: UILabel!
    @IBOutlet weak var pg1_time: UIButton!
    @IBOutlet weak var pg1_button: UIButton!
    @IBOutlet weak var pg2_stack: UIStackView!
    @IBOutlet weak var pg2_time: UIButton!
    @IBOutlet weak var pg2_button: UIButton!
    @IBOutlet weak var lineUnderPG2: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set time buttons disabled properties
        self.tb1_button.setTitle("✓", for: .disabled)
        self.tb1_button.setTitleColor(UIColor.lightGray, for: .disabled)
        self.disableColor(timeButton: self.tb1_time)
        self.tb2_button.setTitle("✓", for: .disabled)
        self.tb2_button.setTitleColor(UIColor.lightGray, for: .disabled)
        self.pg1_button.setTitle("✓", for: .disabled)
        self.pg1_button.setTitleColor(UIColor.lightGray, for: .disabled)
        self.disableColor(timeButton: self.pg1_time)
        self.pg2_button.setTitle("✓", for: .disabled)
        self.pg2_button.setTitleColor(UIColor.lightGray, for: .disabled)

        // *** Load pill times ***
        //************************************************
        // TBLOCK
        //************************************************
        if SettingsDefaultsController.getIncludeTB() {
            //set tb time 1
            self.setTimeButton(timeButton: self.tb1_time, time: self.tbt1, time_s: self.tbt1_s)
            // has tb1 been checked off today?
            if SettingsDefaultsController.tb1_stamped {
                self.checkOff(button_arrow: self.tb1_button, button_time: self.tb1_time, time_s: SettingsDefaultsController.getTB1TimeStamp())
            }
            // one testosterone-blocker a day
            if SettingsDefaultsController.getTBtimesadayInt() == 1 {
                self.tb1_title.text = PDStrings.time
                self.tb2_button.isEnabled = false
                self.tb2_button.isHidden = true
                self.tb2_stack.isHidden = true
                self.lineUnderTB2.isHidden = true
            }
            // two testosterone-blockers a day
            else {
                // set tb time 2
                self.setTimeButton(timeButton: self.tb2_time, time: self.tbt2, time_s: self.tbt2_s)
                // has tb2 been checked off today?
                if SettingsDefaultsController.tb2_stamped {
                    self.checkOff(button_arrow: self.tb2_button, button_time: self.tb2_time, time_s: SettingsDefaultsController.getTB2TimeStamp())
                }
            }
        }
        // zero testosterone-blockers a day
        else {
            self.tb_title.text = PDStrings.tb_disabled
            self.tb_title.textColor = UIColor.lightGray
            self.tb1_time.isEnabled = false
            self.tb1_button.isEnabled = false
            self.tb2_stack.isHidden = true
            self.tb2_time.isHidden = true
            self.lineUnderTB2.isHidden = true
        }
        //************************************************
        // PG
        //************************************************
        if SettingsDefaultsController.getIncludePG() {
            // set pg time 1
            self.setTimeButton(timeButton: self.pg1_time, time: self.pgt1, time_s: self.pgt1_s)
            // has pg1 been checked off today?
            if SettingsDefaultsController.pg1_stamped {
                self.checkOff(button_arrow: self.pg1_button, button_time: self.pg1_time, time_s: SettingsDefaultsController.getPG1TimeStamp())
            }
            // one progesterone a day
            if SettingsDefaultsController.getPGtimesadayInt() == 1 {
                self.pg1_title.text = PDStrings.time
                self.pg2_button.isEnabled = false
                self.pg2_button.isHidden = true
                self.pg2_stack.isHidden = true
                self.lineUnderPG2.isHidden = true
            }
             // two progesterones a day
            else {
                // set pg time 2
                self.setTimeButton(timeButton: self.pg2_time, time: self.pgt2, time_s: self.pgt2_s)
                // has pg2 been checked off today?
                if SettingsDefaultsController.pg2_stamped {
                    self.checkOff(button_arrow: self.pg2_button, button_time: self.pg2_time, time_s: SettingsDefaultsController.getPG2TimeStamp())
                }
            }
        }
        // zero progesterone a day
        else {
            self.pg_title.text = PDStrings.pg_disabled
            self.pg_title.textColor = UIColor.lightGray
            self.pg1_time.isEnabled = false
            self.pg1_button.isEnabled = false
            self.pg2_stack.isHidden = true
            self.pg2_time.isHidden = true
            self.lineUnderPG2.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBACtions
    
    
    
    @IBAction func tb1_tapped(_ sender: Any) {
        SettingsDefaultsController.tb1_stamped = true
        SettingsDefaultsController.setTB1TimeStamp(to: Date())
        self.checkOff(button_arrow: self.tb1_button, button_time: self.tb1_time, time_s: SettingsDefaultsController.getTB1TimeStamp())
    }
    
    @IBAction func tb2_tapped(_ sender: Any) {
        SettingsDefaultsController.tb2_stamped = true
        SettingsDefaultsController.setTB2TimeStamp(to: Date())
        self.checkOff(button_arrow: self.tb2_button, button_time: self.tb2_time, time_s: SettingsDefaultsController.getTB2TimeStamp())
    }
    
    @IBAction func pg1_tapped(_ sender: Any) {
        SettingsDefaultsController.pg1_stamped = true
        SettingsDefaultsController.setPG1TimeStamp(to: Date())
        self.checkOff(button_arrow: self.pg1_button, button_time: self.pg1_time, time_s: SettingsDefaultsController.getPG1TimeStamp())
    }
    
    @IBAction func pg2_tapped(_ sender: Any) {
        SettingsDefaultsController.pg2_stamped = true
        SettingsDefaultsController.setPG2TimeStamp(to: Date())
        self.checkOff(button_arrow: self.pg2_button, button_time: self.pg2_time, time_s: SettingsDefaultsController.getPG2TimeStamp())
        SettingsDefaultsController.setPG2TimeStamp(to: Date())
    }
    
    // MARK: - Private Helpers
    
    private func setTimeButton(timeButton: UIButton, time: Date, time_s: NSMutableAttributedString) {
        // non-expired
        if SettingsDefaultsController.isAfterNow(time: time) {
            timeButton.setAttributedTitle(time_s, for: .normal)
        }
        // expired
        else {
            let title: NSMutableAttributedString = NSMutableAttributedString(string: time_s.string + " - " + PDStrings.due, attributes: [NSAttributedStringKey.foregroundColor : UIColor.red])
            timeButton.setAttributedTitle(title, for: .normal)
        }
    }
    
    // checkOff(button_arrow, button_time, time_s) : disables the pill buttons, slashes out the title of the time checked off and puts it as the button_time title.  This happens during the IBActions for each of the pill buttons when marking a pill as "taken".
    private func checkOff(button_arrow: UIButton, button_time: UIButton, time_s: Date) {
        let timeStampString: NSMutableAttributedString = NSMutableAttributedString(string: SettingsDefaultsController.formatTime(time: time_s))
        button_arrow.isEnabled = false
        button_time.isEnabled = false
        // slash out button time
        button_time.setAttributedTitle(self.slashOut(s: timeStampString), for: .disabled)
    }
    
    // slashOut(s) : slash out a string with a line, used on time strings in the Pill View
    private func slashOut(s: NSMutableAttributedString) -> NSMutableAttributedString {
        let crossedOut_s: NSMutableAttributedString = NSMutableAttributedString(string: s.string, attributes: [NSAttributedStringKey.foregroundColor : UIColor.lightGray])
        crossedOut_s.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: NSMakeRange(0, crossedOut_s.length))
        return crossedOut_s
    }
    
    private func disableColor(timeButton: UIButton) {
        if let title = timeButton.titleLabel, let text = title.text {
            let disabledTimeStr: NSMutableAttributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : UIColor.lightGray])
            timeButton.setAttributedTitle(disabledTimeStr, for: .disabled)
        }
    }

}
