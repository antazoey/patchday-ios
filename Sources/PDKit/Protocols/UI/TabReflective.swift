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

    /// Set the Hormones and Pills tabs to their respective expired counts.
    func reflect()

    /// Set the Hormones tab badge value to the total expired hormones.
    func reflectHormones()

    /// Set the Pills tab badge value to the total expired pills.
    func reflectPills()

    /// Remove the expired pill tab badge.
    func clearPills()
}
