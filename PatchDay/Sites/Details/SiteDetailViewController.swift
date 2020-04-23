//
//  SiteDetailVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/11/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class SiteDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

	var viewModel: SiteDetailViewModel!

	@IBOutlet weak var siteStack: UIStackView!
	@IBOutlet weak var nameStackVertical: UIStackView!
	@IBOutlet weak var nameStackHorizontal: UIStackView!
	@IBOutlet weak var verticalLineByNameTextField: UIView!
	@IBOutlet weak var typeNameButton: UIButton!
	@IBOutlet weak var nameText: UITextField!
	@IBOutlet weak var namePicker: UIPickerView!
	@IBOutlet weak var gapAboveImage: UIView!
	@IBOutlet weak var topConstraint: NSLayoutConstraint!
	@IBOutlet weak var imagePickerDoneButton: UIButton!
	@IBOutlet weak var imageInputView: UIView!
	@IBOutlet weak var imageButton: UIButton!
	@IBOutlet weak var siteImageView: UIImageView!
	@IBOutlet weak var imagePicker: UIPickerView!
	@IBOutlet weak var bottomLine: UIView!

	private var saveButton: UIBarButtonItem {
		navigationItem.rightBarButtonItem ?? UIBarButtonItem()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setRuntimeViewProps()
		applyDelegates()
		loadTitle()
		loadName()
		loadImage()
		loadSave()
		applyTheme()
	}

	static func createSiteDetailVC(
		_ source: UIViewController, _ site: Bodily, params: SiteImageDeterminationParameters
	) -> SiteDetailViewController? {
		createSiteDetailsVC(source)?.initWithSite(site, imageParams: params)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(false)
		applyTheme()
	}

	private static func createSiteDetailsVC(_ source: UIViewController) -> SiteDetailViewController? {
		let id = ViewControllerIds.SiteDetail
		return source.storyboard?.instantiateViewController(withIdentifier: id) as? SiteDetailViewController
	}

	private func initWithSite(
		_ site: Bodily, imageParams: SiteImageDeterminationParameters
	) -> SiteDetailViewController {
		let relatedViews = SiteImagePickerDelegateRelatedViews(
			getPicker: { self.imagePicker },
			getImageView: { self.siteImageView },
			getSaveButton: { self.saveButton }
		)
		return initWithParams(SiteDetailViewModelConstructorParams(site, imageParams, relatedViews))
	}

	private func initWithParams(_ params: SiteDetailViewModelConstructorParams) -> SiteDetailViewController {
		initWithViewModel(SiteDetailViewModel(params))
	}

	private func initWithViewModel(_ viewModel: SiteDetailViewModel) -> SiteDetailViewController {
		self.viewModel = viewModel
		return self
	}

	// MARK: - Actions

	@IBAction func doneButtonTapped(_ sender: Any) {
		siteImageView.image = viewModel.saveSiteImageChanges()
		imagePicker.isHidden = true
		imageButton.isEnabled = true
		nameText.isEnabled = true
		siteImageView.isHidden = false
		typeNameButton.isEnabled = true
		imagePickerDoneButton.hideAsDisabled()
		enableSave()
	}

	@IBAction func imageButtonTapped(_ sender: Any) {
		siteImageView.isHidden = true
		imageButton.isEnabled = false
		viewModel.imagePickerDelegate.openPicker() {
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
		viewModel.handleSave(siteNameText: nameText.text, siteDetailViewController: self)
	}

	// MARK: - Text field

	func textFieldDidBeginEditing(_ textField: UITextField) {
		enableSave()
		typeNameButton.setTitle(ActionStrings.Done)
		if textField.restorationIdentifier == SiteDetailConstants.TypeId {
			nameText.isEnabled = true
			textField.restorationIdentifier = SiteDetailConstants.SelectId
			typeNameButton.replaceTarget(self, newAction: #selector(closeTextField))
		} else if textField.restorationIdentifier == SiteDetailConstants.SelectId {
			view.endEditing(true)
			nameText.isEnabled = false
			openPicker(namePicker)
			typeNameButton.replaceTarget(self, newAction: #selector(closePicker))
		}
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		closeTextField()
		return true
	}

	@objc func closeTextField() {
		view.endEditing(true)
		nameText.restorationIdentifier = SiteDetailConstants.SelectId
		if nameText.text == "" {
			nameText.text = SiteStrings.NewSite
		}
		loadImage()
		typeNameButton.setTitle(ActionStrings._Type, for: .normal)
		nameText.removeTarget(self, action: #selector(closeTextField))
		typeNameButton.addTarget(self, action: #selector(typeTapped(_:)))
	}

	// MARK: - Picker functions

	@objc private func openPicker(_ picker: UIPickerView) {
		namePicker.selectRow(viewModel.siteNamePickerStartIndex, inComponent: 0, animated: true)
		showPicker(picker)
	}

	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		DefaultNumberOfPickerComponents
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		viewModel.sitesCount
	}

	func pickerView(
		_ pickerView: UIPickerView,
		attributedTitleForRow row: Int,
		forComponent component: Int
	) -> NSAttributedString? {
		viewModel.getAttributedSiteName(at: row)
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if let name = viewModel.getSiteName(at: row) {
			self.nameText.text = name
		}
		closePicker()
	}

	@objc func closePicker() {
		self.namePicker.isHidden = true;
		self.bottomLine.isHidden = false;
		self.siteImageView.isHidden = false;
		nameText.restorationIdentifier = SiteDetailConstants.SelectId
		typeNameButton.setTitle(ActionStrings._Type, for: .normal)
		nameText.removeTarget(self, action: #selector(closePicker), for: .touchUpInside)
		self.typeNameButton.addTarget(self, action: #selector(self.typeTapped(_:)), for: .touchUpInside)
		self.nameText.isEnabled = true
		self.navigationItem.rightBarButtonItem?.isEnabled = true
	}

	// MARK: - Private

	private func applyDelegates() {
		nameText.delegate = self
		namePicker.delegate = self
		namePicker.dataSource = self
		imagePicker.delegate = viewModel.imagePickerDelegate
		imagePicker.dataSource = viewModel.imagePickerDelegate
	}

	private func setRuntimeViewProps() {
		if AppDelegate.isPad {
			topConstraint.constant = 100
		}
		verticalLineByNameTextField.backgroundColor = bottomLine.backgroundColor
	}

	private func loadTitle() {
		title = viewModel.siteDetailViewControllerTitle
	}

	private func loadName() {
		nameText.text = viewModel.siteName
		nameText.autocapitalizationType = .words
		nameText.borderStyle = .none
		nameText.restorationIdentifier = SiteDetailConstants.SelectId
		typeNameButton.setTitle(ActionStrings._Type)
		typeNameButton.setTitleColor(UIColor.lightGray, for: .disabled)
		namePicker.isHidden = true
	}

	private func loadImage() {
		showSiteImage(viewModel.siteImage)
	}

	private func showSiteImage(_ image: UIImage?) {
		UIView.transition(
			with: siteImageView,
			duration: 0.5,
			options: .transitionCrossDissolve,
			animations: { self.siteImageView.image = image },
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
				picker.isHidden = false;
				self.bottomLine.isHidden = true;
				self.siteImageView.isHidden = true
			})
	}

	private func applyTheme() {
		view.backgroundColor = UIColor.systemBackground
		nameStackVertical.backgroundColor = UIColor.systemBackground
		nameStackHorizontal.backgroundColor = UIColor.systemBackground
		typeNameButton.setTitleColor(PDColors[.Button], for: .normal)
		nameText.textColor = PDColors[.Text]
		nameText.backgroundColor = UIColor.systemBackground
		siteImageView.backgroundColor = UIColor.systemBackground
		gapAboveImage.backgroundColor = UIColor.systemBackground
	}
}
