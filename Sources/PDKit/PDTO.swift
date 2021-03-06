//
//  PDTO.swift
//  PDKit
//
//  Created by Juliya Smith on 4/26/20.

import Foundation

public struct PillDueDateFinderParams {
    public var timesTakenToday: Int
    public var timesaday: Int
    public var times: [Time]

    public init(_ timesTakenToday: Int, _ timesaday: Int, _ times: [Time]) {
        self.timesTakenToday = timesTakenToday
        self.timesaday = timesaday
        self.times = times
    }
}

public class SiteImageDeterminationParameters {

    public var imageId: SiteName?
    public var deliveryMethod: DeliveryMethod

    public init(imageId: SiteName, deliveryMethod: DeliveryMethod) {
        self.imageId = imageId
        self.deliveryMethod = deliveryMethod
    }

    public init(hormone: Hormonal?) {
        guard let hormone = hormone else {
            self.imageId = nil
            self.deliveryMethod = DefaultSettings.DeliveryMethodValue
            return
        }
        self.imageId = hormone.hasSite ? hormone.siteImageId : nil

        // If siteImageId is empty string somehow, use site name directly.
        if self.imageId == "" {
            self.imageId = hormone.siteName
        }

        // If still empty string (from site name), use default string for new sites.
        if self.imageId == "" {
            self.imageId = SiteStrings.NewSite
        }
        self.deliveryMethod = hormone.deliveryMethod
    }

    public init(deliveryMethod: DeliveryMethod) {
        self.deliveryMethod = deliveryMethod
    }
}

public struct SiteStruct {
    public var id: UUID
    public var hormoneRelationshipIds: [UUID]?
    public var imageIdentifier: String?
    public var name: String?
    public var order: Int

    public init(_ id: UUID) {
        self.id = id
        self.hormoneRelationshipIds = nil
        self.imageIdentifier = nil
        self.name = nil
        self.order = -1
    }

    public init(
        _ id: UUID,
        _ hormoneRelationship: [UUID]?,
        _ imageIdentifier: String?,
        _ name: String?,
        _ order: Int
    ) {
        self.id = id
        self.hormoneRelationshipIds = hormoneRelationship
        self.imageIdentifier = imageIdentifier
        self.name = name
        self.order = order
    }
}

public struct HormoneStruct {
    public var siteRelationshipId: UUID?
    public var id: UUID
    public var siteName: SiteName?
    public var siteImageId: SiteName?
    public var date: Date?
    public var siteNameBackUp: String?

    public init(_ id: UUID) {
        self.siteRelationshipId = nil
        self.id = id
        self.siteName = nil
        self.siteImageId = nil
        self.date = nil
        self.siteNameBackUp = nil
    }

    public init(
        _ id: UUID,
        _ siteRelationshipId: UUID?,
        _ siteName: SiteName?,
        _ siteImageId: SiteName?,
        _ date: Date?,
        _ siteNameBackUp: String?
    ) {
        self.id = id
        self.siteRelationshipId = siteRelationshipId
        self.siteName = siteName
        self.siteImageId = siteImageId
        self.date = date
        self.siteNameBackUp = siteNameBackUp
    }
}

public struct PillStruct {
    public var id: UUID
    public var attributes: PillAttributes

    public init(_ id: UUID, _ attributes: PillAttributes) {
        self.id = id
        self.attributes = attributes
    }
}

public struct SiteCellProperties {
    public init(row: Index) {
        self.row = row
    }
    public var row: Index
    public var site: Bodily?
    public var totalSiteCount = 0
    public var nextSiteIndex = 0
}

public struct BarItemInitializationProperties {
    public init(
        sitesViewController: UIViewController,
        isEditing: Bool,
        oppositeActionTitle: String,
        reset: Selector,
        insert: Selector
    ) {
        self.sitesViewController = sitesViewController
        self.isEditing = isEditing
        self.oppositeActionTitle = oppositeActionTitle
        self.reset = reset
        self.insert = insert
    }
    public var sitesViewController: UIViewController
    public var isEditing: Bool
    public var oppositeActionTitle: String
    public var reset: Selector
    public var insert: Selector
}

public struct PillCellConfigurationParameters {
    public init(pill: Swallowable, index: Index) {
        self.pill = pill
        self.index = index
    }
    public var pill: Swallowable
    public var index: Index
}

public struct HormoneSelectionState {
    public init() {}
    public var site: Bodily?
    public var siteName: SiteName?
    public var date: Date?
    public var siteIndex: Index { site?.order ?? -1 }

    public var hasSelections: Bool {
        let dateSelected = date != nil && date != DateFactory.createDefaultDate()
        let siteSelected = (site != nil && siteIndex != -1) || siteName != nil
        return dateSelected || siteSelected
    }
}

public struct SiteImagePickerProperties {
    public init(
        selectedSiteIndex: Index?,
        imageChoices: [UIImage],
        views: SiteImagePickerRelatedViews?,
        selectedImageIndex: Index?
    ) {
        self.selectedSiteIndex = selectedSiteIndex
        self.imageChoices = imageChoices
        self.views = views
        self.selectedImageIndex = selectedImageIndex
    }
    public var selectedSiteIndex: Index?
    public var imageChoices: [UIImage] = []
    public var views: SiteImagePickerRelatedViews?
    public var selectedImageIndex: Index?
}

public struct SiteImagePickerRelatedViews {
    public init(
        getPicker: @escaping () -> UIPickerView,
        getImageView: @escaping () -> UIImageView,
        getSaveButton: @escaping () -> UIBarButtonItem) {
        self.getPicker = getPicker
        self.getImageView = getImageView
        self.getSaveButton = getSaveButton
    }
    public var getPicker: () -> UIPickerView
    public var getImageView: () -> UIImageView
    public var getSaveButton: () -> UIBarButtonItem
}

public struct SiteDetailViewModelConstructorParams {
    public var siteIndex: Index
    public var imageSelectionParams: SiteImageDeterminationParameters
    public var relatedViews: SiteImagePickerRelatedViews
    public var deliveryMethod: DeliveryMethod

    public init(
        _ siteIndex: Index,
        _ imageParams: SiteImageDeterminationParameters,
        _ relateViews: SiteImagePickerRelatedViews
    ) {
        self.siteIndex = siteIndex
        self.imageSelectionParams = imageParams
        self.relatedViews = relateViews
        self.deliveryMethod = imageParams.deliveryMethod
    }
}

public struct SiteImageStruct {
    public init(image: UIImage, name: SiteName) {
        self.image = image
        self.name = name
    }
    public let image: UIImage
    public let name: SiteName
}

public struct SiteSelectionState {
    public init() {}
    public var selectedSiteName: SiteName?
    // Image propety is not tracked here - see SiteImagePicker.swift

    public var hasSelections: Bool {
        selectedSiteName != nil
    }
}
