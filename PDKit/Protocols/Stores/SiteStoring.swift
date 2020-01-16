//
//  SiteStoring.swift
//  PDKit
//
//  Created by Juliya Smith on 1/9/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation


public protocol SiteStoring {
    
    /// Fetches all the sites from storage.
    func getStoredSites(expiration: ExpirationIntervalUD, method: DeliveryMethod) -> [Bodily]
    
    /// Creates a new stored site and returns it.
    func createNewSite(expiration: ExpirationIntervalUD, method: DeliveryMethod, doSave: Bool) -> Bodily?

    /// Deletes the given site from storage.
    func delete(_ site: Bodily)

    /// Pushes the given sites to the managed context to stage changes for saving.
    func pushLocalChangesToBeSaved(_ sites: [Bodily])
    
    /// Gets the related hormones to site with the given ID.
    func getSiteHormones(siteId: UUID) -> [HormoneStruct]
}
