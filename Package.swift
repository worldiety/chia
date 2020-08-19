// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "chia",
    platforms: [
        .macOS(.v10_12)
    ],
    products: [
        .library(name: "chiaLib", targets: ["chiaLib"]),
        .library(name: "TerminalLog", targets: ["TerminalLog"]),
        .executable(name: "chia", targets: ["chia"])
    ],
    dependencies: [
        .package(url: "https://github.com/johnsundell/shellout.git", from: "2.0.0"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.1.1"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-tools-support-core.git", from: "0.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", .exact("0.50100.0")),
        .package(url: "https://github.com/jkandzi/Progress.swift", from: "0.4.0")
    ],
    targets: [
        .target(
            name: "chiaLib",
            dependencies: [
                "ShellOut", "Files", "Yams", "Logging", "SwiftSyntax", "Progress"
            ]
        ),
        .target(
            name: "TerminalLog",
            dependencies: [
                "Logging"
            ]
        ),
        .target(
            name: "chia",
            dependencies: ["chiaLib", "SwiftToolsSupport-auto", "TerminalLog"]
        ),
        .testTarget(
            name: "chiaTests",
            dependencies: ["chiaLib"]
        )
    ]
)
