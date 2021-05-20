//
//  SiteImageHistory.swift
//  PatchDay
//
//  Created by Juliya Smith on 3/28/20.

import UIKit
import PDKit

class SiteImageRecorder: NSObject, SiteImageRecording {

    private var images: [UIImage?] = [nil, nil]
    var row: Index

    init(_ row: Index, _ image: UIImage? = nil) {
        self.row = row
        super.init()
        self.push(image)
    }

    var current: UIImage? { images.tryGet(at: 1) ?? nil }

    @discardableResult
    func push(_ image: UIImage?) -> SiteImageRecording {
        images[0] = images.tryGet(at: 1) ?? nil
        images[1] = image
        return self
    }

    func differentiate() -> HormoneMutation {
        let penultimate = images.tryGet(at: 0) ?? nil
        let last = images.tryGet(at: 1) ?? nil
        if penultimate == nil && last == nil {
            return .Empty
        } else if penultimate == nil && last != nil {
            return .Add
        } else if penultimate != nil && last == nil {
            return .Remove
        } else if penultimate != last {
            return .Edit
        }
        return .None
    }

    private func logState() {
        let log = PDLog<SiteImageHistory>()
        let last = images.tryGet(at: 0)??.accessibilityIdentifier ?? "nil"
        let latest = images.tryGet(at: 1)??.accessibilityIdentifier ?? "nil"
        log.info("HormoneCell site image history last: \(last), Latest: \(latest)")
    }
}

class SiteImageHistory: SiteImageHistorical {

    private var recorders: [SiteImageRecorder]

    init(_ upperLimit: Int = SUPPORTED_HORMONE_UPPER_QUANTITY_LIMIT) {
        recorders = []
        for i in 0..<upperLimit {
            recorders.append(SiteImageRecorder(i))
        }
    }

    public subscript(index: Index) -> SiteImageRecording {
        recorders[index]
    }
}
