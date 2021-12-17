// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CoreGraphics

let package = Package(
    name: "PhoneParser",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PhoneParser",
            targets: ["PhoneParser"]),
    ],
    dependencies: [
        .package(name: "libPhoneNumber", url: "https://github.com/alex1704/libPhoneNumber-iOS", branch: "master")
    ],
    targets: [
        .target(
            name: "PhoneParser",
            dependencies: [
                "libPhoneNumber"
            ]),
        .testTarget(
            name: "PhoneParserTests",
            dependencies: ["PhoneParser"],
        resources: [
            .copy("Resources")
        ])
    ]
)
