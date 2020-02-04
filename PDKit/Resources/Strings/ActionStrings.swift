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

    public static let Done = { NSLocalizedString("Done", comment: c1) }()
    public static let Delete = { NSLocalizedString("Delete", comment: c1) }()
    public static let Take = { NSLocalizedString("Take", comment: c2) }()
    public static let Taken = { NSLocalizedString("Taken", comment: c3) }()
    public static let Save = { NSLocalizedString("Save", comment: c4) }()
    public static let Undo = { NSLocalizedString("undo", comment: c4) }()
    public static let Autofill = { NSLocalizedString("Autofill", comment: c4) }()
    public static let _Type = { NSLocalizedString("Type", comment: c5) }()
    public static let Select = { NSLocalizedString("Select", comment: c5) }()
    public static let Dismiss = { NSLocalizedString("Dismiss", comment: c5) }()
    public static let Accept = { NSLocalizedString("Accept", comment: c6) }()
    public static let Continue = { NSLocalizedString("Continue", comment: c6) }()
    public static let Decline = { NSLocalizedString("Decline", comment: c6) }()
    public static let Yes = { NSLocalizedString("Yes", comment: c6) }()
    public static let No = { NSLocalizedString("No", comment: c6) }()
    public static let Edit = { NSLocalizedString("Edit", comment: c7) }()
    public static let Reset = { NSLocalizedString("Reset", comment: c7) }()
}
