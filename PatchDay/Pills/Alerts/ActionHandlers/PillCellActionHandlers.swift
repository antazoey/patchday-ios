//
//  PillCellActionHandlers.swift
//  PatchDay
//
//  Created by Juliya Smith on 2/19/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class PillCellActionHandlers: PillCellActionHandling {

	private let goToDetailsAction: () -> ()
	private let takePillAction: () -> ()

	init(goToDetails: @escaping () -> (), takePill: @escaping () -> ()) {
		self.goToDetailsAction = goToDetails
		self.takePillAction = takePill
	}

	public func goToDetails() {
		goToDetailsAction()
	}

	public func takePill() {
		takePillAction()
	}
}
