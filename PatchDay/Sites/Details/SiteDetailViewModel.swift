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

    var imagePickerDelegate: SiteImagePicker?

    convenience init(_ params: SiteDetailViewModelConstructorParams) {
        let imageChoices = SiteImages.All[params.deliveryMethod]
        let image = SiteImages[params.imageSelectionParams]
        let imageIndex = imageChoices.firstIndex(where: { $0 == image })
        let pickerDelegateProps = SiteImagePickerDelegateProperties(
            selectedSiteIndex: params.siteIndex,
            imageChoices: imageChoices,
            views: params.relatedViews,
            selectedImageIndex: imageIndex
        )
        self.init(siteIndex: params.siteIndex, imagePickerProps: pickerDelegateProps)
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
        _ imagePickerDelegate: SiteImagePicker,
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

    var siteNameOptions: [SiteName] { sdk?.sites.names ?? [] }

    var siteNamePickerStartIndex: Index {
        let startName = selections.selectedSiteName ?? siteName
        return siteNameOptions.firstIndex(of: startName) ?? 0
    }

    var siteImage: UIImage {
        guard let settings = sdk?.settings else { return UIImage() }
        let key = site.imageId
        let params = SiteImageDeterminationParameters(
            imageId: key, deliveryMethod: settings.deliveryMethod.value
        )
        return SiteImages[params]
    }

    func handleSave(siteDetailViewController: UIViewController) {
        if let name = selections.selectedSiteName {
            saveSiteNameChanges(siteName: name)
        }
        saveSiteImageChanges()
        nav?.pop(source: siteDetailViewController)
        selections = SiteSelectionState()
    }

    func handleIfUnsaved(_ viewController: UIViewController) {
        let save: () -> Void = {
            self.handleSave(siteDetailViewController: viewController)
        }
        let discard: () -> Void = {
            self.nav?.pop(source: viewController)
            // Delete site if it was new.
            guard self.site.name == SiteStrings.NewSite else { return }
            guard let sdk = self.sdk else { return }
            sdk.sites.delete(at: self.siteIndex)
        }
        if hasSelections || site.name == SiteStrings.NewSite {
            self.alerts?.createUnsavedAlert(
	            viewController,
	            saveAndContinueHandler: save,
	            discardHandler: discard
            ).present()
        } else {
            self.nav?.pop(source: viewController)
        }
    }

    func getSiteName(at index: Index) -> SiteName? {
        siteNameOptions.tryGet(at: index)
    }

    func getAttributedSiteName(at index: Index) -> NSAttributedString? {
        guard let siteRowName = getSiteName(at: index) else { return nil }
        let attributes = [NSAttributedString.Key.foregroundColor: PDColors[.Text] as Any]
        return NSAttributedString(string: siteRowName, attributes: attributes)
    }

    // MARK: - Private

    private func saveSiteNameChanges(siteName: SiteName) {
        guard let sites = sdk?.sites else { return }
        if siteIndex >= 0 && siteIndex < sites.count {
            sites.rename(at: siteIndex, to: siteName)
        } else if siteIndex == sites.count {
            sites.insertNew(name: siteName, onSuccess: nil)
        }
    }

    private func saveSiteImageChanges() {
        guard let row = imagePickerDelegate?.selectedRow else { return }
        guard let image = createImageStruct(selectedRow: row) else { return }
        sdk?.sites.setImageId(at: siteIndex, to: image.name)
    }

    private func createImageStruct(selectedRow: Index) -> SiteImageStruct? {
        let images = SiteImages.all
        guard let image = images.tryGet(at: selectedRow) else { return nil }
        let imageKey = SiteImages.getName(from: image)
        return SiteImageStruct(image: image, name: imageKey)
    }

    private var hasSelections: Bool {
        selections.hasSelections || (imagePickerDelegate?.didSelectImage ?? false)
    }
}
