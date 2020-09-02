//
//  SiteImageHistoryTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 6/6/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class SiteImageHistoryTests: XCTestCase {

    func testCurrentAndPush_whenNoHistory_returnsNil() {
        let history = SiteImageHistory(0)
        XCTAssertNil(history.current)
    }

    func testCurrentAndPush_whenPushedOnce_returnsImagePushed() {
        let history = SiteImageHistory(0)
        let image = UIImage()
        history.push(image)
        let actual = history.current
        let expected = image
        XCTAssertEqual(expected, actual)
    }

    func testCurrentAndPush_whenPushedMoreThanOnce_returnsLastImagePushed() {
        let history = SiteImageHistory(0)
        let firstImage = UIImage()
        let secondImage = UIImage()
        let lastImage = UIImage()
        history.push(firstImage)
        history.push(secondImage)
        history.push(lastImage)
        let actual = history.current
        let expected = lastImage
        XCTAssertEqual(expected, actual)
    }

    func testDifferentiate_whenNeverTaken_returnsEmpty() {
        let history = SiteImageHistory(0)
        let actual = history.differentiate()
        let expected = HormoneMutation.Empty
        XCTAssertEqual(expected, actual)
    }

    func testDifferentiate_whenLastEqualsPenultimate_returnsNone() {
        let history = SiteImageHistory(0)
        let image = UIImage()
        history.push(image)
        history.push(image)
        let actual = history.differentiate()
        let expected = HormoneMutation.None
        XCTAssertEqual(expected, actual)
    }

    func testDifferentiate_whenOnlyOneImagePushes_returnsAdd() {
        let history = SiteImageHistory(0)
        let image = UIImage()
        history.push(image)
        let actual = history.differentiate()
        let expected = HormoneMutation.Add
        XCTAssertEqual(expected, actual)
    }

    func testDifferentiate_whenLastImageDifferentThanPenultimate_returnsEdit() {
        let history = SiteImageHistory(0)
        let penultimate = SiteImages.arms
        let last = SiteImages.customPatch
        history.push(penultimate)
        history.push(last)
        let actual = history.differentiate()
        let expected = HormoneMutation.Edit
        XCTAssertEqual(expected, actual)
    }

    func testDifferentiate_whenLastPushIsNilAndPenultimateIsImage_returnsRemove() {
        let history = SiteImageHistory(0)
        let penultimate = SiteImages.arms
        let last: UIImage? = nil
        history.push(penultimate)
        history.push(last)
        let actual = history.differentiate()
        let expected = HormoneMutation.Remove
        XCTAssertEqual(expected, actual)
    }
}
