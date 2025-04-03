// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Arctop-SDK",
    platforms: [
            .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Arctop-SDK",
            targets: ["Arctop-SDK"]),
    ],
    targets: [
        .binaryTarget(
            name: "Arctop-SDK",
            path: "Sources/ArctopSDK.xcframework.zip"
        )
    ]
)
