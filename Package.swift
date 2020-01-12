// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "chia",
    platforms: [
        .macOS(.v10_12),
    ],
    products: [
        .library(name: "chia", targets: ["chia"]),
        .executable(name: "chia-cli", targets: ["chiaCLI"])
    ],
    dependencies: [
        .package(url: "https://github.com/johnsundell/shellout.git", from: "2.0.0"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "chia",
            dependencies: [
                "ShellOut", "Files"
            ]
        ),
        .target(
            name: "chiaCLI",
            dependencies: ["chia"]
        ),
        .testTarget(
            name: "chiaTests",
            dependencies: ["chia"]
        )
    ]
)
