//
//  SiteImagePickerDelegate.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/12/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class SiteImagePickerDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {

	private var props: SiteImagePickerDelegateProperties

	init(props: SiteImagePickerDelegateProperties) {
		self.props = props
		super.init()
	}

	var picker: UIPickerView {
		props.views.getPicker()
	}

	var imageView: UIImageView {
		props.views.getImageView()
	}

	var options: [UIImage?] {
		props.imageOptions
	}

	var selectedRow: Index {
		props.selectedImageIndex
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		props.imageOptions.count
	}

	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		DefaultNumberOfPickerComponents
	}

	func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
		SiteDetailConstants.SiteImageRowHeight
	}

	func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
		SiteDetailConstants.SiteImageRowWidth
	}

	func pickerView(
		_ pickerView: UIPickerView,
		viewForRow row: Int,
		forComponent component: Int,
		reusing view: UIView?
	) -> UIView {
		let size = SiteDetailConstants.SiteImageResizedSize
		if let image = getImage(at: row) {
			let resizedImage = ImageResizer.resize(image, targetSize: size)
			return UIImageView(image: resizedImage)
		}
		return UIImageView()
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		props.selectedImageIndex = row
		let imageView = props.views.getImageView()
		imageView.image = getImage(at: row)
	}

	public func openPicker(completion: @escaping () -> ()) {
		showPicker() {
			completion()
		}
	}

	private func getImage(at row: Index) -> UIImage? {
		props.imageOptions.tryGet(at: row)
	}

	private func showPicker(completion: @escaping () -> ()) {
		UIView.transition(
			with: props.views.getPicker() as UIView,
			duration: 0.4,
			options: .transitionFlipFromTop,
			animations: {
				self.props.views.getPicker().isHidden = false
				self.props.views.getSaveButton().isEnabled = true
			},
			completion: { void in completion() }
		)
	}
}
