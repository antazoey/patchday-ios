//
//  PDActionStrings.swift
//  PDKit
//
//  Created by Juliya Smith on 6/16/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public class PDActionStrings {

    private static let c1 = "Button title.  Could you keep it short?"
    private static let c2 = "Notification action. Used all over app, so please keep it short."
    private static let c3 = "Title for button, not too much room left for a really long word."
    private static let c4 = "Button title.  Room is fair."
    private static let c5 = "Button title.  Could you keep it short?"
    private static let c6 = "Alert action. Room is not an issue."
    private static let c7 = "Nav bar item title.  Could you keep it short?"

    public static let done = { return NSLocalizedString("Done", comment: c1) }()

    public static let delete = { return NSLocalizedString("Delete", comment: c1) }()

    public static let take = { return NSLocalizedString("Take", comment: c2) }()

    public static let taken = { return NSLocalizedString("Taken", comment: c3) }()

    public static let save = { return NSLocalizedString("Save", comment: c4) }()

    public static let undo = { return NSLocalizedString("undo", comment: c4) }()

    public static let autofill = { return NSLocalizedString("Autofill", comment: c4) }()

    public static let type = { return NSLocalizedString("Type", comment: c5) }()

    public static let select = { return NSLocalizedString("Select", comment: c5) }()

    public static let dismiss = { return NSLocalizedString("Dismiss", comment: c5) }()

    public static let accept = { return NSLocalizedString("Accept", comment: c6) }()

    public static let cont = { return NSLocalizedString("Continue", comment: c6) }()

    public static let decline = { return NSLocalizedString("Decline", comment: c6) }()

    public static let yes = { return NSLocalizedString("Yes", comment: c6) }()

    public static let no = { return NSLocalizedString("No", comment: c6) }()

    public static let edit = { return NSLocalizedString("Edit", comment: c7) }()

    public static let reset = { return NSLocalizedString("Reset", comment: c7) }()
}
