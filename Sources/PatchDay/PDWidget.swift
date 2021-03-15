//
//  PDWidget.swift
//  PDKit
//
//  Created by Juliya Smith on 3/14/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit
import WidgetKit

class PDWidget: PDWidgetProtocol {
    func set() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
