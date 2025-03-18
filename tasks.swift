#!/usr/bin/swift

import Foundation

let cmd = "xcodebuild"
let lintPaths = "Sources/ Tests/"
let lintFlags = "--quiet --fix"
let testBuild = "xcodebuild build-for-testing"
let testFlags = "-destination 'platform=iOS Simulator,name=iPhone 16,OS=18.3.1'"

func run(_ command: String) -> Int32 {
    print("🔹 Running: \(command)")
    let process = Process()
    let pipe = Pipe()
    
    process.standardOutput = pipe
    process.standardError = pipe
    process.arguments = ["-c", command]
    process.launchPath = "/bin/zsh"
    process.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    
    let output = String(data: data, encoding: .utf8) ?? ""
    if !output.isEmpty {
        print(output)
    }
    
    if process.terminationStatus != 0 {
        print("❌ Command failed: \(command)")
    }
    
    return process.terminationStatus
}

func runTask(_ taskName: String) -> Int32 {
    guard let task = tasks[taskName] else {
        print("❌ Unknown task: \(taskName). Available tasks: \(tasks.keys.joined(separator: ", "))")
        return 1
    }
    return task()
}

func runTest(_ scheme: String) -> Int32 {
    return runTask("build-for-tests") == 0 ? run("\(cmd) test -scheme \(scheme) \(testFlags)") : 1
}

let tasks: [String: () -> Int32] = [
    "build": { run(cmd) },
    "build-for-tests": { run("\(testBuild) -scheme Tests \(testFlags)") },
    "test": {
        for testName in ["test-pdkit", "test-patchdata", "test-patchday"] {
            let res = runTask(testName)
            if res != 0 { return res }
        }
        return 0
    },
    "test-pdkit": { runTest("PDKitTests") },
    "test-patchdata": { runTest("PatchDataTests") },
    "test-patchday": { runTest("PatchDayTests") },
    "lint": { run("swiftlint lint \(lintPaths) \(lintFlags)") }
]

// ~ Main ~
if CommandLine.arguments.count < 2 {
    print("❌ No command provided. Available commands: \(tasks.keys.joined(separator: ", "))")
    exit(1)
}

exit(runTask(CommandLine.arguments[1]))
