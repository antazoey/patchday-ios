//
//  SiteScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol SiteScheduling: Schedule, Sorting, Deleting, Resetting {

	/// All the sites.
	var all: [Bodily] { get }

	/// The currently next suggested site for applying a hormone.
	var suggested: Bodily? { get }

	/// The index of suggested site or -1 if there are no sites.
	var nextIndex: Index { get }

	/// All names.
	var names: [SiteName] { get }

	/// If the sites use the default scheme for the given delivery method.
	var isDefault: Bool { get }

	/// Force reload context from database.
	func reloadContext()

	/// Inserts a new site into the schedule.
	@discardableResult
	func insertNew(name: String, onSuccess: (() -> Void)?) -> Bodily?

	/// Returns the site at the given index.
	subscript(index: Index) -> Bodily? { get }

	/// Returns the site for the given ID.
	subscript(id: UUID) -> Bodily? { get }

	/// Changes the name of a site.
	func rename(at index: Index, to name: SiteName)

	/// Changes the order of the site at the given index and adjusts the order of the other sites.
	func reorder(at index: Index, to newOrder: Int)

	/// Sets the image ID of the site at the given index.
	func setImageId(at index: Index, to newId: String)

	/// Returns the first first index of the given site.
	func indexOf(_ site: Bodily) -> Index?
}
