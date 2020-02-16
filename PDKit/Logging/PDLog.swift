//
// Created by Juliya Smith on 12/24/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation


public class PDLog<T> {

    private enum LogStatus: String {
        case INFO = "INFO"
        case WARN = "WARN"
        case ERROR = "ERROR"
    }
    
    private var symbolMap: [LogStatus: String] = [
        .INFO: "🔎",
        .WARN: "⚠️",
        .ERROR: "🛑"
    ]

    private var context: String

    public init() {
        self.context = String(describing: T.self)
    }

    public func info(_ message: String, silence: Bool=false) {
        if (!silence) {
            printMessage(message, status: .INFO)
        }
    }

    public func warn(_ message: String) {
        printMessage(message, status: .WARN)
    }

    public func error(_ message: String) {
        printMessage(message, status: .ERROR)
    }

    public func error(_ message: String, _ error: Error) {
        printMessage("message. \(String(describing: error))", status: .ERROR)
    }

    public func error(_ error: Error) {
        printMessage(String(describing: error), status: .ERROR)
    }

    private func printMessage(_ message: String, status: LogStatus) {
        let symbol = symbolMap[status] ?? ""
        print("\(symbol) \(status.rawValue) \(contextString) \(symbol) ::: \(message).")
    }

    private var contextString: String {
        if let bundleId = bundle {
            return "\(bundleId).\(context)"
        }
        return context
    }

    private var bundle: String? {
        if let type = T.self as? AnyClass.Type, let id = Bundle(for: type).bundleIdentifier {
            return id
        }
        return nil
    }
}
