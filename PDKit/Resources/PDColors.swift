//
//  PDColors.swift
//  PDKit
//
//  Created by Juliya Smith on 5/26/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit

public enum ColorKey: String {
	case Border
	case Button
	case EvenCell
	case NewItem
	case OddCell
	case Purple
	case Selected
	case Text
	case Unselected
}

public class PDColors: NSObject {

	override public var description: String {
		"Read-only PatchDay Color class."
	}

	public static subscript(_ key: ColorKey) -> UIColor {
		switch key {
			case .Border: return border
			case .Button: return button
			case .EvenCell: return evenCell
			case .NewItem: return newItem
			case .OddCell: return oddCell
			case .Purple: return purple
			case .Selected: return selected
			case .Text: return text
			case .Unselected: return unselected
		}
	}

	public class Cell {
		public static subscript(index: Index) -> UIColor {
			index % 2 == 0 ? PDColors[.EvenCell] : PDColors[.OddCell]
		}
	}

	private static var border: UIColor { UIColor(named: "Border") ?? UIColor.gray }
	private static var button: UIColor { UIColor(named: "Button") ?? UIColor.blue }
	private static var evenCell: UIColor { UIColor(named: "Even Cell") ?? UIColor.white }
	private static var newItem: UIColor { UIColor(named: "New Item") ?? UIColor.green }
	private static var oddCell: UIColor { UIColor(named: "Odd Cell") ?? UIColor.white }
	private static var purple: UIColor { UIColor(named: "Purple") ?? UIColor.purple }
	private static var selected: UIColor { UIColor(named: "Selected") ?? UIColor.gray }
	private static var text: UIColor { UIColor(named: "Text") ?? UIColor.black }
	private static var unselected: UIColor { UIColor(named: "Unselected") ?? UIColor.white }
}
