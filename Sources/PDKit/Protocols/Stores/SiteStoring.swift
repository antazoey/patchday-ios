//
//  SiteStoring.swift
//  PDKit
//
//  Created by Juliya Smith on 1/9/20.
//  
//

import Foundation

public protocol SiteStoring: PDObjectStoring {

    /// Get the count of stored sites.
    var siteCount: Int { get }

    /// Fetches all the sites from storage.
    func getStoredSites() -> [Bodily]

    /// Creates a new stored site and returns it.
    func createNewSite(doSave: Bool) -> Bodily?

    /// Gets the related hormones to site with the given ID.
    func getRelatedHormones(_ siteId: UUID) -> [HormoneStruct]

    /// Deletes the given site from storage.
    func delete(_ site: Bodily)

    /// Pushes the given sites to the managed context to stage changes for saving and optionally writes-through.
    func pushLocalChangesToManagedContext(_ sites: [Bodily], doSave: Bool)
}
