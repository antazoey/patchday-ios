//
//  HormoneCellViewModelTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 10/15/20.

import Foundation

import XCTest
import PDKit
import PDTest

@testable
import PatchDay

class HormoneCellViewModelTests: PDTestCase {

    func getMockSDK(_ hormoneArray: [Hormonal]?=nil) -> MockSDK {
        let sdk = MockSDK()
        let settings = MockSettings()
        settings.quantity = QuantityUD(4)
        let hormones = MockHormoneSchedule()
        hormones.all = hormoneArray ?? [MockHormone(), MockHormone(), MockHormone(), MockHormone()]
        sdk.hormones = hormones
        sdk.settings = settings
        return sdk
    }

    func testInit_whenCellIndexNegative_hasNilHormone() {
        let sdk = getMockSDK()
        let viewModel = HormoneCellViewModel(cellIndex: -4, sdk: sdk, isPad: false)
        XCTAssertNil(viewModel.hormone)
    }

    func testInit_whenCellIndexPastQuantity_hasNilHormone() {
        let sdk = getMockSDK()
        let viewModel = HormoneCellViewModel(cellIndex: 5, sdk: sdk, isPad: false)
        XCTAssertNil(viewModel.hormone)
    }

    func testHormone_whenCellIndexValid_ReturnsHormone() {
        let hormone = MockHormone()  // For index 1
        let hormones = [MockHormone(), hormone, MockHormone(), MockHormone()]
        let sdk = getMockSDK(hormones)
        let viewModel = HormoneCellViewModel(cellIndex: 1, sdk: sdk, isPad: false)
        XCTAssertEqual(hormone.id, viewModel.hormone!.id)
    }

    func testShouldShowHormone_whenNoHormoneAtIndex_returnsFalse() {
        let hormones: [Hormonal] = []
        let sdk = getMockSDK(hormones)
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        XCTAssertFalse(viewModel.shouldShowHormone)
    }

    func testShouldShowHormone_whenHormoneAtIndex_returnsTrue() {
        let hormones: [Hormonal] = [MockHormone()]
        let sdk = getMockSDK(hormones)
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        XCTAssert(viewModel.shouldShowHormone)
    }

    func testMoonIcon_whenNoHormoneIndex_returnsNil() {
        let hormones: [Hormonal] = []
        let sdk = getMockSDK(hormones)
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        XCTAssertNil(viewModel.moonIcon)
    }

    func testMoonIcon_whenHormoneExpiresOvernightAndIsNotExpired_returnsImage() {
        let hormone = MockHormone()
        hormone.isExpired = false
        hormone.expiresOvernight = true
        let sdk = getMockSDK([hormone])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        let expected = PDIcons.moonIcon
        let actual = viewModel.moonIcon
        XCTAssertEqual(expected, actual)
    }

    func testMoonIcon_whenHormoneExpiresOvernightAndIsExpired_returnsNil() {
        let hormone = MockHormone()
        hormone.isExpired = true
        hormone.expiresOvernight = true
        let sdk = getMockSDK([hormone])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        XCTAssertNil(viewModel.moonIcon)
    }

    func testMoonIcon_whenHormoneDoesNotExpireOverNight_returnsNil() {
        let hormone = MockHormone()
        hormone.isExpired = false
        hormone.expiresOvernight = false
        let sdk = getMockSDK([hormone])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        XCTAssertNil(viewModel.moonIcon)
    }

    func testCellId_returnsExpectedId() {
        let sdk = getMockSDK([])
        let viewModel = HormoneCellViewModel(cellIndex: 23, sdk: sdk, isPad: false)
        let expected = "HormoneCell_23"
        let actual = viewModel.cellId
        XCTAssertEqual(expected, actual)
    }

    func testBackgroundColor_whenIndexEven_returnsEvenCellColor() {
        let sdk = getMockSDK([])
        let viewModel = HormoneCellViewModel(cellIndex: 2, sdk: sdk, isPad: false)
        let expected = PDColors[.EvenCell]
        let actual = viewModel.backgroundColor
        XCTAssertEqual(expected, actual)
    }

