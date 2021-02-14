//
// PDLog.swift
// Created by Juliya Smith on 12/24/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation

public enum PDLogLevels {
    case DEBUG
    case NONE
}

/// Print something that is easy to find in the logs.  Use for debugging purposes only. Do not commit usages.
public func tprint(_ msg: Any?) {
    print("\n\n____TEST____\n")
    print(msg ?? "nil")
    print("\n____TEST____\n\n")
}

/// Set to `LogLevel.DEBUG` to turn on loggers.
public var PDLogLevel = PDLogLevels.NONE

public class PDLog<T> {

    private enum LogStatus: String {
        case INFO
        case WARN
        case ERROR
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

    public func info(_ message: String, silence: Bool = false) {
        guard !silence else { return }
        printMessage(message, status: .INFO)
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
        guard PDLogLevel == PDLogLevels.DEBUG else { return }
        var m = message
        if m.last == "." {
            m.removeLast()
        }
        let symbol = symbolMap[status] ?? ""
        print("\(symbol) \(status.rawValue) \(contextString) \(symbol) ::: \(message).")
    }

    private var contextString: String {
        guard let bundleId = bundle else { return context }
        return "\(bundleId).\(context)"
    }

    private var bundle: String? {
        guard let t = T.self as? AnyClass.Type, let id = Bundle(for: t).bundleIdentifier else {
            return nil
        }
        return id
    }
}
