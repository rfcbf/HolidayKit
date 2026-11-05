// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HolidayKit",
    platforms: [.iOS(.v17), .macOS(.v14), .watchOS(.v10), .tvOS(.v17), .visionOS(.v1)],
    products: [
        .library(name: "HolidayKit", targets: ["HolidayKit"])
    ],
    targets: [
        .target(name: "HolidayKit"),
        .testTarget(name: "HolidayKitTests", dependencies: ["HolidayKit"])
    ]
)
