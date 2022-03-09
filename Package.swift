// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlutterUI",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "FlutterUI",
            targets: ["FlutterUI"]),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: "FlutterUI",
            dependencies: ["FlutterCore"]
        ),
        .target(
            name: "FlutterCore",
            dependencies: []
        )
    ]
)
