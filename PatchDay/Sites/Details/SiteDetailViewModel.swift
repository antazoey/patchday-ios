//
// Created by Juliya Smith on 12/3/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class SiteDetailViewModel: CodeBehindDependencies<SiteDetailViewModel> {

	private let siteIndex: Index
	
	private var site: Bodily { sdk!.sites[siteIndex]! }
	var selections = SiteSelectionState()

	weak var imagePickerDelegate: SiteImagePicker?

	convenience init(_ params: SiteDetailViewModelConstructorParams) {
		let images = SiteImages.all
		self.init(
			siteIndex: params.siteIndex,
			imageSelections: images,
			siteImagePickerRelatedViews: params.relatedViews
		)
	}

	private convenience init(
		siteIndex: Index,
		imageSelections: [UIImage],
		siteImagePickerRelatedViews: SiteImagePickerDelegateRelatedViews
	) {
		let pickerDelegateProps = SiteImagePickerDelegateProperties(
			selectedSiteIndex: siteIndex,
			imageOptions: imageSelections,
			views: siteImagePickerRelatedViews
		)
		self.init(siteIndex: siteIndex, imagePickerProps: pickerDelegateProps)
	}

	private convenience init(
		siteIndex: Index, imagePickerProps: SiteImagePickerDelegateProperties
	) {
		let imagePickerDelegate = SiteImagePicker(props: imagePickerProps)
		self.init(siteIndex, imagePickerDelegate: imagePickerDelegate)
	}

	init(_ siteIndex: Index, imagePickerDelegate: SiteImagePicker) {
		self.siteIndex = siteIndex
		self.imagePickerDelegate = imagePickerDelegate
		super.init()
	}

	init(
		_ siteIndex: Index,
		imagePickerDelegate: SiteImagePicker,
		_ dependencies: DependenciesProtocol
	) {
		self.siteIndex = siteIndex
		self.imagePickerDelegate = imagePickerDelegate
		super.init(
			sdk: dependencies.sdk,
			tabs: dependencies.tabs,
			notifications: dependencies.notifications,
			alerts: dependencies.alerts,
			nav: dependencies.nav,
			badge: dependencies.badge
		)
	}

	// MARK: - Public

	var siteDetailViewControllerTitle: String { siteName }

	var siteName: SiteName { site.name }

	var sitesCount: Int { sdk?.sites.count ?? 0 }

	var siteNameSelections: [SiteName] { sdk?.sites.names ?? [] }

	var siteNamePickerStartIndex: Index {
		let startName = selections.selectedSiteName ?? siteName
		return siteNameSelections.firstIndex(of: startName) ?? 0
	}

	var siteImage: UIImage {
		guard let settings = sdk?.settings else { return UIImage() }
		let params = SiteImageDeterminationParameters(
			siteName: siteName, deliveryMethod: settings.deliveryMethod.value
		)
		return SiteImages[params]
	}

	@discardableResult func saveSiteImageChanges() -> UIImage? {
        guard let row = imagePickerDelegate?.selectedRow else { return nil }
		guard let image = createImageStruct(selectedRow: row) else { return nil }
		sdk?.sites.setImageId(at: row, to: image.name)
		return image.image
	}

	func handleSave(siteNameText: SiteName?, siteDetailViewController: UIViewController) {
		if let name = siteNameText {
			saveSiteNameChanges(siteName: name)
		}
		nav?.pop(source: siteDetailViewController)
	}

	func getSiteName(at index: Index) -> SiteName? {
		siteNameSelections.tryGet(at: index)
	}

	func getAttributedSiteName(at index: Index) -> NSAttributedString? {
		guard let siteRowName = getSiteName(at: index) else { return nil }
		let attributes = [NSAttributedString.Key.foregroundColor: PDColors[.Text] as Any]
		return NSAttributedString(string: siteRowName, attributes: attributes)
	}

	// MARK: - Private

	private func createImageStruct(selectedRow: Index) -> SiteImageStruct? {
		guard let settings = sdk?.settings else {
			return createImageStruct(
				selectedRow: selectedRow, method: DefaultSettings.DeliveryMethodValue
			)
		}
		let method = settings.deliveryMethod.value
		return createImageStruct(selectedRow: selectedRow, method: method)
	}

	private func createImageStruct(selectedRow: Index, method: DeliveryMethod) -> SiteImageStruct? {
		let images = SiteImages.All[method]
		guard let image = images.tryGet(at: selectedRow) else { return nil }
		let imageKey = SiteImages.getName(from: image)
		return SiteImageStruct(image: image, name: imageKey)
	}

	private func saveSiteNameChanges(siteName: SiteName) {
		guard let sites = sdk?.sites else { return }
		if siteIndex >= 0 && siteIndex < sites.count {
			sites.rename(at: siteIndex, to: siteName)
		} else if siteIndex == sites.count {
			sites.insertNew(name: siteName, onSuccess: nil)
		}
	}
}