    func testBackgroundColor_whenIndexOdd_returnsOddCellColor() {
        let sdk = getMockSDK([])
        let viewModel = HormoneCellViewModel(cellIndex: 3, sdk: sdk, isPad: false)
        let expected = PDColors[.OddCell]
        let actual = viewModel.backgroundColor
        XCTAssertEqual(expected, actual)
    }

    func testBadgeType_whenNoHormoneForIndex_returnsPatchesAndGelHormonesView() {
        let sdk = getMockSDK([])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        let expected = PDBadgeButtonType.forPatchesAndGelHormonesView
        let actual = viewModel.badgeType
        XCTAssertEqual(expected, actual)
    }

    func testBadgeType_whenInjections_returnsForInjectionsHormoneView() {
        let hormone = MockHormone()
        hormone.deliveryMethod = .Injections
        let sdk = getMockSDK([hormone])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        let expected = PDBadgeButtonType.forInjectionsHormonesView
        let actual = viewModel.badgeType
        XCTAssertEqual(expected, actual)
    }

    func testBadgeType_whenPatches_returnsPatchesAndGelHormonesView() {
        let hormone = MockHormone()
        hormone.deliveryMethod = .Patches
        let sdk = getMockSDK([hormone])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        let expected = PDBadgeButtonType.forPatchesAndGelHormonesView
        let actual = viewModel.badgeType
        XCTAssertEqual(expected, actual)
    }

    func testBadgeType_whenGel_returnsPatchesAndGelHormonesView() {
        let hormone = MockHormone()
        hormone.deliveryMethod = .Gel
        let sdk = getMockSDK([hormone])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        let expected = PDBadgeButtonType.forPatchesAndGelHormonesView
        let actual = viewModel.badgeType
        XCTAssertEqual(expected, actual)
    }

    func testBadgeValue_whenNoHormoneForIndex_returnsNil() {
        let sdk = getMockSDK([])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        XCTAssertNil(viewModel.badgeValue)
    }

    func testBadgeValue_whenHormoneIsPastNotificationTime_returnsExclamationMark() {
        let hormone = MockHormone()
        hormone.isPastNotificationTime = true
        let sdk = getMockSDK([hormone])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        let expected = "!"
        let actual = viewModel.badgeValue
        XCTAssertEqual(expected, actual)
    }

    func testBadgeValue_whenHormoneIsNotPastNotificationTime_returnsNil() {
        let hormone = MockHormone()
        hormone.isPastNotificationTime = false
        let sdk = getMockSDK([hormone])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        XCTAssertNil(viewModel.badgeValue)
    }

    func testDateString_whenNoHormoneForIndex_returnsNil() {
        let sdk = getMockSDK([])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        XCTAssertNil(viewModel.dateString)
    }

    func testDateString_whenHormoneHasNoExpiration_returnsNil() {
        let hormone = MockHormone()
        hormone.expiration = nil
        let sdk = getMockSDK([hormone])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        XCTAssertNil(viewModel.dateString)
    }

    func testDateString_whenHormoneHasDefaultDate_returnsNil() {
        let hormone = MockHormone()
        hormone.expiration = Date()
        hormone.date = DateFactory.createDefaultDate()
        let sdk = getMockSDK([hormone])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        XCTAssertNil(viewModel.dateString)
    }

    func testDateString_whenNonExpiredPatchHasValidDatesThatAreWithinAWeek_returnsNonExpiredDayString() {
        let hormone = MockHormone()
        let date = Date()
        let expirationDate = DateFactory.createDate(byAddingHours: 2, to: date)!
        hormone.expiration = expirationDate
        hormone.date = date
        hormone.deliveryMethod = .Patches
        hormone.isExpired = false
        let sdk = getMockSDK([hormone])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        let expected = "Expiration: \(PDDateFormatter.formatDay(expirationDate))"
        let actual = viewModel.dateString
        XCTAssertEqual(expected, actual)
    }

    func testDateString_whenExpiredPatchHasValidDatesThatAreWithinAWeek_returnsExpiredDayString() {
        let hormone = MockHormone()
        let date = Date()
        let expirationDate = DateFactory.createDate(byAddingHours: -2, to: date)!
        hormone.expiration = expirationDate
        hormone.date = date
        hormone.deliveryMethod = .Patches
        hormone.isExpired = true
        let sdk = getMockSDK([hormone])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        let expected = "Expiration: \(PDDateFormatter.formatDay(expirationDate))"
        let actual = viewModel.dateString
        XCTAssertEqual(expected, actual)
    }

