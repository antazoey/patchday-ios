//
//  HormoneStoring.swift
//  PDKit
//
//  Created by Juliya Smith on 1/9/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

public protocol HormoneStoring: PDObjectStoring {

	/// Fetches all the hormones from storage.
	func getStoredHormones(_ settings: UserDefaultsReading) -> [Hormonal]

	/// Creates a new stored hormone and returns it.
	func createNewHormone(_ settings: UserDefaultsReading) -> Hormonal?

	/// Deletes the given hormone from storage.
	func delete(_ hormone: Hormonal)

	/// Pushes the given hormones to the managed context to stage changes for saving and optionally writes-through.
	func pushLocalChangesToManagedContext(_ hormones: [Hormonal], doSave: Bool)
}
