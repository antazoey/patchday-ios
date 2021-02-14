//
//  SiteDetailViewModelProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public protocol SiteDetailViewModelProtocol {
    var selections: SiteSelectionState { get set }
    var imagePickerDelegate: SiteImagePicker? { get }
    var siteDetailViewControllerTitle: String { get }
    var siteName: SiteName { get }
    var sitesCount: Int { get }
    var siteNameOptions: [SiteName] { get }
    var siteNamePickerStartIndex: Index { get }
    var siteImage: UIImage { get }
    func handleSave(siteDetailViewController: UIViewController)
    func handleIfUnsaved(_ viewController: UIViewController)
    func getSiteName(at index: Index) -> SiteName?
    func getAttributedSiteName(at index: Index) -> NSAttributedString?
}
