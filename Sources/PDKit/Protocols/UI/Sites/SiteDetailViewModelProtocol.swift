//
//  SiteDetailViewModelProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.

import Foundation

public protocol SiteDetailViewModelProtocol {
    /// The current selections of the site before save.
    var selections: SiteSelectionState { get set }

    /// The image picker delegate for changing a site's image.
    var imagePicker: SiteImagePicker? { get }

    /// The name of the site.
    var siteName: SiteName? { get }

    /// The total number of sites there are in the `SiteSchedule`.
    var sitesCount: Int { get }

    /// Existing site names to select when editting a site.
    var siteNameOptions: [SiteName] { get }

    /// The index to start the site name picker upon initializaiton.
    var siteNamePickerStartIndex: Index { get }

    /// The current site image for the site.
    var siteImage: UIImage { get }

    /// Select a site name and image.
    func selectSite(_ siteName: String)

    /// Apply changes to the site.
    func handleSave(siteDetailViewController: UIViewController)

    /// Prompt about unsaved changes for a chance to save.
    func handleIfUnsaved(_ viewController: UIViewController)

    /// Get the site name at the given index.
    func getSiteName(at index: Index) -> SiteName?

    /// Get the site name at the given index with colors and formatting.
    func getAttributedSiteName(at index: Index) -> NSAttributedString?
}
