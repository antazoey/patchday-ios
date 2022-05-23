//
//  SiteDetailViewModelProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.

import Foundation

public protocol SiteDetailViewModelProtocol {
    var selections: SiteSelectionState { get set }
    /// The current selections of the site before save.

    var imagePicker: SiteImagePicker? { get }
    /// The image picker delegate for changing a site's image.

    var siteName: SiteName? { get }
    /// The name of the site.

    var sitesCount: Int { get }
    /// The total number of sites there are in the `SiteSchedule`.

    var siteNameOptions: [SiteName] { get }
    /// Existing site names to select when editting a site.

    var siteNamePickerStartIndex: Index { get }
    /// The index to start the site name picker upon initializaiton.

    var siteImage: UIImage { get }
    /// The current site image for the site.

    func selectSite(_ siteName: String)
    /// Select a site name and image.

    func handleSave(siteDetailViewController: UIViewController)
    /// Apply changes to the site.

    func handleIfUnsaved(_ viewController: UIViewController)
    /// Prompt about unsaved changes for a chance to save.

    func getSiteName(at index: Index) -> SiteName?
    /// Get the site name at the given index.

    func getAttributedSiteName(at index: Index) -> NSAttributedString?
    /// Get the site name at the given index with colors and formatting.
}
