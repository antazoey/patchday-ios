//
// Created by Juliya Smith on 11/29/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class PillsTable: TableViewWrapper<PillCell> {

	private let pills: PillScheduling?

	init(_ table: UITableView, pills: PillScheduling?) {
		self.pills = pills
		super.init(table, primaryCellReuseId: CellReuseIds.Pill)
		applyTheme()
		table.allowsSelectionDuringEditing = true
	}

	subscript(index: Index) -> PillCell {
		guard let pill = pills?[index] else { return PillCell() }
		let params = PillCellConfigurationParameters(pill: pill, index: index)
		return dequeueCell()?.configure(params) ?? PillCell()
	}

	func deleteCell(at indexPath: IndexPath, pillsCount: Int) {
		table.deleteRows(at: [indexPath], with: .fade)
		let start = indexPath.row
		let count = pillsCount
		let end = count - 1
		if start <= end {
			for i in start...end {
				self[i].loadBackground()
			}
		}
		table.reloadData()
	}

	private func applyTheme() {
		table.backgroundColor = UIColor.systemBackground
		table.separatorColor = PDColors[.Border]
	}
}