    func testDateString_whenNonExpiredPatchHasValidDatesThatAreNotWithinAWeek_returnsNonExpiredDateString() {
        let hormone = MockHormone()
        let date = Date()
        let expirationDate = DateFactory.createDate(byAddingHours: -Hours.IN_TWO_WEEKS, to: date)!
        hormone.expiration = expirationDate
        hormone.date = date
        hormone.deliveryMethod = .Patches
        hormone.isExpired = false
        let sdk = getMockSDK([hormone])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        let expected = "Expiration: \(PDDateFormatter.formatDate(expirationDate))"
        let actual = viewModel.dateString
        XCTAssertEqual(expected, actual)
    }

    func testDateString_whenExpiredPatchHasValidDatesThatAreNotWithinAWeek_returnsExpiredDateString() {
        let hormone = MockHormone()
        let date = Date()
        let expirationDate = DateFactory.createDate(byAddingHours: Hours.IN_TWO_WEEKS, to: date)!
        hormone.expiration = expirationDate
        hormone.date = date
        hormone.deliveryMethod = .Patches
        hormone.isExpired = true
        let sdk = getMockSDK([hormone])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        let expected = "Expiration: \(PDDateFormatter.formatDate(expirationDate))"
        let actual = viewModel.dateString
        XCTAssertEqual(expected, actual)
    }

    func testDateString_whenInjectionHasValidDates_returnsExpectedDayString() {
        let hormone = MockHormone()
        let date = Date()
        let expirationDate = DateFactory.createDate(byAddingHours: 2, to: date)!
        hormone.expiration = expirationDate
        hormone.date = date
        hormone.deliveryMethod = .Injections
        let sdk = getMockSDK([hormone])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        let expected = "Next: \(PDDateFormatter.formatDay(expirationDate))"
        let actual = viewModel.dateString
        XCTAssertEqual(expected, actual)
    }

    func testDateString_whenGelHasValidDates_returnsExpectedDayString() {
        let hormone = MockHormone()
        let date = Date()
        let expirationDate = DateFactory.createDate(byAddingHours: 2, to: date)!
        hormone.expiration = expirationDate
        hormone.date = date
        hormone.deliveryMethod = .Gel
        let sdk = getMockSDK([hormone])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        let expected = "Next: \(PDDateFormatter.formatDay(expirationDate))"
        let actual = viewModel.dateString
        XCTAssertEqual(expected, actual)
    }

    func testDateFont_whenIsPad_returnsExpectedValue() {
        let sdk = getMockSDK([])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: true)
        let expected = UIFont.systemFont(ofSize: HORMONE_CELL_PAD_FONT_SIZE)
        let actual = viewModel.dateFont
        XCTAssertEqual(expected, actual)
    }

    func testDateFont_whenIsPhone_returnsExpectedValue() {
        let sdk = getMockSDK([])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        let expected = UIFont.systemFont(ofSize: HORMONE_CELL_PHONE_FONT_SIZE)
        let actual = viewModel.dateFont
        XCTAssertEqual(expected, actual)
    }

    func testDateLabelColor_whenNoHormoneForIndex_returnsTextColor() {
        let sdk = getMockSDK([])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        let expected = PDColors[.Text]
        let actual = viewModel.dateLabelColor
        XCTAssertEqual(expected, actual)
    }

    func testDateLabelColor_whenHormoneIsPastNotificationTime_returnsRed() {
        let hormone = MockHormone()
        hormone.isPastNotificationTime = true
        let sdk = getMockSDK([hormone])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        let expected = UIColor.red
        let actual = viewModel.dateLabelColor
        XCTAssertEqual(expected, actual)
    }

    func testDateLabelColor_whenHormoneIsNotPastNotificationTime_returnsTextColor() {
        let hormone = MockHormone()
        hormone.isPastNotificationTime = false
        let sdk = getMockSDK([hormone])
        let viewModel = HormoneCellViewModel(cellIndex: 0, sdk: sdk, isPad: false)
        let expected = PDColors[.Text]
        let actual = viewModel.dateLabelColor
        XCTAssertEqual(expected, actual)
    }
}
