//
//  SiteDetailVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/11/18.

import UIKit
import PDKit

class SiteDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    var viewModel: SiteDetailViewModelProtocol!

    @IBOutlet weak var siteStack: UIStackView!
    @IBOutlet weak var nameStackVertical: UIStackView!
    @IBOutlet weak var nameStackHorizontal: UIStackView!
    @IBOutlet weak var verticalLineByNameTextField: UIView!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lineUnderNameLabel: UIView!
    @IBOutlet weak var typeNameButton: UIButton!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var namePicker: UIPickerView!
    @IBOutlet weak var gapAboveImage: UIView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var imagePickerDoneButton: UIButton!

    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var lineUnderImageLabel: UIView!
    @IBOutlet weak var imageInputView: UIView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var siteImageView: UIImageView!
    @IBOutlet weak var imagePicker: UIPickerView!
    @IBOutlet weak var lineUnderNameStack: UIView!

    private var saveButton: UIBarButtonItem {
        navigationItem.rightBarButtonItem ?? UIBarButtonItem()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        willEnterForeground()
        setRuntimeViewProps()
        applyDelegates()
        loadTitle()
        setBackButton()
    }

    static func createSiteDetailVC(
        _ source: UIViewController, _ index: Index, params: SiteImageDeterminationParameters
    ) -> SiteDetailViewController? {
        createSiteDetailsVC(source)?.initWithSiteIndex(index, imageParams: params)
    }

    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        willEnterForeground()
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        closeSiteTextField()  // Mostly to help emulator 
    }

    @objc func willEnterForeground() {
        guard viewModel.siteName != nil else {
            // Remove outdated observer
            NotificationCenter.default.removeObserver(
                self,
                name: UIApplication.willEnterForegroundNotification,
                object: nil
            )
            return
        }
        loadName()
        self.siteImageView.image = viewModel.siteImage
        loadSave()
        applyTheme()
    }

    private static func createSiteDetailsVC(
        _ source: UIViewController
    ) -> SiteDetailViewController? {
        let id = ViewControllerIds.SiteDetail
        let sb = source.storyboard
        return sb?.instantiateViewController(withIdentifier: id) as? SiteDetailViewController
    }

    // MARK: - Actions

    @IBAction func doneButtonTapped(_ sender: Any) {
        imagePicker.isHidden = true
        imageButton.isEnabled = true
        nameText.isEnabled = true
        siteImageView.isHidden = false
        imageButton.isHidden = false
        imageButton.isEnabled = true
        typeNameButton.isEnabled = true
        imagePickerDoneButton.hideAsDisabled()
        enableSave()
    }

    @IBAction func imageButtonTapped(_ sender: Any) {
        guard let picker = viewModel.imagePicker else { return }
        siteImageView.isHidden = true
        imageButton.isEnabled = false
        picker.openPicker {
            self.typeNameButton.isEnabled = false
            self.imageButton.isEnabled = false
            self.nameText.isEnabled = false
            self.imagePickerDoneButton.isHidden = false
            self.imagePickerDoneButton.isEnabled = true
        }
    }

    @IBAction func typeTapped(_ sender: Any) {
        nameText.restorationIdentifier = SiteDetailConstants.TypeId
        nameText.becomeFirstResponder()
    }

    @objc func saveButtonTapped(_ sender: Any) {
        // Close to save the current name in the text if changed
        // The save button is tempting to tap right away if you are quickly just changing a name
        // ... normally you have to tap the Done button first on picker to set the selection.
        closeSiteTextField()
        viewModel.handleSave(siteDetailViewController: self)
    }

    // MARK: - Text field

    /// Prevents the text field from exceededing a reasonable limit of characters.
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""
        let result = TextFieldHelper.canSet(
            currentString: currentText, replacementString: string, range: range
        )
        if result.canReplace && result.updatedText != SiteStrings.NewSite {
            viewModel.selections.selectedSiteName = result.updatedText
            enableSave()
        } else {
            // Unable to allow user to name their site "New Site" because it is used
            // as a detection mechanism for prompting for unsaved changes after creating
            // a new site.
            disableSave()

        }
        return result.canReplace
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        imageButton.isEnabled = false
        typeNameButton.setTitle(ActionStrings.Done)
        if textField.restorationIdentifier == SiteDetailConstants.TypeId {
            nameText.isEnabled = true
            textField.restorationIdentifier = SiteDetailConstants.SelectId
            typeNameButton.replaceTarget(self, newAction: #selector(closeSiteTextField))
        } else if textField.restorationIdentifier == SiteDetailConstants.SelectId {
            view.endEditing(true)
            nameText.isEnabled = false
            openPicker(namePicker)
            typeNameButton.replaceTarget(self, newAction: #selector(closeNamePicker))
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        closeSiteTextField()
        return true
    }

    @objc func closeSiteTextField() {
        view.endEditing(true)
        viewModel.selections.selectedSiteName = nameText.text
        nameText.restorationIdentifier = SiteDetailConstants.SelectId
        if nameText.text == "" {
            nameText.text = SiteStrings.NewSite
        }
        showSiteImage()
        typeNameButton.setTitle(ActionStrings._Type, for: .normal)
        nameText.removeTarget(self, action: #selector(closeSiteTextField))
        typeNameButton.addTarget(self, action: #selector(typeTapped(_:)))
        imageButton.isEnabled = true
    }

    // MARK: - Picker functions

    @objc private func openPicker(_ picker: UIPickerView) {
        namePicker.selectRow(viewModel.siteNamePickerStartIndex, inComponent: 0, animated: true)
        showPicker(picker)
        imageButton.isEnabled = false
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        DefaultNumberOfPickerComponents
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        viewModel.siteNameOptions.count
    }

    func pickerView(
        _ pickerView: UIPickerView,
        attributedTitleForRow row: Int,
        forComponent component: Int
    ) -> NSAttributedString? {
        viewModel.getAttributedSiteName(at: row)
    }

    /// Called when selecting a site name.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let name = viewModel.getSiteName(at: row) else { return }
        self.nameText.text = name
        viewModel.selectSite(name)
    }

    @objc func closeNamePicker() {
        self.namePicker.isHidden = true
        self.lineUnderNameStack.isHidden = false
        self.siteImageView.isHidden = false
        nameText.restorationIdentifier = SiteDetailConstants.SelectId
        typeNameButton.setTitle(ActionStrings._Type, for: .normal)
        nameText.removeTarget(self, action: #selector(closeNamePicker), for: .touchUpInside)
        self.typeNameButton.addTarget(
            self, action: #selector(self.typeTapped(_:)), for: .touchUpInside
        )
        self.nameText.isEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.imageButton.isEnabled = true
    }

    @objc func back() {
        checkForUnsavedChanges()
    }

    // MARK: - Private

    private func applyDelegates() {
        nameText.delegate = self
        namePicker.delegate = self
        namePicker.dataSource = self
        imagePicker.delegate = viewModel.imagePicker
        imagePicker.dataSource = viewModel.imagePicker
    }

    private func setRuntimeViewProps() {
        if AppDelegate.isPad {
            topConstraint.constant = 100
        }
    }

    private func loadTitle() {
        title = viewModel.siteName
    }

    private func setBackButton() {
        let newButton = UIBarButtonItem(
            title: ActionStrings.Back,
            style: UIBarButtonItem.Style.plain,
            target: self,
            action: #selector(back)
        )
        newButton.tintColor = PDColors[.Button]
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = newButton
    }

    private func initWithSiteIndex(
        _ index: Index, imageParams: SiteImageDeterminationParameters
    ) -> SiteDetailViewController {
        let relatedViews = SiteImagePickerRelatedViews(
            getPicker: { self.imagePicker },
            getImageView: { self.siteImageView },
            getSaveButton: { self.saveButton }
        )
        let params = SiteDetailViewModelConstructorParams(index, imageParams, relatedViews)
        return initWithParams(params)
    }

    private func initWithParams(
        _ params: SiteDetailViewModelConstructorParams
    ) -> SiteDetailViewController {
        let viewModel = SiteDetailViewModel(params)
        return initWithViewModel(viewModel)
    }

    private func initWithViewModel(
        _ viewModel: SiteDetailViewModelProtocol
    ) -> SiteDetailViewController {
        self.viewModel = viewModel
        return self
    }

    private func checkForUnsavedChanges() {
        guard let viewModel = viewModel else { return }
        viewModel.handleIfUnsaved(self)
    }

    private func loadName() {
        nameText.text = viewModel.selections.selectedSiteName ?? viewModel.siteName
        nameText.autocapitalizationType = .words
        nameText.borderStyle = .none
        nameText.restorationIdentifier = SiteDetailConstants.SelectId
        typeNameButton.setTitle(ActionStrings._Type)
        typeNameButton.setTitleColor(UIColor.lightGray, for: .disabled)
        namePicker.isHidden = true
    }

    private func showSiteImage() {
        UIView.transition(
            with: siteImageView,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: { self.siteImageView.image = self.viewModel.siteImage },
            completion: nil
        )
    }

    private func loadSave() {
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(
                title: ActionStrings.Save,
                style: .plain,
                target: self,
                action: #selector(saveButtonTapped(_:))
            )
        disableSave()
    }

    private func enableSave() {
        navigationItem.rightBarButtonItem?.isEnabled = true
    }

    private func disableSave() {
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    private func showPicker(_ picker: UIPickerView) {
        UIView.transition(
            with: picker as UIView,
            duration: 0.4,
            options: .transitionFlipFromTop, animations: {
                picker.isHidden = false
                self.lineUnderNameStack.isHidden = true
                self.siteImageView.isHidden = true
            })
    }

    private func applyTheme() {
        view.backgroundColor = UIColor.systemBackground
        nameLabel.textColor = PDColors[.Text]
        lineUnderNameLabel.backgroundColor = PDColors[.Border]
        nameStackVertical.backgroundColor = UIColor.systemBackground
        nameStackHorizontal.backgroundColor = UIColor.systemBackground
        typeNameButton.setTitleColor(PDColors[.Button], for: .normal)
        nameText.textColor = PDColors[.Text]
        nameText.backgroundColor = UIColor.systemBackground
        verticalLineByNameTextField.backgroundColor = PDColors[.Border]
        lineUnderNameStack.backgroundColor = PDColors[.Border]
        imageLabel.textColor = PDColors[.Text]
        lineUnderImageLabel.backgroundColor = PDColors[.Border]
        siteImageView.backgroundColor = UIColor.systemBackground
        gapAboveImage.backgroundColor = UIColor.systemBackground
        imageInputView.backgroundColor = UIColor.systemBackground
        saveButton.tintColor = PDColors[.Button]
        imagePickerDoneButton.setTitleColor(PDColors[.Button])
    }
}
