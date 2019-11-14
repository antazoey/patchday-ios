//
//  ActionStrings.swift
//  PDKit
//
//  Created by Juliya Smith on 6/16/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public class ActionStrings {

    private static let c1 = "Button title.  Could you keep it short?"
    private static let c2 = "Notification action. Used all over app, so please keep it short."
    private static let c3 = "Title for button, not too much room left for a really long word."
    private static let c4 = "Button title.  Room is fair."
    private static let c5 = "Button title.  Could you keep it short?"
    private static let c6 = "Alert action. Room is not an issue."
    private static let c7 = "Nav bar item title.  Could you keep it short?"

    public static let done = { NSLocalizedString("Done", comment: c1) }()
    public static let delete = { NSLocalizedString("Delete", comment: c1) }()
    public static let take = { NSLocalizedString("Take", comment: c2) }()
    public static let taken = { NSLocalizedString("Taken", comment: c3) }()
    public static let save = { NSLocalizedString("Save", comment: c4) }()
    public static let undo = { NSLocalizedString("undo", comment: c4) }()
    public static let autofill = { NSLocalizedString("Autofill", comment: c4) }()
    public static let type = { NSLocalizedString("Type", comment: c5) }()
    public static let select = { NSLocalizedString("Select", comment: c5) }()
    public static let dismiss = { NSLocalizedString("Dismiss", comment: c5) }()
    public static let accept = { NSLocalizedString("Accept", comment: c6) }()
    public static let cont = { NSLocalizedString("Continue", comment: c6) }()
    public static let decline = { NSLocalizedString("Decline", comment: c6) }()
    public static let yes = { NSLocalizedString("Yes", comment: c6) }()
    public static let no = { NSLocalizedString("No", comment: c6) }()
    public static let edit = { NSLocalizedString("Edit", comment: c7) }()
    public static let reset = { NSLocalizedString("Reset", comment: c7) }()
}
