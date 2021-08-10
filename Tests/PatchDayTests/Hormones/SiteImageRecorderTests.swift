//
//  SiteImageRecorderTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 6/6/20.

import XCTest
import PDKit
import PDTest

@testable
import PatchDay

class SiteImageRecorderTests: PDTestCase {

    func testCurrentAndPush_whenNoHistory_returnsNil() {
        let recorder = SiteImageRecorder(0)
        XCTAssertNil(recorder.current)
    }

    func testCurrentAndPush_whenPushedOnce_returnsImagePushed() {
        let recorder = SiteImageRecorder(0)
        let image = UIImage()
        recorder.push(image)
        let actual = recorder.current
        let expected = image
        XCTAssertEqual(expected, actual)
    }

    func testCurrentAndPush_whenPushedMoreThanOnce_returnsLastImagePushed() {
        let recorder = SiteImageRecorder(0)
        let firstImage = UIImage()
        let secondImage = UIImage()
        let lastImage = UIImage()
        recorder.push(firstImage)
        recorder.push(secondImage)
        recorder.push(lastImage)
        let actual = recorder.current
        let expected = lastImage
        XCTAssertEqual(expected, actual)
    }

    func testDifferentiate_whenNeverTaken_returnsEmpty() {
        let recorder = SiteImageRecorder(0)
        let actual = recorder.differentiate()
        let expected = HormoneMutation.Empty
        XCTAssertEqual(expected, actual)
    }

    func testDifferentiate_whenLastEqualsPenultimate_returnsNone() {
        let recorder = SiteImageRecorder(0)
        let image = UIImage()
        recorder.push(image)
        recorder.push(image)
        let actual = recorder.differentiate()
        let expected = HormoneMutation.None
        XCTAssertEqual(expected, actual)
    }

    func testDifferentiate_whenOnlyOneImagePushes_returnsAdd() {
        let recorder = SiteImageRecorder(0)
        let image = UIImage()
        recorder.push(image)
        let actual = recorder.differentiate()
        let expected = HormoneMutation.Add
        XCTAssertEqual(expected, actual)
    }

    func testDifferentiate_whenLastImageDifferentThanPenultimate_returnsEdit() {
        let recorder = SiteImageRecorder(0)
        let penultimate = SiteImages.arms
        let last = SiteImages.customPatch
        recorder.push(penultimate)
        recorder.push(last)
        let actual = recorder.differentiate()
        let expected = HormoneMutation.Edit
        XCTAssertEqual(expected, actual)
    }

    func testDifferentiate_whenLastPushIsNilAndPenultimateIsImage_returnsRemove() {
        let recorder = SiteImageRecorder(0)
        let penultimate = SiteImages.arms
        let last: UIImage? = nil
        recorder.push(penultimate)
        recorder.push(last)
        let actual = recorder.differentiate()
        let expected = HormoneMutation.Remove
        XCTAssertEqual(expected, actual)
    }
}
