//
//  SettingsPickerIndexing.swift
//  PDKit
//
//  Created by Juliya Smith on 5/16/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public protocol SettingsPickerIndexing {

    /// The index to open the delivery method picker at.
    var deliveryMethodStartIndex: Index { get }

    /// The index to open the quantity picker at.
    var quantityStartIndex: Index { get }

    /// The index to open the expiration interval picker at.
    var expirationIntervalStartIndex: Index { get }

    /// The index to open the X-Days picker at.
    var xDaysStartIndex: Index { get }
}
