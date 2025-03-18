#!/usr/bin/swift

import Foundation

// Constants
let cmd = "xcodebuild"
let lintPaths = "Sources/ Tests/"
let lintFlags = "--quiet --fix"
let testBuild = "xcodebuild build-for-testing"
let testFlags = "-destination 'platform=iOS Simulator,name=iPhone 16,OS=18.3.1' -quiet"

// Maps option keys to the corresponding test schemes.
let testSchemes: [String: String] = [
    "pdkit": "PDKitTests",
    "patchdata": "PatchDataTests",
    "patchday": "PatchDayTests"
]

// Run a shell command (helper).
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

// Run a task.
func runTask(_ taskName: String) -> Int32 {
    guard let task = tasks[taskName] else {
        print("❌ Unknown task: \(taskName). Available tasks: \(tasks.keys.joined(separator: ", "))")
        return 1
    }
    return task()
}

// Run tests.
func runTest(_ scheme: String) -> Int32 {
    return build(forTesting: true) == 0 ? run("\(cmd) test -scheme \(scheme) \(testFlags)") : 1
}

// Build PatchDay
func build(forTesting: Bool = false) -> Int32 {
    let buildCommand = forTesting ? "\(testBuild) -scheme Tests \(testFlags)" : cmd
    return run(buildCommand)
}

// All tasks (commands).
var tasks: [String: () -> Int32] = [
    "build": {
        let args = CommandLine.arguments.dropFirst(2) // Get arguments after `build`
        let isTestBuild = args.contains("--test")
        return build(forTesting: isTestBuild)
    },
    "test": {
        let args = CommandLine.arguments.dropFirst(2) // Get test names after `test`
        let schemes = args.isEmpty ? Array(testSchemes.values) : args.compactMap { testSchemes[$0] }
        
        if schemes.isEmpty {
            print("❌ Invalid test names. Available tests: \(testSchemes.keys.joined(separator: ", "))")
            return 1
        }

        for scheme in schemes {
            let res = runTest(scheme)
            if res != 0 { return res }
        }
        return 0
    },
    "lint": { run("swiftlint lint \(lintPaths) \(lintFlags)") }
]

// ~ Main ~

if CommandLine.arguments.count < 2 {
    print("❌ No command provided. Available commands: \(tasks.keys.joined(separator: ", "))")
    exit(1)
}

exit(runTask(CommandLine.arguments[1]))
