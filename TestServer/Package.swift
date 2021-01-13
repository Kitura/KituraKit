// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "TestServer",
    dependencies: [
        .package(url: "https://github.com/Kitura/Kitura.git", from: "2.9.200"),
        .package(url: "https://github.com/Kitura/HeliumLogger.git", from: "1.9.200"),
        .package(url: "https://github.com/Kitura/Swift-JWT.git", from: "3.6.200"),
    ],
    targets: [
        .target(
            name: "TestServer",
            dependencies: ["Kitura", "HeliumLogger", "SwiftJWT"]),
    ]
)
