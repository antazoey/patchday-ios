//
//  TabReflective.swift
//  PatchDay
//
//  Created by Juliya Smith on 8/10/19.

import UIKit

public protocol TabReflective {

    /// The Hormones View Controller.
    var hormonesViewController: UIViewController? { get }

    /// The Pills View Controller.
    var pillsViewController: UIViewController? { get }

    /// The Sites View Controller.
    var sitesViewController: UIViewController? { get }

    /// Sets the Hormones and Pills tabs to their respective expired counts.
    func reflect()

    /// Sets the Hormones tab badge value to the total expired hormones.
    func reflectHormones()

    /// Sets the Pills tab badge value to the total expired pills.
    func reflectPills()
}
