// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AMKit",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "AMKit",
            targets: ["AMKit"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-server/async-http-client.git",
            from: "1.26.0"
        ),
        .package(
            url: "https://github.com/vapor/jwt-kit.git",
            from: "5.2.0"
        )
    ],
    targets: [
        .target(
            name: "AMKit",
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "JWTKit", package: "jwt-kit")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "AMKitTests",
            dependencies: [
                "AMKit",
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "JWTKit", package: "jwt-kit")
            ],
            path: "Tests/AMKitTests",
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("StrictConcurrency")
            ]
        )
    ]
)
