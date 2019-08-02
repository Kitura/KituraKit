// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "TestServer",
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/Kitura.git", from: "2.6.0"),
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", from: "1.8.0"),
        .package(url: "https://github.com/IBM-Swift/Swift-JWT.git", from: "3.1.0"),
    ],
    targets: [
        .target(
            name: "TestServer",
            dependencies: ["Kitura", "HeliumLogger", "SwiftJWT"]),
    ]
)
