//
//  ArrayExtension.swift
//  PDKit
//
//  Created by Juliya Smith on 10/29/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public extension Array {

	func tryGet(at index: Index) -> Element? {
		guard index < count && index >= 0 else { return nil }
		return self[index]
	}
}

public extension Array where Element: Equatable {

	func tryGetIndex(item: Element?) -> Index? {
		guard let item = item else { return nil }
		return firstIndex(of: item)
	}
}

// https://stackoverflow.com/questions/39677330/how-does-string-substring-work-in-swift
public extension String {
	func index(from: Int) -> Index {
		self.index(startIndex, offsetBy: from)
	}

	func substring(from: Int) -> String {
		let fromIndex = index(from: from)
		return String(self[fromIndex...])
	}

	func substring(to: Int) -> String {
		let toIndex = index(from: to)
		return String(self[..<toIndex])
	}

	func substring(with r: Range<Int>) -> String {
		let startIndex = index(from: r.lowerBound)
		let endIndex = index(from: r.upperBound)
		return String(self[startIndex..<endIndex])
	}
}

public extension UIViewController {

	func getStyle() -> UIUserInterfaceStyle {
		self.traitCollection.userInterfaceStyle
	}
}
