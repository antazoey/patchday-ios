// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "patchday-ios",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "patchday-ios",
            targets: ["PatchDay", "PDKit", "PatchData", "NextHormoneWidget"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PatchDay",
            dependencies: ["PDKit", "PatchData"],
            exclude: ["README.md", "Info.plist", "PatchDay.entitlements"]
        ),
        .target(
            name: "PDKit",
            exclude: ["README.md", "Info.plist"]
        ),
        .target(
            name: "PatchData",
            dependencies: ["PDKit"],
            exclude: ["README.md", "Info.plist"]
        ),
        .target(
            name: "NextHormoneWidget",
            dependencies: ["PatchDay"],
            exclude: ["Info.plist", "NextHormoneWidget.entitlements"]
        ),
        .target(
            name: "PDMock",
            exclude: ["README.md", "Info.plist"]
        ),
        .testTarget(
            name: "PDKitTests",
            dependencies: ["PDMock", "PatchDay"],
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "PatchDataTests",
            dependencies: ["PDMock", "PatchDay"],
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "PatchDayTests",
            dependencies: ["PDMock", "PatchDay"],
            exclude: ["Info.plist"]
        )
    ]
)
