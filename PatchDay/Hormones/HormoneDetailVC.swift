//
//  EstrogenVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/27/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class HormoneDetailVC: UIViewController,
                  UIPickerViewDelegate,
                  UIPickerViewDataSource,
                  UITextFieldDelegate {
    
    private var model: HormonesModel = HormonesModel()
    private var selectedSite: Bodily?
    
    //MARK: - Main
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    // Interface
    private weak var saveButton: UIBarButtonItem!
    @IBOutlet private weak var dateAndTimePlaced: UILabel!
    @IBOutlet private weak var selectSiteTextField: UITextField!
    @IBOutlet private weak var chooseDateButton: UIButton!
    @IBOutlet private weak var datePickerInputView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet private weak var lineUnderScheduleDate: UIView!
    @IBOutlet private weak var lineUnderDate: UIView!
    @IBOutlet private weak var lineUnderDateAndTimePlaced: UIView!
    @IBOutlet private weak var bigGap: UIView!
    @IBOutlet private weak var expLabel: UILabel!
    @IBOutlet private weak var expirationDateLabel: UILabel!
    @IBOutlet private weak var lineUnderExpires: UIView!
    @IBOutlet private weak var bigGap2: UIView!
    @IBOutlet private weak var horizontalLineAboveSite: UIView!
    @IBOutlet private weak var siteStackView: UIStackView!
    @IBOutlet private weak var siteLabel: UILabel!
    @IBOutlet private weak var verticalLineInSiteStack: UIView!
    @IBOutlet private var typeSiteButton: UIButton!
    @IBOutlet public weak var sitePicker: UIPickerView!
    @IBOutlet private var horizontalLineBelowSite: UIView!
    @IBOutlet private weak var autofillButton: UIButton!

    // Non-interface
    var hormone: Hormonal!
    var site: String = ""
    var datePlaced: Date = Date()
    var dateSelected: Date?
    private var siteTextHasChanged = false
    private var dateTextHasChanged = false
    private var shouldSaveSelectedSiteIndex = false
    private var shouldSaveIncrementedSiteIndex = false
    private var siteIndexSelected = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTitle()
        loadExpirationText()
        loadSiteControls()
        loadSaveButton()
        loadAutofillButton()
        loadExpirationText()
        loadSiteControls()
    }
    
    static func createHormoneDetailVC(source: UIViewController, hormone: Hormonal) -> HormoneDetailVC? {
        let id = "HormoneDetailVC_id"
        if let moneVC = source.storyboard?.instantiateViewController(withIdentifier: id) as? HormoneDetailVC {
            moneVC.hormone = hormone
            return moneVC
        }
        return nil
    }
    
    var hormoneIndex: Index {
        return model.hormones?.indexOf(hormone) ?? -1
    }

    @objc private func saveButtonTapped(_ sender: Any) {
        if let mone = hormone {
            let wasExpiredBeforeSave = mone.isExpired
            saveData()
            let isExpiredAfterSave = mone.isExpired
            configureBadgeIcon(wasExpiredBeforeSave, isExpiredAfterSave)
            requestNotifications()
        }
        self.tabs?.reflectHormone()
        if let navCon = navigationController {
            navCon.popViewController(animated: true)
        }
    }
    
    @IBAction private func autofillTapped(_ sender: Any) {
        autoPickSite()
        autoPickDate()
        saveButton.isEnabled = true
    }
    
    // MARK: - Text Edit Functions
    
    @IBAction private func keyboardTapped(_ sender: Any) {
        selectSiteTextField.restorationIdentifier = "type"
        selectSiteTextField.becomeFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectSiteTextField.isUserInteractionEnabled = true
        chooseDateButton.isEnabled = false
        autofillButton.isHidden = true
        typeSiteButton.setTitle(PDActionStrings.done, for: .normal)
        var newAction: Selector?
        switch (textField.restorationIdentifier) {
            case "type" :
                selectSiteTextField.isEnabled = true
                selectSiteTextField.text = ""
                textField.restorationIdentifier = "pick"
                newAction = #selector(closeTextField)
            case "pick" :
                view.endEditing(true)
                selectSiteTextField.isEnabled = false
                newAction = #selector(closeSitePicker)
                fallthrough
            default : openSitePicker(textField)
        }
        if let new = newAction {
            typeSiteButton.replaceTarget(self, newAction: new)
        }
    }
    
    @objc func closeTextField() {
        self.selectedSite = nil
        siteTextHasChanged = true
        if selectSiteTextField.text == "" {
            selectSiteTextField.text = PDStrings.PlaceholderStrings.newSite
        }
        typeSiteButton.setTitle(PDActionStrings.type, for: .normal)
        selectSiteTextField.endEditing(true)
        selectSiteTextField.isEnabled = true
        chooseDateButton.isEnabled = true
        autofillButton.isHidden = false
        selectSiteTextField.isHidden = false
        saveButton.isEnabled = true
        typeSiteButton.replaceTarget(self, newAction: #selector(keyboardTapped(_:)))
        siteIndexSelected = sdk?.sites.count ?? 1
        if let n = selectSiteTextField.text {
            alerts?.presentNewSiteAlert(
                with: n,
                at: siteIndexSelected,
                moneVC: self
            )
        }
    }
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        closeTextField()
        return true
    }
    
    // MARK: - Picker Functions
    
    @IBAction func openSitePicker(_ sender: Any) {
        UIView.transition(with: sitePicker as UIView,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: { self.sitePicker.isHidden = false
        }, completion: nil)
        sitePicker.selectRow(findSiteStartRow(site), inComponent: 0, animated: false)
        autofillButton.isHidden = true
        autofillButton.isEnabled = false
        selectSiteTextField.isEnabled = false
        chooseDateButton.isEnabled = false
    }
    
    @objc func closeSitePicker() {
        sitePicker.isHidden = true
        autofillButton.isEnabled = true
        chooseDateButton.isEnabled = true
        selectSiteTextField.isEnabled = true
        selectSiteTextField.isHidden = false
        autofillButton.isHidden = false
        siteTextHasChanged = true
        saveButton.isEnabled = true
        shouldSaveSelectedSiteIndex = true
        shouldSaveIncrementedSiteIndex = false
        typeSiteButton.setTitle(PDActionStrings.type, for: .normal)
        typeSiteButton.replaceTarget(self, newAction: #selector(keyboardTapped(_:)))
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return sdk?.sites.count ?? 0
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String? {
        return sdk?.sites.names.tryGet(at: row) ?? ""
    }
    
    // Done
    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int
    ) {
        if let name = sdk?.sites.names.tryGet(at: row) {
            selectedSite = sdk?.sites.at(row)
            selectSiteTextField.text = name
            closeSitePicker()
            siteIndexSelected = row
        }
    }

    // MARK: - Date Picker funcs
    
    @IBAction func chooseDateTextTapped(_ sender: Any) {
        // Unhide date picker
        UIView.transition(
            with: datePickerInputView as UIView,
            duration: 0.4,
            options: .transitionCrossDissolve,
            animations: { self.datePickerInputView.isHidden = false },
            completion: nil
        )
        datePicker.date = dateSelected ?? hormone.date
        let doneButton = makeDoneButton()
        datePickerInputView.addSubview(doneButton)
        autofillButton.isHidden = true
        chooseDateButton.isEnabled = false
        typeSiteButton.isEnabled = false
        selectSiteTextField.isEnabled = false
    }
    
    @objc func datePickerDone(_ sender: Any) {
        let doneButton = sender as! UIButton
        doneButton.removeFromSuperview()
        datePickerInputView.isHidden = true
        dateSelected = datePicker.date
        let interval = sdk?.defaults.expirationInterval.hours ?? 0
        let dateStr = PDDateHelper.format(date: datePicker.date, useWords: true)
        chooseDateButton.setTitle(dateStr, for: UIControl.State.normal)
        if let expDate = PDDateHelper.expirationDate(from: datePicker.date, interval) {
            expirationDateLabel.text = PDDateHelper.format(date: expDate, useWords: true)
        }
        // outer view changes
        saveButton.isEnabled = true
        chooseDateButton.isEnabled = true
        typeSiteButton.isEnabled = true
        autofillButton.isHidden = false
        siteStackView.isHidden = false
        siteLabel.isHidden = false
        dateTextHasChanged = true
        selectSiteTextField.isEnabled = true
    }
    
    // MARK: - private funcs
    
    private func loadTitle() {
        title = PDVCTitleStrings.getTitle(for: sdk?.deliveryMethod ?? .Patches)
    }
    
    private func loadExpirationText() {
        if let mone = hormone, let method = sdk?.deliveryMethod {
            let viewStrings = PDColonedStrings.getHormoneViewStrings(
                deliveryMethod: method,
                hormone: mone
            )
            expLabel.text = viewStrings.expirationText
            dateAndTimePlaced.text = viewStrings.dateAndTimePlacedText
            siteLabel.text = viewStrings.siteLabeText
            expirationDateLabel.text  = mone.expirationString
        } else {
            expirationDateLabel.text  = PDStrings.PlaceholderStrings.dotDotDot
        }
    }
    
    private func loadSiteControls() {
        selectSiteTextField.autocapitalizationType = .words
        selectSiteTextField.text = hormone.isCerebral
            ? PDActionStrings.select : hormone.siteName
        selectSiteTextField.restorationIdentifier = "pick"
        selectSiteTextField.delegate = self
        sitePicker.delegate = self
        sitePicker.dataSource = self
        verticalLineInSiteStack.backgroundColor = lineUnderDate.backgroundColor
        typeSiteButton.setTitle(PDActionStrings.type, for: .normal)
    }
    
    private func loadSaveButton() {
        let save = PDActionStrings.save
        let handleSave = #selector(saveButtonTapped(_:))
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: save, style: .plain, target: self, action: handleSave
        )
        saveButton = navigationItem.rightBarButtonItem
        saveButton.isEnabled = false
    }
    
    private func loadAutofillButton() {
        autofillButton.setTitleColor(UIColor.darkGray, for: UIControl.State.disabled)
        if AppDelegate.isPad {
            topConstraint.constant = 100
            autofillButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        }
    }

    private func saveData() {
        switch (saveSite: siteTextHasChanged, saveDate: dateTextHasChanged) {
        case (saveSite: true, saveDate: true):
            if let site = selectedSite {
                sdk?.setHormoneDateAndSite(
                    at: hormoneIndex,
                    date: datePicker.date,
                    site: site
                )
            }
        case (saveSite: true, saveDate: false):
            if let site = selectedSite {
                sdk?.setHormoneSite(at: hormoneIndex, with: site)
            }
        case (saveSite: false, saveDate: true):
            sdk?.setHormoneDate(at: hormoneIndex, with: datePicker.date)
        default:
            return
        }
    }
    
    private func autoPickSite() {
        if let nextSite = sdk?.sites.suggested {
            shouldSaveIncrementedSiteIndex = true
            shouldSaveSelectedSiteIndex = false
            selectSiteTextField.text = nextSite.name
            siteTextHasChanged = true
            siteIndexSelected = nextSite.order
        }
    }
    
    private func autoPickDate() {
        let now = Date()
        chooseDateButton.setTitle(PDDateHelper.format(date: now, useWords: true), for: .normal)
        if let interval = sdk?.defaults.expirationInterval.hours,
            let expDate = PDDateHelper.expirationDate(from: now, interval) {
            
            expirationDateLabel.text = PDDateHelper.format(date: expDate, useWords: true)
            dateTextHasChanged = true
            dateSelected = now
        }
    }
    
    private func requestNotifications() {
        if let mone = hormone, let n = notifications {
            n.requestExpiredHormoneNotification(for: mone)
            if mone.expiresOvernight {
                n.requestOvernightExpirationNotification(mone)
            }
        }
    }
    
    private func cancelNotification() {
        notifications?.requestExpiredHormoneNotification(for: hormone)
    }
    
    // MARK: - Private
    
    private func findSiteStartRow(_ site: String) -> Int {
        if siteIndexSelected != -1 {
            return siteIndexSelected
        } else if let site = hormone.site {
            let order = site.order
            let end = sdk?.sites.count ?? 0
            if order >= 1 && order <= end {
                siteIndexSelected = order
                return order 
            }
        }
        return 0
    }
    
    /// Makes done button for editing state.
    private func makeDoneButton() -> UIButton {
        let donePoint = CGPoint(x: configureDoneButtonStartX(), y: 0)
        let doneSize = CGSize(width: 100, height: 50)
        let doneRect = CGRect(origin: donePoint, size: doneSize)
        let doneButton = UIButton(frame: doneRect)
        doneButton.setTitle(PDActionStrings.done, for: UIControl.State.normal)
        doneButton.setTitle(PDActionStrings.done, for: UIControl.State.highlighted)
        doneButton.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        doneButton.setTitleColor(UIColor.black, for: UIControl.State.highlighted)
        doneButton.replaceTarget(self, newAction: #selector(datePickerDone))
        return doneButton
    }

    private func configureDoneButtonStartX() -> CGFloat {
        return AppDelegate.isPad ? 0 : (view.frame.size.width / 2) - 50
    }
    
    private func configureBadgeIcon(_ wasExpiredBeforeSave: Bool,_ isExpiredAfterSave: Bool) {
        // New mone is fresh
        let hasBadge = UIApplication.shared.applicationIconBadgeNumber > 0
        if !isExpiredAfterSave && hasBadge {
            UIApplication.shared.applicationIconBadgeNumber -= 1
        } else if !wasExpiredBeforeSave && isExpiredAfterSave {
            // New mone is not fresh
            UIApplication.shared.applicationIconBadgeNumber += 1
        }
        if !wasExpiredBeforeSave {
            cancelNotification()
        }
    }

    private func hideLines() {
        lineUnderScheduleDate.isHidden = true
        lineUnderDateAndTimePlaced.isHidden = true
        lineUnderExpires.isHidden = true
        horizontalLineAboveSite.isHidden = true
        horizontalLineBelowSite.isHidden = true
        lineUnderDate.isHidden = true
        verticalLineInSiteStack.isHidden = true
    }
    
    private func unhideLines() {
        lineUnderScheduleDate.isHidden = false
        lineUnderDateAndTimePlaced.isHidden = false
        lineUnderExpires.isHidden = false
        horizontalLineAboveSite.isHidden = false
        horizontalLineBelowSite.isHidden = false
        lineUnderDate.isHidden = false
        verticalLineInSiteStack.isHidden = false
    }
}
